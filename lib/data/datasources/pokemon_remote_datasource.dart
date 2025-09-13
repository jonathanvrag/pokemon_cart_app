import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/pokemon_model.dart';

abstract class PokemonRemoteDataSource {
  Future<PokemonListResponse> getPokemonList({int offset = 0, int limit = 20});
}

class PokemonRemoteDataSourceImpl implements PokemonRemoteDataSource {
  final Dio dio;

  PokemonRemoteDataSourceImpl({required this.dio});

  @override
  Future<PokemonListResponse> getPokemonList({
    int offset = 0,
    int limit = ApiConstants.defaultLimit,
  }) async {
    try {
      final response = await dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.pokemonEndpoint}',
        queryParameters: {'offset': offset, 'limit': limit},
      );

      if (response.statusCode == 200) {
        return PokemonListResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load pokemon list');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
