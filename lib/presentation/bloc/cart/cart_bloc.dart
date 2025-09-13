import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:flutter/services.dart';
import '../../../core/services/location_service.dart';
import '../../../domain/entities/cart_item.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  late Box<CartItem> _cartBox;
  List<CartItem> _cartItems = [];

  CartBloc() : super(CartInitial()) {
    _cartBox = Hive.box<CartItem>('cartBox');

    on<LoadCart>(_onLoadCart);
    on<AddPokemonToCart>(_onAddPokemonToCart);
    on<RemovePokemonFromCart>(_onRemovePokemonFromCart);
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
      if (!isClosed) emit(_buildCartLoadedState());
    } catch (e) {
      if (!isClosed) emit(CartError(message: 'Error: $e'));
    }
  }

  CartLoaded _buildCartLoadedState() {
    final totalPrice = _cartItems.fold<double>(
      0.0,
      (sum, item) => sum + item.simulatedPrice,
    );

    return CartLoaded(
      items: List.unmodifiable(_cartItems),
      totalPrice: totalPrice,
      totalItems: _cartItems.length,
    );
  }
}
