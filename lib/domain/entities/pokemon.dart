import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:pokemon_cart_app/core/constants/pokemon_type_colors.dart';

class Pokemon extends Equatable {
  final int id;
  final String name;
  final String imageUrl;
  final String url;
  final List<String> types;

  const Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.url,
    required this.types,
  });

  Color get primaryTypeColor {
    if (types.isEmpty) return const Color(0xFFBBBBBB);
    return PokemonTypeColors.getTypeColor(types.first);
  }

  @override
  List<Object> get props => [id, name, imageUrl, url, types];
}
