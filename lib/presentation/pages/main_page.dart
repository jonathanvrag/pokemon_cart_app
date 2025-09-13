import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cart/cart_bloc.dart';
import '../bloc/cart/cart_state.dart';
import 'catalog_page.dart';
import 'cart_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [const CatalogPage(), const CartPage()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          int cartItemCount = 0;
          if (state is CartLoaded) {
            cartItemCount = state.totalItems;
          }

          return BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.list),
                label: 'Catálogo',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    const Icon(Icons.shopping_cart),
                    if (cartItemCount > 0)
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
                            '$cartItemCount',
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
                label: 'Carrito',
              ),
            ],
          );
        },
      ),
    );
  }
}
