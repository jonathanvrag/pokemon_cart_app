import 'package:flutter/material.dart';
import '../../domain/entities/pokemon.dart';
import '../../core/constants/pokemon_type_colors.dart';
import 'pokeball_button.dart';

class ColoredPokemonCard extends StatelessWidget {
  final Pokemon pokemon;
  final VoidCallback onAddToCart;
  final bool isLoading;

  const ColoredPokemonCard({
    super.key,
    required this.pokemon,
    required this.onAddToCart,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = pokemon.types.isNotEmpty
        ? PokemonTypeColors.getTypeColor(pokemon.types.first)
        : const Color(0xFFEFEFEF);

    final Color darkerColor = Color.lerp(backgroundColor, Colors.black, 0.15)!;

    return Card(
      elevation: 6,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [backgroundColor, darkerColor],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '#${pokemon.id.toString().padLeft(3, '0')}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PokeballButton(
                    isLoading: isLoading,
                    onPressed: onAddToCart,
                    size: 32,
                  ),
                ],
              ),

              Expanded(
                child: Image.network(
                  pokemon.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.catching_pokemon,
                      color: Colors.white70,
                      size: 48,
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              Text(
                pokemon.name.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              if (pokemon.types.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    pokemon.types.first.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
