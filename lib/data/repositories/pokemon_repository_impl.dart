import '../../domain/entities/pokemon.dart';
import '../../domain/repositories/pokemon_repository.dart';
import '../datasources/pokemon_remote_datasource.dart';

class PokemonRepositoryImpl implements PokemonRepository {
  final PokemonRemoteDataSource remoteDataSource;

  PokemonRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Pokemon>> getPokemonList({int offset = 0, int limit = 20}) async {
    try {
      final result = await remoteDataSource.getPokemonList(
        offset: offset,
        limit: limit,
      );
      return result.results;
    } catch (e) {
      throw Exception('Error fetching Pokémon list: $e');
    }
  }
}
