import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../bloc/cart/cart_bloc.dart';
import '../bloc/cart/cart_event.dart';
import '../bloc/cart/cart_state.dart';
import '../widgets/cart_item_card.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito de Pokémon'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state is CartLoaded && state.items.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  onPressed: () {
                    _showClearCartDialog(context);
                  },
                  tooltip: 'Limpiar carrito',
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartInitial || state is CartLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CartError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<CartBloc>().add(const LoadCart());
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is CartLoaded) {
            if (state.items.isEmpty) {
              return _buildEmptyCart(context);
            }

            return Column(
              children: [
                // Resumen del carrito
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total de Pokémon:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '${state.totalItems}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Precio Total:',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${state.totalPrice.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Lista de ítems
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return CartItemCard(
                        cartItem: item,
                        onRemove: () {
                          context.read<CartBloc>().add(
                            RemovePokemonFromCart(pokemonName: item.pokemonName),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          }

          return const Center(child: Text('Estado desconocido'));
        },
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 120,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Tu carrito está vacío',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega algunos Pokémon desde el catálogo',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navegar al catálogo (cambiar tab)
              final mainPageState = context.findAncestorStateOfType<State<StatefulWidget>>();
              if (mainPageState != null) {
                // Esto es un hack, mejor usar un callback o state management
                // Por simplicidad, solo mostramos el botón
              }
            },
            icon: const Icon(Icons.list),
            label: const Text('Ver Catálogo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Limpiar Carrito'),
          content: const Text('¿Estás seguro de que quieres eliminar todos los Pokémon del carrito?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                context.read<CartBloc>().add(const ClearCart());
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Limpiar'),
            ),
          ],
        );
      },
    );
  }
}
