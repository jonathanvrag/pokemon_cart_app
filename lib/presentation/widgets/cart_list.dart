import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cart/cart_bloc.dart';
import '../bloc/cart/cart_event.dart';
import '../bloc/cart/cart_state.dart';
import 'cart_item_card.dart';

class CartList extends StatefulWidget {
  const CartList({super.key});

  @override
  State<CartList> createState() => _CartListState();
}

class _CartListState extends State<CartList> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<CartBloc, CartState>(
      listener: (context, state) {
        if (state is CartLoaded) {
          setState(() {});
        }
      },
      child: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoaded) {
            final items = state.items;

            if (items.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Tu carrito está vacío',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 10),
                  key: ValueKey(
                    '${item.pokemonName}_${item.captureTime.millisecondsSinceEpoch}',
                  ),
                  child: CartItemCard(
                    cartItem: item,
                    onRemove: () {
                      context.read<CartBloc>().add(
                        RemovePokemonFromCart(pokemonName: item.pokemonName),
                      );
                    },
                  ),
                );
              },
            );
          }

          if (state is CartLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return const Center(child: Text('Carrito vacío'));
        },
      ),
    );
  }
}
