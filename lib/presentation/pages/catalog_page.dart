import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/pokemon/pokemon_bloc.dart';
import '../bloc/pokemon/pokemon_event.dart';
import '../bloc/pokemon/pokemon_state.dart';
import '../bloc/cart/cart_bloc.dart';
import '../bloc/cart/cart_state.dart';
import '../bloc/connectivity/Connectivity_bloc.dart';
import '../bloc/connectivity/connectivity_state.dart';
import '../widgets/pokemon_card.dart';
import 'cart_page.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<PokemonBloc>().add(const LoadPokemonList());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<PokemonBloc>().add(const LoadMorePokemon());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokémon Catalog'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          BlocBuilder<ConnectivityBloc, ConnectivityState>(
            builder: (conetxt, state) {
              return Container(
                margin: const EdgeInsets.only(right: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      state is ConnectivityOnline ? Icons.wifi : Icons.wifi_off,
                      color: state is ConnectivityOnline
                          ? Colors.green
                          : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      state is ConnectivityOnline ? 'Online' : 'Offline',
                      style: TextStyle(
                        fontSize: 12,
                        color: state is ConnectivityOnline
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<PokemonBloc, PokemonState>(
        builder: (context, state) {
          if (state is PokemonInitial || state is PokemonLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PokemonError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<PokemonBloc>().add(const LoadPokemonList());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is PokemonLoaded) {
            return ListView.builder(
              controller: _scrollController,
              itemCount: state.hasReachedMax
                  ? state.pokemonList.length
                  : state.pokemonList.length + 1,
              itemBuilder: (context, index) {
                if (index >= state.pokemonList.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final pokemon = state.pokemonList[index];
                return PokemonCard(pokemon: pokemon);
              },
            );
          }

          return const SizedBox();
        },
      ),

      floatingActionButton: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          int itemCount = 0;
          if (state is CartLoaded) {
            itemCount = state.totalItems;
          }

          return FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartPage()),
              );
            },
            child: Stack(
              children: [
                const Icon(Icons.shopping_cart),
                if (itemCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$itemCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
