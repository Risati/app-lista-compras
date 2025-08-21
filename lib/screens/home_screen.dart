import 'package:flutter/material.dart';
import 'list_tab.dart' show ListTab;
import 'cart_tab.dart' show CartPage;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
        body: const TabBarView(
          children: [
            ListTab(),
            CartPage(),
          ],
        ),
      ),
    );
  }
}
