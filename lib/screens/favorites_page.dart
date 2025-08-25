import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/lists_provider.dart';
import '../models/shopping_list.dart';
import '../core/theme/text_styles.dart';
import '../core/constants/strings.dart';

class FavoritesPage extends StatelessWidget {
  final ShoppingList list;
  const FavoritesPage({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ListsProvider>();
    final favorites = model.favorites;

    if (favorites.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Favoritos')),
        body: Center(
          child: Text(Strings.msgNoFavorites,
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(178),
              )),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text(Strings.titleFavorites)),
      body: ListView.separated(
        itemCount: favorites.length,
        padding: const EdgeInsets.all(12),
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final item = favorites[i];

          return Dismissible(
            key: ValueKey(item.name + item.quantity.toString()),

            // Swipe para a direita → adicionar à lista
            background: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 24),
              child: Icon(Icons.add,
                  color: Theme.of(context).colorScheme.onPrimary, size: 32),
            ),

            // Swipe para a esquerda → remover dos favoritos
            secondaryBackground: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              child: Icon(Icons.delete,
                  color: Theme.of(context).colorScheme.onError, size: 32),
            ),

            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                // Evita duplicados
                final alreadyInList =
                    list.items.any((i) => i.name == item.name);
                if (!alreadyInList) {
                  model.addFavoriteToList(list, item);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('"${item.name}" adicionado à lista!'),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(12),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('"${item.name}" já está na lista.'),
                      backgroundColor:
                          Theme.of(context).colorScheme.secondaryContainer,
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(12),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
                return false;
              } else if (direction == DismissDirection.endToStart) {
                model.toggleFavorite(item);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('"${item.name}" removido dos favoritos.'),
                    backgroundColor: Theme.of(context).colorScheme.error,
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(12),
                    duration: const Duration(seconds: 2),
                  ),
                );
                return true;
              }
              return false;
            },

            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Theme.of(context).colorScheme.surface,
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Text(item.name,
                    style: AppTextStyles.bodyLarge(context)
                        .copyWith(fontWeight: FontWeight.w600)),
                subtitle: Text('Qtd: ${item.quantity}',
                    style: AppTextStyles.bodyMedium(context).copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withAlpha(178))),
                trailing: IconButton(
                  icon: Icon(
                    item.isFavorite ? Icons.star : Icons.star_border,
                    color: item.isFavorite
                        ? Colors.amber
                        : Theme.of(context).iconTheme.color?.withAlpha(153),
                  ),
                  onPressed: () => model.toggleFavorite(item),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
