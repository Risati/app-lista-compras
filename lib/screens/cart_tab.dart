import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/dimensions.dart';
import '../core/constants/strings.dart';
import '../core/theme/colors.dart';
import '../core/utils/formatters.dart';
import '../models/shopping_list.dart';
import '../providers/lists_provider.dart';
import '../widgets/cards/shopping_item_card.dart';
import '../widgets/dialogs/confirm_dialog.dart';
import '../models/grocery_item.dart';
import '../widgets/buttons/primary_button.dart';
import '../core/theme/text_styles.dart';

class CartPage extends StatelessWidget {
  final ShoppingList list;
  const CartPage({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    return Consumer<ListsProvider>(
      builder: (_, provider, __) {
        final cart = provider.getCartItems(list);
        final totalGasto = provider.getListPurchasedTotal(list);
        final budget = provider.getBudget();
        final remaining = budget - totalGasto;

        return Scaffold(
          appBar: AppBar(
            title: const Text(Strings.titleCart),
            centerTitle: true,
          ),
          body: Column(
            children: [
              _buildSummaryCard(context, budget, totalGasto, remaining),
              Expanded(
                child: cart.isEmpty
                    ? const Center(child: Text(Strings.msgEmptyCart))
                    : _buildCartList(context, provider, cart),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(
      BuildContext context, budget, double totalGasto, double remaining) {
    return Card(
      margin: const EdgeInsets.all(Dimensions.paddingM),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusL),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingL),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                const Icon(Icons.account_balance_wallet, color: Colors.blue),
                const SizedBox(height: Dimensions.paddingXS),
                Text(
                  Strings.labelBudget,
                  style: AppTextStyles.bodyMedium(context)
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  Formatters.currency(budget),
                  style: AppTextStyles.bodyLarge(context)
                      .copyWith(fontSize: 16, fontWeight: FontWeight.normal),
                ),
              ],
            ),
            Column(
              children: [
                const Icon(Icons.shopping_cart_checkout,
                    color: AppColors.success),
                const SizedBox(height: Dimensions.paddingXS),
                Text(
                  Strings.labelSpent,
                  style: AppTextStyles.bodyMedium(context)
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  Formatters.currency(totalGasto),
                  style: AppTextStyles.bodyLarge(context).copyWith(
                    fontSize: 16,
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                const Icon(Icons.account_balance, color: AppColors.warning),
                const SizedBox(height: Dimensions.paddingXS),
                Text(
                  Strings.labelRemaining,
                  style: AppTextStyles.bodyMedium(context)
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  Formatters.currency(remaining),
                  style: AppTextStyles.bodyLarge(context).copyWith(
                    fontSize: 16,
                    color: remaining >= 0 ? AppColors.warning : AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartList(
    BuildContext context,
    ListsProvider provider,
    List<GroceryItem> cart,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.all(Dimensions.paddingM),
      itemCount: cart.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: Dimensions.paddingXS),
      itemBuilder: (_, i) {
        if (i == cart.length) {
          return !list.isCompleted
              ? _buildFinishButton(context, provider, cart)
              : const SizedBox();
        }

        final item = cart[i];
        return Dismissible(
          key: ValueKey('${item.name}_${item.quantity}'),
          background: _buildDismissBackground(
            color: AppColors.warning,
            icon: Icons.undo,
            alignment: Alignment.centerLeft,
          ),
          secondaryBackground: _buildDismissBackground(
            color: AppColors.error,
            icon: Icons.delete,
            alignment: Alignment.centerRight,
          ),
          confirmDismiss: (direction) =>
              _handleDismiss(direction, item, provider),
          child: ShoppingItemCard(
            item: item,
            onEdit: () => _showEditItemDialog(context, provider, item),
            onEditName: () => _showEditNameDialog(context, provider, item),
            onFavorite: () => provider.toggleFavorite(item),
          ),
        );
      },
    );
  }

  Widget _buildFinishButton(
    BuildContext context,
    ListsProvider provider,
    List<GroceryItem> cart,
  ) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingL),
      child: SizedBox(
          width: double.infinity,
          child: PrimaryButton(
            text: Strings.btnFinishList,
            icon: Icons.check_circle_outline,
            onPressed:
                cart.isEmpty ? null : () => _finishList(context, provider),
            backgroundColor: AppColors.success,
            fullWidth: true,
          )),
    );
  }

  Widget _buildDismissBackground({
    required Color color,
    required IconData icon,
    required Alignment alignment,
  }) {
    return Container(
      color: color,
      alignment: alignment,
      padding: EdgeInsets.only(
        left: alignment == Alignment.centerLeft ? Dimensions.paddingXL : 0,
        right: alignment == Alignment.centerRight ? Dimensions.paddingXL : 0,
      ),
      child: Icon(
        icon,
        color: AppColors.textLight,
        size: Dimensions.iconXL,
      ),
    );
  }

  Future<bool> _handleDismiss(
    DismissDirection direction,
    GroceryItem item,
    ListsProvider provider,
  ) async {
    if (direction == DismissDirection.startToEnd) {
      provider.togglePurchased(item);
      return false;
    } else if (direction == DismissDirection.endToStart) {
      provider.remove(item);
      return true;
    }
    return false;
  }

  Future<void> _finishList(BuildContext context, ListsProvider provider) async {
    final confirm = await ConfirmDialog.show(
      context: context,
      title: Strings.dialogFinishList,
      message: Strings.dialogConfirmFinish,
      confirmText: Strings.btnFinish,
      cancelText: Strings.btnNotYet,
      confirmColor: AppColors.success,
    );

    if (confirm == true) {
      provider.completeList(list);
      if (!context.mounted) return;
      Navigator.of(context).pop();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(Strings.msgListCompleted),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showEditItemDialog(
    BuildContext context,
    ListsProvider provider,
    GroceryItem item,
  ) {
    final qtyCtrl = TextEditingController(text: item.quantity.toString());
    final priceCtrl = TextEditingController(
      text: Formatters.currency(item.price),
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(Strings.dialogEditItem),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qtyCtrl,
              decoration:
                  const InputDecoration(labelText: Strings.labelQuantity),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: Dimensions.paddingM),
            TextField(
              controller: priceCtrl,
              decoration: const InputDecoration(labelText: Strings.labelPrice),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(Strings.btnCancel),
          ),
          TextButton(
            onPressed: () {
              final quantity = int.tryParse(qtyCtrl.text) ?? item.quantity;
              final price = double.tryParse(
                    priceCtrl.text.replaceAll(RegExp(r'[^0-9,.]'), ''),
                  ) ??
                  item.price;
              provider.updateItem(list, item, quantity: quantity, price: price);
              Navigator.pop(context);
            },
            child: const Text(Strings.btnSave),
          ),
        ],
      ),
    );
  }

  void _showEditNameDialog(
    BuildContext context,
    ListsProvider provider,
    GroceryItem item,
  ) {
    final ctrl = TextEditingController(text: item.name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(Strings.dialogEditName),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: Strings.labelName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(Strings.btnCancel),
          ),
          TextButton(
            onPressed: () {
              final newName = ctrl.text.trim();
              if (newName.isNotEmpty) {
                provider.updateItem(list, item, name: newName);
              }
              Navigator.pop(context);
            },
            child: const Text(Strings.btnSave),
          ),
        ],
      ),
    );
  }
}
