import 'package:flutter/material.dart';

class PokemonTypeColors {
  static const Map<String, Color> typeColors = {
    'normal': Color(0xFFD6CCC2),
    'fire': Color(0xFFF7B8B8),
    'water': Color(0xFFA3CEF1),
    'electric': Color(0xFFF7F3C3),
    'grass': Color(0xFFC6EBC5),
    'ice': Color(0xFFB3E3DB),
    'fighting': Color(0xFFD6B5AA),
    'poison': Color(0xFFD8B4CE),
    'ground': Color(0xFFEAD3C7),
    'flying': Color(0xFFCDCEE4),
    'psychic': Color(0xFFECCAE8),
    'bug': Color(0xFFDDE4B4),
    'rock': Color(0xFFEEE8D5),
    'ghost': Color(0xFFC5C6D9),
    'dragon': Color(0xFFD6BDFF),
    'dark': Color(0xFFBCB6AF),
    'steel': Color(0xFFD1D3DD),
    'fairy': Color(0xFFF1DBF1),
  };

  static Color getTypeColor(String type) {
    return typeColors[type.toLowerCase()] ?? Color(0xFFEFEFEF);
  }

  static Color getPrimaryTypeColor(List<Map<String, dynamic>> types) {
    if (types.isEmpty) return const Color(0xFFEFEFEF);

    final primaryType = types[0]['type']['name'] as String;
    return getTypeColor(primaryType);
  }
}
