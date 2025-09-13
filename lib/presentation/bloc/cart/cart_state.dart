import 'package:equatable/equatable.dart';
import '../../../domain/entities/cart_item.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {
  final String? pokemonName;

  const CartLoading({this.pokemonName});

  @override
  List<Object?> get props => [pokemonName];
}

class CartLoaded extends CartState {
  final List<CartItem> items;
  final double totalPrice;
  final int totalItems;
  final bool isSynced;

  const CartLoaded({
    required this.items,
    required this.totalPrice,
    required this.totalItems,
    this.isSynced = true,
  });

  CartLoaded copyWith({
    List<CartItem>? items,
    double? totalPrice,
    int? totalItems,
    bool? isSynced,
  }) {
    return CartLoaded(
      items: items ?? this.items,
      totalPrice: totalPrice ?? this.totalPrice,
      totalItems: totalItems ?? this.totalItems,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  List<Object?> get props => [items, totalPrice, totalItems, isSynced];
}

class CartError extends CartState {
  final String message;
  final String? pokemonName;

  const CartError({required this.message, this.pokemonName});

  @override
  List<Object?> get props => [message, pokemonName];
}

class PokemonAdded extends CartState {
  final String pokemonName;
  final String? location;

  const PokemonAdded({required this.pokemonName, this.location});

  @override
  List<Object?> get props => [pokemonName, location];
}

class CartSyncInProgress extends CartState {
  final DateTime startTime;

  const CartSyncInProgress({required this.startTime});

  @override
  List<Object?> get props => [startTime];
}

class CartSyncSuccess extends CartState {
  final DateTime syncTime;
  final int itemsSynced;

  const CartSyncSuccess({required this.syncTime, required this.itemsSynced});

  @override
  List<Object> get props => [syncTime, itemsSynced];
}

class CartSyncFailure extends CartState {
  final String error;
  final DateTime failureTime;

  const CartSyncFailure({required this.error, required this.failureTime});

  @override
  List<Object> get props => [error, failureTime];
}
