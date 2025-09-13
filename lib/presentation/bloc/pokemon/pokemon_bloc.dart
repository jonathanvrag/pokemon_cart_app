import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_pokemon_list.dart';
import 'pokemon_event.dart';
import 'pokemon_state.dart';

class PokemonBloc extends Bloc<PokemonEvent, PokemonState> {
  final GetPokemonList getPokemonList;

  PokemonBloc({required this.getPokemonList}) : super(PokemonInitial()) {
    on<LoadPokemonList>(_onLoadPokemonList);
    on<LoadMorePokemon>(_onLoadMorePokemon);
  }

  Future<void> _onLoadPokemonList(
    LoadPokemonList event,
    Emitter<PokemonState> emit,
  ) async {
    emit(PokemonLoading());

    try {
      final pokemonList = await getPokemonList(offset: 0, limit: 20);
      emit(PokemonLoaded(pokemonList: pokemonList));
    } catch (e) {
      emit(PokemonError(message: e.toString()));
    }
  }

  Future<void> _onLoadMorePokemon(
    LoadMorePokemon event,
    Emitter<PokemonState> emit,
  ) async {
    final currentState = state;
    if (currentState is PokemonLoaded && !currentState.hasReachedMax) {
      try {
        final morePokemon = await getPokemonList(
          offset: currentState.pokemonList.length,
          limit: 20,
        );

        if (morePokemon.isEmpty) {
          emit(currentState.copyWith(hasReachedMax: true));
        } else {
          emit(
            currentState.copyWith(
              pokemonList: [...currentState.pokemonList, ...morePokemon],
            ),
          );
        }
      } catch (e) {
        emit(PokemonError(message: e.toString()));
      }
    }
  }
}
