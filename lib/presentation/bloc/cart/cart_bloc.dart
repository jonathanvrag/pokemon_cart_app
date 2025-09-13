import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/services/location_service.dart';
import '../../../domain/entities/cart_item.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final List<CartItem> _cartItems = [];

  CartBloc() : super(CartInitial()) {
    on<AddPokemonToCart>(_onAddPokemonToCart);
    on<RemovePokemonFromCart>(_onRemovePokemonFromCart);
    on<LoadCart>(_onLoadCart);
  }

  Future<void> _onAddPokemonToCart(
    AddPokemonToCart event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading(pokemonName: event.pokemon.name));

    try {
      bool alreadyExists = _cartItems.any(
        (item) => item.pokemon.name == event.pokemon.name,
      );

      if (alreadyExists) {
        emit(
          CartError(
            message: '¡Este Pokémon ya está en el carrito!',
            pokemonName: event.pokemon.name,
          ),
        );
        await HapticService.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 1500));
        emit(_buildCartLoadedState());
        return;
      }

      await HapticService.lightImpact();

      final locationData = await LocationService.getCurrentLocation();

      final random = Random();
      final price = (random.nextDouble() * 99.99) + 0.01;

      final cartItem = CartItem(
        pokemon: event.pokemon,
        simulatedPrice: price,
        captureTime: DateTime.now(),
        latitude: locationData?.latitude,
        longitude: locationData?.longitude,
        locationName: locationData?.locationName,
      );

      _cartItems.add(cartItem);

      await HapticService.successPattern();

      emit(
        PokemonAdded(
          pokemonName: event.pokemon.name,
          location: locationData?.locationName,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 1500));
      emit(_buildCartLoadedState());
    } catch (e) {
      await HapticService.heavyImpact();
      emit(CartError(message: 'Error al agregar el Pokémon: $e'));
    }
  }

  Future<void> _onRemovePokemonFromCart(
    RemovePokemonFromCart event,
    Emitter<CartState> emit,
  ) async {
    try {
      await HapticService.mediumImpact();

      _cartItems.removeWhere((item) => item.pokemon.name == event.pokemonName);

      emit(_buildCartLoadedState());
    } catch (e) {
      emit(CartError(message: 'Error al eliminar el Pokémon: $e'));
    }
  }

  void _onLoadCart(LoadCart event, Emitter<CartState> emit) {
    emit(_buildCartLoadedState());
  }

  CartLoaded _buildCartLoadedState() {
    final totalPrice = _cartItems.fold<double>(
      0.0,
      (sum, item) => sum + item.simulatedPrice,
    );

    return CartLoaded(
      items: List.from(_cartItems),
      totalPrice: totalPrice,
      totalItems: _cartItems.length,
    );
  }
}
