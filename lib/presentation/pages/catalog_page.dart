import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/pokemon.dart';
import '../bloc/pokemon/pokemon_bloc.dart';
import '../bloc/pokemon/pokemon_event.dart';
import '../bloc/pokemon/pokemon_state.dart';
import '../bloc/cart/cart_bloc.dart';
import '../bloc/cart/cart_event.dart';
import '../bloc/cart/cart_state.dart';
import '../bloc/connectivity/connectivity_bloc.dart';
import '../bloc/connectivity/connectivity_state.dart';
import '../widgets/colored_pokemon_card.dart';
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
  final Map<int, bool> _loadingStates = {};

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
    return currentScroll >= (maxScroll * 0.8);
  }

  Future<void> _addPokemonToCart(Pokemon pokemon) async {
    setState(() {
      _loadingStates[pokemon.id] = true;
    });

    try {
      context.read<CartBloc>().add(AddPokemonToCart(pokemon: pokemon));
      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${pokemon.name.toUpperCase()} agregado al carrito',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(
                  Icons.catching_pokemon,
                  color: Colors.white.withOpacity(0.8),
                  size: 20,
                ),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Error al agregar ${pokemon.name.toUpperCase()}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingStates[pokemon.id] = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokémon Catalog'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
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
              return GridView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: state.hasReachedMax
                    ? state.pokemonList.length
                    : state.pokemonList.length + 2,
                itemBuilder: (context, index) {
                  if (index >= state.pokemonList.length) {
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }

                  final pokemon = state.pokemonList[index];
                  final isLoading = _loadingStates[pokemon.id] ?? false;

                  return ColoredPokemonCard(
                    key: ValueKey(pokemon.name),
                    pokemon: pokemon,
                    isLoading: isLoading,
                    onAddToCart: () => _addPokemonToCart(pokemon),
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
            backgroundColor: Colors.blue,
            child: Stack(
              children: [
                const Icon(Icons.shopping_cart, color: Colors.white),
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
