import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/pokemon/pokemon_bloc.dart';
import '../bloc/pokemon/pokemon_event.dart';
import '../bloc/pokemon/pokemon_state.dart';
import '../bloc/cart/cart_bloc.dart';
import '../bloc/cart/cart_event.dart';
import '../bloc/cart/cart_state.dart';
import '../bloc/connectivity/connectivity_bloc.dart';
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
  Timer? _syncSnackBarTimer;
  bool _isSyncSnackBarVisible = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<PokemonBloc>().add(const LoadPokemonList());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _syncSnackBarTimer?.cancel();
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
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: BlocBuilder<CartBloc, CartState>(
              builder: (context, cartState) {
                return BlocBuilder<ConnectivityBloc, ConnectivityState>(
                  builder: (context, connectivityState) {
                    final isOnline = connectivityState is ConnectivityOnline;
                    final isSynced = cartState is CartLoaded
                        ? cartState.isSynced
                        : true;
                    final canShowSync =
                        isOnline && isSynced && !_isSyncSnackBarVisible;

                    Icon icon;
                    String text;
                    Color color;

                    if (!isOnline) {
                      icon = const Icon(Icons.cloud_off, size: 20);
                      text = 'Offline';
                      color = Colors.red;
                    } else if (canShowSync) {
                      icon = const Icon(Icons.cloud_done, size: 20);
                      text = 'Sync';
                      color = Colors.green;
                    } else {
                      icon = const Icon(Icons.cloud_sync, size: 20);
                      text = 'Pending';
                      color = Colors.orange;
                    }

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon.icon, color: color, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          text,
                          style: TextStyle(fontSize: 12, color: color),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      body: BlocListener<CartBloc, CartState>(
        listener: (context, state) {
          if (state is CartSyncInProgress) {
            _syncSnackBarTimer?.cancel();
            _syncSnackBarTimer = Timer(const Duration(seconds: 2), () {
              if (!_isSyncSnackBarVisible) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 16),
                        Text('Sincronizando carrito...'),
                      ],
                    ),
                    backgroundColor: Colors.blue,
                    duration: Duration(minutes: 1),
                  ),
                );
                setState(() {
                  _isSyncSnackBarVisible = true;
                });
              }
            });
          } else {
            _syncSnackBarTimer?.cancel();
            if (_isSyncSnackBarVisible) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              setState(() {
                _isSyncSnackBarVisible = false;
              });
            }
            if (state is CartSyncFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('❌ Error de sincronización: ${state.error}'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 4),
                  action: SnackBarAction(
                    label: 'Reintentar',
                    textColor: Colors.white,
                    onPressed: () {
                      context.read<CartBloc>().add(const SyncCart());
                    },
                  ),
                ),
              );
            }
          }
        },
        child: BlocBuilder<PokemonBloc, PokemonState>(
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
                    Text(
                      'Error: ${state.message}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<PokemonBloc>().add(
                          const LoadPokemonList(),
                        );
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
                  return PokemonCard(
                    key: ValueKey(pokemon.name),
                    pokemon: pokemon,
                  );
                },
              );
            }

            return const SizedBox();
          },
        ),
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
