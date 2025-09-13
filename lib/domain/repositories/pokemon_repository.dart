import '../entities/pokemon.dart';

abstract class PokemonRepository {
  Future<List<Pokemon>> getPokemonList({int offset = 0, int limit = 20});
}
