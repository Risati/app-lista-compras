import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shopping_list_model.dart';
import '../models/shopping_list.dart';

class FavoritesPage extends StatelessWidget {
  final ShoppingList list;
  const FavoritesPage({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ShoppingListModel>();
    final favorites = model.favorites;

    if (favorites.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Favoritos')),
        body: const Center(child: Text('Nenhum favorito ainda.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (_, i) {
          final item = favorites[i];
          return Dismissible(
            key: ValueKey(item.name + item.quantity.toString()),
            background: Container(
              color: Colors.green,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 24),
              child: const Icon(Icons.add, color: Colors.white, size: 32),
            ),
            secondaryBackground: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              child: const Icon(Icons.delete, color: Colors.white, size: 32),
            ),
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                // Swipe para a direita: adicionar à lista
                model.addFavoriteToList(item);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('"${item.name}" adicionado à lista!'),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.only(
                        bottom: 20, right: 20, left: 20),
                  ),
                );
                return false; // Não remove dos favoritos
              } else if (direction == DismissDirection.endToStart) {
                // Swipe para a esquerda: remover dos favoritos
                model.toggleFavorite(item);
                return true;
              }
              return false;
            },
            child: ListTile(
              title: Text(item.name),
              subtitle: Text('Qtd: ${item.quantity}'),
              trailing: IconButton(
                icon: const Icon(Icons.star, color: Colors.amber),
                onPressed: () {
                  model.toggleFavorite(item);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}