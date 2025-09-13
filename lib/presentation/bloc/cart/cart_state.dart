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
  List<Object?> get props => [pokemonName];}

class CartLoaded extends CartState {
  final List<CartItem> items;
  final double totalPrice;
  final int totalItems;

  const CartLoaded({
    required this.items,
    required this.totalPrice,
    required this.totalItems,
  });

  CartLoaded copyWith({
    List<CartItem>? items,
    double? totalPrice,
    int? totalItems,
  }) {
    return CartLoaded(
      items: items ?? this.items,
      totalPrice: totalPrice ?? this.totalPrice,
      totalItems: totalItems ?? this.totalItems,
    );
  }

  @override
  List<Object?> get props => [items, totalPrice, totalItems];
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
