import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cart/cart_bloc.dart';
import '../bloc/cart/cart_event.dart';
import '../bloc/cart/cart_state.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Carrito Pokémon'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartInitial || state is CartLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is CartLoaded) {
            if (state.items.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Tu carrito está vacío', style: TextStyle(fontSize: 18)),
                    Text('Agrega Pokémon desde el catálogo', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            }
            
            return Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue.shade50,
                  child: Column(
                    children: [
                      Text('Total Pokémon: ${state.totalItems}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('Precio Total: \$${state.totalPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                    ],
                  ),
                ),
                
                Expanded(
                  child: ListView.builder(
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: ListTile(
                          title: Text(item.pokemonName.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Precio: \$${item.simulatedPrice.toStringAsFixed(2)}', style: TextStyle(color: Colors.green.shade700)),
                              if (item.locationName != null) 
                                Text('📍 ${item.locationName}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              context.read<CartBloc>().add(RemovePokemonFromCart(pokemonName: item.pokemonName));
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
          
          if (state is CartError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  ElevatedButton(
                    onPressed: () => context.read<CartBloc>().add(const LoadCart()),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          
          return const SizedBox();
        },
      ),
    );
  }
}
