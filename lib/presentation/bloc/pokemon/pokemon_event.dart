import 'package:equatable/equatable.dart';

abstract class PokemonEvent extends Equatable {
  const PokemonEvent();

  @override
  List<Object> get props => [];
}

class LoadPokemonList extends PokemonEvent {
  const LoadPokemonList();
}

class LoadMorePokemon extends PokemonEvent {
  const LoadMorePokemon();
}
