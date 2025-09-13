import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/pokemon.dart';
import '../bloc/cart/cart_bloc.dart';
import '../bloc/cart/cart_event.dart';
import '../bloc/cart/cart_state.dart';

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonCard({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: pokemon.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pokemon.name.toUpperCase(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pokémon #${_extractIdFromUrl(pokemon.url)}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            BlocListener<CartBloc, CartState>(
              listenWhen: (previous, current) {
                if (current is PokemonAdded) {
                  return current.pokemonName == pokemon.name;
                }
                if (current is CartError) {
                  return current.pokemonName == pokemon.name;
                }
                return false;
              },
              listener: (context, state) {
                if (state is PokemonAdded &&
                    state.pokemonName == pokemon.name) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${state.pokemonName.toUpperCase()} capturado!${state.location != null ? '\n📍 ${state.location}' : ''}',
                      ),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else if (state is CartError &&
                    state.pokemonName == pokemon.name) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.orange,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: BlocBuilder<CartBloc, CartState>(
                buildWhen: (previous, current) {
                  if (current is CartLoading) {
                    return current.pokemonName == pokemon.name;
                  }
                  if (current is CartLoaded) {
                    return true;
                  }
                  return false;
                },
                builder: (context, state) {
                  final isLoading =
                      state is CartLoading && state.pokemonName == pokemon.name;

                  return ElevatedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () {
                            context.read<CartBloc>().add(
                              AddPokemonToCart(pokemon: pokemon),
                            );
                          },
                    icon: isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.catching_pokemon),
                    label: Text(isLoading ? 'Capturando...' : 'Capturar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _extractIdFromUrl(String url) {
    final segments = url.split('/');
    return segments[segments.length - 2];
  }
}
