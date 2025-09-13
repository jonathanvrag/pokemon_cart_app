import '../../domain/entities/pokemon.dart';

class PokemonModel extends Pokemon {
  const PokemonModel({
    required super.id,
    required super.name,
    required super.imageUrl,
    required super.url,
    required super.type,
  });

  factory PokemonModel.fromJson(Map<String, dynamic> json) {
    final pokemonId = _extractIdFromUrl(json['url']);
    return PokemonModel(
      id: int.parse(pokemonId),
      name: json['name'],
      imageUrl:
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$pokemonId.png',
      url: json['url'],
      type: 'unknown',
    );
  }

  static String _extractIdFromUrl(String url) {
    final segments = url.split('/');
    return segments[segments.length - 2];
  }
}

class PokemonListResponse {
  final List<PokemonModel> results;
  final String? next;
  final String? previous;

  PokemonListResponse({
    required this.results,
    required this.next,
    required this.previous,
  });

  factory PokemonListResponse.fromJson(Map<String, dynamic> json) {
    return PokemonListResponse(
      results: (json['results'] as List)
          .map((pokemon) => PokemonModel.fromJson(pokemon))
          .toList(),
      next: json['next'],
      previous: json['previous'],
    );
  }
}
