import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:flutter/services.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/sync_service.dart';
import '../../../domain/entities/cart_item.dart';
import '../connectivity/connectivity_bloc.dart';
import '../connectivity/connectivity_state.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  late Box<CartItem> _cartBox;
  final SyncService _syncService;
  final ConnectivityBloc _connectivityBloc;
  List<CartItem> _cartItems = [];
  StreamSubscription<ConnectivityState>? _connectivitySubscription;
  bool _isConnected = false;
  bool _hasPendingChanges = false;

  CartBloc({
    required SyncService syncService,
    required ConnectivityBloc connectivityBloc,
  }) : _syncService = syncService,
       _connectivityBloc = connectivityBloc,
       super(CartInitial()) {
    _cartBox = Hive.box<CartItem>('cartBox');

    on<LoadCart>(_onLoadCart);
    on<AddPokemonToCart>(_onAddPokemonToCart);
    on<RemovePokemonFromCart>(_onRemovePokemonFromCart);
    on<ClearCart>(_onClearCart);
    on<SyncCart>(_onSyncCart);
    on<ConnectivityStatusChanged>(_onConnectivityStatusChanged);

    _connectivitySubscription = _connectivityBloc.stream.listen((
      connectivityState,
    ) {
      final newConnectionStatus = connectivityState is ConnectivityOnline;

      if (!_isConnected && newConnectionStatus && _hasPendingChanges) {
        add(const SyncCart());
      }

      add(ConnectivityStatusChanged(isConnected: newConnectionStatus));
    });
  }

  void _onLoadCart(LoadCart event, Emitter<CartState> emit) {
    try {
      _cartItems = _cartBox.values.toList();
      emit(_buildCartLoadedState());
    } catch (e) {
      emit(CartError(message: 'Error cargando carrito: $e'));
    }
  }

  Future<void> _onAddPokemonToCart(
    AddPokemonToCart event,
    Emitter<CartState> emit,
  ) async {
    if (isClosed) return;

    emit(CartLoading(pokemonName: event.pokemon.name));

    try {
      bool alreadyExists = _cartItems.any(
        (item) => item.pokemonName == event.pokemon.name,
      );

      if (alreadyExists) {
        if (isClosed) return;
        emit(
          CartError(
            message:
                '¡${event.pokemon.name.toUpperCase()} ya está en tu carrito!',
            pokemonName: event.pokemon.name,
          ),
        );
        await HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 1500));
        if (!isClosed) emit(_buildCartLoadedState());
        return;
      }

      await HapticFeedback.lightImpact();

      final locationData = await LocationService.getCurrentLocation();

      final random = Random();
      final price = (random.nextDouble() * 99.99) + 0.01;

      final cartItem = CartItem.fromPokemon(
        pokemon: event.pokemon,
        simulatedPrice: price,
        captureTime: DateTime.now(),
        latitude: locationData?.latitude,
        longitude: locationData?.longitude,
        locationName: locationData?.locationName,
      );

      await _cartBox.add(cartItem);
      _cartItems.add(cartItem);

      _hasPendingChanges = true;

      if (_isConnected && !isClosed) {
        add(const SyncCart());
      }

      await HapticFeedback.selectionClick();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.lightImpact();

      if (isClosed) return;
      emit(
        PokemonAdded(
          pokemonName: event.pokemon.name,
          location: locationData?.locationName,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 1500));
      if (!isClosed) emit(_buildCartLoadedState());
    } catch (e) {
      await HapticFeedback.heavyImpact();
      if (!isClosed) {
        emit(CartError(message: 'Error: $e', pokemonName: event.pokemon.name));
        await Future.delayed(const Duration(milliseconds: 1500));
        if (!isClosed) emit(_buildCartLoadedState());
      }
    }
  }

  Future<void> _onRemovePokemonFromCart(
    RemovePokemonFromCart event,
    Emitter<CartState> emit,
  ) async {
    if (isClosed) return;

    try {
      await HapticFeedback.mediumImpact();

      final keys = _cartBox.keys.toList();
      for (final key in keys) {
        final item = _cartBox.get(key);
        if (item?.pokemonName == event.pokemonName) {
          await _cartBox.delete(key);
          break;
        }
      }

      _cartItems.removeWhere((item) => item.pokemonName == event.pokemonName);

      _hasPendingChanges = true;

      if (!isClosed) {
        emit(_buildCartLoadedState());
      }

      if (_isConnected && !isClosed) {
        add(const SyncCart());
      }
    } catch (e) {
      if (!isClosed) emit(CartError(message: 'Error: $e'));
    }
  }

  Future<void> _onClearCart(ClearCart event, Emitter<CartState> emit) async {
    try {
      await _cartBox.clear();
      _cartItems.clear();
      _hasPendingChanges = true;
      emit(_buildCartLoadedState());
    } catch (e) {
      emit(CartError(message: 'Error: $e'));
    }
  }

  void _onConnectivityStatusChanged(
    ConnectivityStatusChanged event,
    Emitter<CartState> emit,
  ) {
    final wasOffline = !_isConnected;
    _isConnected = event.isConnected;

    if (wasOffline && _isConnected && _hasPendingChanges) {
      Future.delayed(Duration(milliseconds: 500), () {
        if (!isClosed) add(const SyncCart());
      });
    }

    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      emit(
        currentState.copyWith(isSynced: _isConnected && !_hasPendingChanges),
      );
    }
  }

  Future<void> _onSyncCart(SyncCart event, Emitter<CartState> emit) async {
    if (isClosed || !_isConnected) return;

    emit(CartSyncInProgress(startTime: DateTime.now()));

    try {
      final result = await _syncService.syncCart();

      if (!isClosed) {
        if (result.isSuccess) {
          _hasPendingChanges = false;
          emit(
            CartSyncSuccess(
              syncTime: DateTime.now(),
              itemsSynced: result.itemsCount,
            ),
          );

          await HapticFeedback.selectionClick();

          await Future.delayed(const Duration(milliseconds: 2000));
          if (!isClosed) emit(_buildCartLoadedState());
        } else {
          emit(
            CartSyncFailure(
              error: result.error ?? 'Error desconocido',
              failureTime: DateTime.now(),
            ),
          );

          await HapticFeedback.heavyImpact();

          await Future.delayed(const Duration(milliseconds: 3000));
          if (!isClosed) emit(_buildCartLoadedState());
        }
      }
    } catch (e) {
      if (!isClosed) {
        emit(
          CartSyncFailure(
            error: 'Error de sincronización: $e',
            failureTime: DateTime.now(),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 3000));
        if (!isClosed) emit(_buildCartLoadedState());
      }
    }
  }

  CartLoaded _buildCartLoadedState() {
    final totalPrice = _cartItems.fold<double>(
      0.0,
      (sum, item) => sum + item.simulatedPrice,
    );

    return CartLoaded(
      items: List.unmodifiable(List.from(_cartItems)),
      totalPrice: totalPrice,
      totalItems: _cartItems.length,
      isSynced: _isConnected && !_hasPendingChanges,
    );
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
