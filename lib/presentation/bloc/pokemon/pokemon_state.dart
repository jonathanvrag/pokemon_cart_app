import 'package:equatable/equatable.dart';
import '../../../domain/entities/pokemon.dart';

abstract class PokemonState extends Equatable {
  const PokemonState();

  @override
  List<Object> get props => [];
}

class PokemonInitial extends PokemonState {}

class PokemonLoading extends PokemonState {}

class PokemonLoaded extends PokemonState {
  final List<Pokemon> pokemonList;
  final bool hasReachedMax;

  const PokemonLoaded({required this.pokemonList, this.hasReachedMax = false});

  PokemonLoaded copyWith({List<Pokemon>? pokemonList, bool? hasReachedMax}) {
    return PokemonLoaded(
      pokemonList: pokemonList ?? this.pokemonList,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object> get props => [pokemonList, hasReachedMax];
}

class PokemonError extends PokemonState {
  final String message;

  const PokemonError({required this.message});

  @override
  List<Object> get props => [message];
}
