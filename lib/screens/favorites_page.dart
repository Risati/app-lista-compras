import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shopping_list_model.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

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
          return ListTile(
            title: Text(item.name),
            subtitle: Text('Qtd: ${item.quantity}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.star, color: Colors.amber),
                  onPressed: () {
                    model.toggleFavorite(item);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Provider.of<ShoppingListModel>(context, listen: false)
                        .addFavoriteToList(item);
                  },
                ),
              ],
            ),
            leading: Checkbox(
              value: item.purchased,
              onChanged: (_) {
                model.togglePurchased(item);
              },
            ),
          );
        },
      ),
    );
  }
}
