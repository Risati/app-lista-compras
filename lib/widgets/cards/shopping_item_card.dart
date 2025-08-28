import 'package:flutter/material.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../models/grocery_item.dart';
import '../../services/category_service.dart';

class ShoppingItemCard extends StatelessWidget {
  final GroceryItem item;
  final String categoria;
  final Color corCategoria;
  final VoidCallback? onEdit;
  final VoidCallback? onEditName;
  final VoidCallback? onFavorite;

  const ShoppingItemCard({
    Key? key,
    required this.item,
    required this.categoria,
    required this.corCategoria,
    this.onEdit,
    this.onEditName,
    this.onFavorite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        visualDensity: const VisualDensity(vertical: -4),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingS, // Reduzido
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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start, // Permite quebra
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
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: corCategoria,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    categoria,
                    style: TextStyle(
                      fontSize: 12,
                      color: corCategoria,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Wrap(
          spacing: 0,
          alignment: WrapAlignment.center,
          children: [
            IconButton(
              iconSize: 20, // menor
              icon: Icon(
                item.isFavorite ? Icons.star : Icons.star_border,
                color: item.isFavorite
                    ? Colors.amber
                    : Theme.of(context).iconTheme.color?.withAlpha(153),
              ),
              onPressed: onFavorite,
            ),
            IconButton(
              iconSize: 20, // menor
              icon: Icon(
                Icons.edit,
                size: 20,
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
