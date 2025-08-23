import 'package:flutter/material.dart';
import '../models/shopping_list.dart';
import 'list_tab.dart' show ListTab;
import 'cart_tab.dart' show CartPage;

class HomeScreen extends StatelessWidget {
  final ShoppingList list;
  const HomeScreen({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lembra AÍ'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Para Comprar'),
              Tab(text: 'Carrinho'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListTab(list: list),
            CartPage(list: list),
          ],
        ),
      ),
    );
  }
}
