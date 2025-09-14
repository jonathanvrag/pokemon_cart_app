import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/pokemon.dart';
import '../../domain/repositories/pokemon_repository.dart';
import '../datasources/pokemon_remote_datasource.dart';

class PokemonRepositoryImpl implements PokemonRepository {
  final Dio _dio;
  final PokemonRemoteDataSource remoteDataSource;

  PokemonRepositoryImpl({required this.remoteDataSource})
    : _dio = Dio(
        BaseOptions(
          baseUrl: 'https://pokeapi.co/api/v2/',
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 20),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

  @override
  Future<List<Pokemon>> getPokemonList({int limit = 20, int offset = 0}) async {
    try {
      final response = await _dio.get(
        'pokemon',
        queryParameters: {'limit': limit, 'offset': offset},
      );

      final results = response.data['results'] as List;

      final List<Pokemon> pokemonList = [];

      for (final pokemonData in results) {
        try {
          final pokemon = await _fetchPokemonDetails(pokemonData);
          if (pokemon != null) {
            pokemonList.add(pokemon);
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error cargando ${pokemonData['name']}: $e');
          }
        }
      }

      return pokemonList;
    } on DioException catch (e) {
      throw Exception(_getDioErrorMessage(e));
    } catch (e) {
      throw Exception('Error inesperado al cargar Pokémon: $e');
    }
  }

  Future<Pokemon?> _fetchPokemonDetails(
    Map<String, dynamic> pokemonData,
  ) async {
    try {
      final detailResponse = await _dio.get('pokemon/${pokemonData['name']}');
      final pokemonDetail = detailResponse.data;

      final List<String> types = _parsePokemonTypes(pokemonDetail['types']);

      return Pokemon(
        id: pokemonDetail['id'],
        name: pokemonDetail['name'],
        imageUrl:
            pokemonDetail['sprites']['other']['official-artwork']['front_default'] ??
            pokemonDetail['sprites']['front_default'] ??
            '',
        url: pokemonData['url'],
        types: types,
      );
    } on DioException {
      return null;
    }
  }

  String _getDioErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Tiempo de conexión agotado. Verifica tu internet.';
      case DioExceptionType.receiveTimeout:
        return 'El servidor tardó demasiado en responder.';
      case DioExceptionType.connectionError:
        return 'Error de conexión. Verifica tu internet.';
      case DioExceptionType.badResponse:
        return 'Error del servidor (${e.response?.statusCode}).';
      case DioExceptionType.cancel:
        return 'Operación cancelada.';
      default:
        return e.message ?? 'Error de red desconocido.';
    }
  }

  List<String> _parsePokemonTypes(dynamic rawTypes) {
    if (rawTypes == null) return [];

    try {
      return (rawTypes as List<dynamic>)
          .map((typeData) => typeData['type']['name'] as String)
          .toList();
    } catch (e) {
      return [];
    }
  }
}
