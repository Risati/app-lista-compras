import 'package:flutter/material.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../models/grocery_item.dart';

class ShoppingItemCard extends StatelessWidget {
  final GroceryItem item;
  final VoidCallback onEdit;
  final VoidCallback onEditName;
  final VoidCallback onFavorite;

  const ShoppingItemCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onEditName,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        visualDensity: const VisualDensity(vertical: -4),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingM,
          vertical: Dimensions.paddingXS,
        ),
        tileColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusS),
        ),
        title: GestureDetector(
          onTap: onEditName,
          child: Text(
            item.name,
            style: AppTextStyles.bodyLarge(context),
          ),
        ),
        subtitle: Wrap(
          children: [
            Text(
              'Qtd: ${Formatters.quantity(item.quantity)}',
              style: AppTextStyles.bodyMedium(context),
            ),
            const SizedBox(width: Dimensions.paddingM),
            Text(
              Formatters.currency(item.price),
              style: AppTextStyles.bodyMedium(context),
            ),
            const SizedBox(width: Dimensions.paddingM),
            Text(
              'Total: ${Formatters.currency(item.quantity * item.price)}',
              style: AppTextStyles.price(context),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                item.isFavorite ? Icons.star : Icons.star_border,
                color: item.isFavorite
                    ? Colors.amber
                    : Theme.of(context).iconTheme.color?.withAlpha(153),
              ),
              onPressed: onFavorite,
            ),
            IconButton(
              icon: Icon(
                Icons.edit,
                size: Dimensions.iconM,
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: onEdit,
            ),
          ],
        ),
      ),
    );
  }
}
