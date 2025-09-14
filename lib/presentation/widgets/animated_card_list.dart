import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/cart_item.dart';
import '../bloc/cart/cart_bloc.dart';
import '../bloc/cart/cart_event.dart';
import '../bloc/cart/cart_state.dart';
import 'cart_item_card.dart';

class AnimatedCartList extends StatefulWidget {
  const AnimatedCartList({super.key});

  @override
  State<AnimatedCartList> createState() => _AnimatedCartListState();
}

class _AnimatedCartListState extends State<AnimatedCartList> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<CartItem> _items = [];

  @override
  Widget build(BuildContext context) {
    return BlocListener<CartBloc, CartState>(
      listener: (context, state) {
        if (state is CartLoaded) {
          _updateList(state.items);
        }
      },
      child: AnimatedList(
        key: _listKey,
        initialItemCount: _items.length,
        itemBuilder: (context, index, animation) {
          if (index >= _items.length) return const SizedBox();

          final cartItem = _items[index];

          return SlideTransition(
            position: animation.drive(
              Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero),
            ),
            child: CartItemCard(
              key: ValueKey(cartItem.pokemonName),
              cartItem: cartItem,
              onRemove: () => _removeItem(index),
            ),
          );
        },
      ),
    );
  }

  void _updateList(List<CartItem> newItems) {
    for (int i = _items.length - 1; i >= 0; i--) {
      if (!newItems.any((item) => item.pokemonName == _items[i].pokemonName)) {
        _removeItemAt(i);
      }
    }

    for (int i = 0; i < newItems.length; i++) {
      if (i >= _items.length ||
          _items[i].pokemonName != newItems[i].pokemonName) {
        _insertItemAt(i, newItems[i]);
      }
    }
  }

  void _removeItem(int index) {
    final removedItem = _items[index];
    _items.removeAt(index);

    _listKey.currentState?.removeItem(
      index,
      (context, animation) => SlideTransition(
        position: animation.drive(
          Tween<Offset>(begin: Offset.zero, end: const Offset(-1.0, 0.0)),
        ),
        child: CartItemCard(cartItem: removedItem, onRemove: () {}),
      ),
      duration: const Duration(milliseconds: 300),
    );

    context.read<CartBloc>().add(
      RemovePokemonFromCart(pokemonName: removedItem.pokemonName),
    );
  }

  void _insertItemAt(int index, CartItem cartItem) {
    _items.insert(index, cartItem);
    _listKey.currentState?.insertItem(index);
  }

  void _removeItemAt(int index) {
    final removedItem = _items.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => SlideTransition(
        position: animation.drive(
          Tween<Offset>(begin: Offset.zero, end: const Offset(-1.0, 0.0)),
        ),
        child: CartItemCard(cartItem: removedItem, onRemove: () {}),
      ),
    );
  }
}
