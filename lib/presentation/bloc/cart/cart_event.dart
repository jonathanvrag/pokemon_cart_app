import 'package:equatable/equatable.dart';
import '../../../domain/entities/pokemon.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}

class AddPokemonToCart extends CartEvent {
  final Pokemon pokemon;

  const AddPokemonToCart({required this.pokemon});

  @override
  List<Object> get props => [pokemon];
}

class RemovePokemonFromCart extends CartEvent {
  final String pokemonName;

  const RemovePokemonFromCart({required this.pokemonName});

  @override
  List<Object> get props => [pokemonName];
}

class LoadCart extends CartEvent {
  const LoadCart();
}

class ClearCart extends CartEvent {
  const ClearCart();
}

class SyncCart extends CartEvent {
  const SyncCart();
}

class ConnectivityStatusChanged extends CartEvent {
  final bool isConnected;

  const ConnectivityStatusChanged({required this.isConnected});

  @override
  List<Object> get props => [isConnected];
}
