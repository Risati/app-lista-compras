import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../core/constants/strings.dart';
import '../core/constants/dimensions.dart';
import '../core/utils/formatters.dart';
import '../models/shopping_list.dart';
import '../models/grocery_item.dart';
import '../providers/lists_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/cards/shopping_info_card.dart';
import '../widgets/cards/shopping_item_card.dart';
import '../widgets/inputs/search_field.dart';
import '../widgets/inputs/currency_field.dart';
import '../widgets/dialogs/confirm_dialog.dart';
import 'barcode_scanner_page.dart';
import '../core/theme/text_styles.dart';
import '../core/theme/colors.dart';

class ShoppingListPage extends StatefulWidget {
  final ShoppingList list;
  const ShoppingListPage({super.key, required this.list});

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  final _nameCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '1');
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  bool _showSearch = false;

  @override
  Widget build(BuildContext context) {
    final listsProvider = Provider.of<ListsProvider>(context);
    final isAscending = listsProvider.isListAscending(widget.list);
    final budget = listsProvider.getListBudget(widget.list);
    final total = listsProvider.getListTotal(widget.list);
    final totalGasto = listsProvider.getListPurchasedTotal(widget.list);
    final itensRestantes = listsProvider.getRemainingItems(widget.list);
    final filtered = listsProvider
        .getAvailableItems(widget.list)
        .where((item) =>
            item.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: _buildAppBar(context, listsProvider, isAscending, budget),
      floatingActionButton: FloatingActionButton(
        tooltip: Strings.tooltipScanBarcode,
        heroTag: 'scan_fab',
        child: const Icon(Icons.qr_code_scanner),
        onPressed: () => _openBarcodeScanner(context, listsProvider),
      ),
      body: Column(
        children: [
          ShoppingInfoCard(
            total: total,
            spent: totalGasto,
            remaining: itensRestantes,
          ),
          _buildAddItemRow(listsProvider),
          Expanded(
            child: _buildItemsList(filtered, listsProvider),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context,
      ListsProvider provider,
      bool isAscending,
      double budget,
      ) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            Strings.appName,
            style: AppTextStyles.titleSmall(context)
                .copyWith(color: Theme.of(context).colorScheme.onPrimary),
          ),
          Text(
            Strings.appSubtitle,
            style: AppTextStyles.titleSmall(context)
                .copyWith(color: Theme.of(context).colorScheme.onPrimary),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            Theme.of(context).brightness == Brightness.dark
                ? Icons.light_mode
                : Icons.dark_mode,
          ),
          tooltip: Strings.tooltipToggleTheme,
          onPressed: () {
            Provider.of<ThemeProvider>(context, listen: false).toggleMode();
          },
        ),
        if (provider.isListComplete(widget.list))
          IconButton(
            icon: const Icon(Icons.task_alt),
            tooltip: Strings.tooltipFinishList,
            onPressed: () => _showFinishListDialog(context, provider),
          ),
        SearchField(
          controller: _searchCtrl,
          isVisible: _showSearch,
          onChanged: (query) => setState(() => _searchQuery = query),
          onClear: () {
            setState(() {
              if (_showSearch) {
                _searchQuery = '';
                _searchCtrl.clear();
              }
              _showSearch = !_showSearch;
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.share),
          tooltip: 'Compartilhar lista',
          onPressed: () => _shareList(widget.list),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingL,
            vertical: Dimensions.paddingS,
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  isAscending
                      ? Icons.sort_by_alpha
                      : Icons.sort_by_alpha_outlined,
                      color: Theme.of(context).colorScheme.onPrimary,
                ),
                tooltip: Strings.tooltipSortList,
                onPressed: () => provider.toggleListSort(widget.list),
              ),
              Expanded(
                child: _buildBudgetButton(context, provider, budget),
              ),
              const SizedBox(width: Dimensions.paddingS),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetButton(
      BuildContext context,
      ListsProvider provider,
      double budget,
      ) {
    return GestureDetector(
      onTap: () => _showBudgetDialog(context, provider),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingL,
          vertical: Dimensions.paddingXS,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white10
              : Colors.blueAccent.withAlpha(178),
          borderRadius: BorderRadius.circular(Dimensions.radiusL),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center, // Centraliza o conteúdo
          children: [
            Icon(
              Icons.account_balance_wallet,
              size: Dimensions.iconS,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.white,
            ),
            const SizedBox(width: Dimensions.paddingXS),
            Flexible(
              child: Text(
                '${Strings.labelBudget}: ${Formatters.currency(budget)}',
                style: AppTextStyles.bodyLarge(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center, // Garante centralização do texto
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddItemRow(ListsProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingL),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                hintText: Strings.labelProduct,
              ),
              onSubmitted: (_) => _add(provider),
            ),
          ),
          const SizedBox(width: Dimensions.paddingS),
          SizedBox(
            width: 60,
            child: TextField(
              controller: _qtyCtrl,
              decoration: const InputDecoration(
                hintText: Strings.labelQuantity,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onSubmitted: (_) => _add(provider),
            ),
          ),
          const SizedBox(width: Dimensions.paddingS),
          SizedBox(
            width: Dimensions.buttonHeight,
            height: Dimensions.buttonHeight,
            child: ElevatedButton(
              onPressed: () => _add(provider),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(List<GroceryItem> items, ListsProvider provider) {
    return ListView.separated(
      padding: const EdgeInsets.all(Dimensions.paddingS),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: Dimensions.paddingXS),
      itemBuilder: (_, i) {
        final item = items[i];
        return Dismissible(
          key: ValueKey('${item.name}_${item.quantity}'),
          background: buildDismissBackground(
            color: AppColors.warning,
            icon: Icons.undo,
            alignment: Alignment.centerLeft,
          ),
          secondaryBackground: buildDismissBackground(
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

  Widget buildDismissBackground({
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
      provider.toggleItemPurchased(widget.list, item);
      return false;
    } else if (direction == DismissDirection.endToStart) {
      provider.removeItemFromList(widget.list, item);
      return true;
    }
    return false;
  }

  void _add(ListsProvider provider) {
    FocusScope.of(context).unfocus();
    final name = _nameCtrl.text.trim();
    final qty = int.tryParse(_qtyCtrl.text) ?? 1;
    if (name.isEmpty) return;

    provider.addItemToList(widget.list, name, qty);
    _nameCtrl.clear();
    _qtyCtrl.text = '1';
  }

  void _openBarcodeScanner(BuildContext context, ListsProvider provider) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BarcodeScannerPage(
          list: widget.list,
          model: provider,
        ),
      ),
    );
  }

  Future<void> _showFinishListDialog(
      BuildContext context, ListsProvider provider) async {
    final confirm = await ConfirmDialog.show(
      context: context,
      title: Strings.dialogFinishList,
      message: Strings.dialogConfirmFinish,
      confirmText: Strings.btnFinish,
      cancelText: Strings.btnNotYet,
      confirmColor: Colors.green,
    );

    if (confirm == true) {
      await provider.completeList(widget.list);
      if (!context.mounted) return;
      Navigator.of(context).pop();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(Strings.msgListCompleted),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showBudgetDialog(BuildContext context, ListsProvider provider) {
    final ctrl = TextEditingController(
      text: Formatters.currency(provider.getListBudget(widget.list)),
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(Strings.dialogAdjustBudget),
        content: CurrencyField(controller: ctrl),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(Strings.btnCancel),
          ),
          TextButton(
            onPressed: () {
              final digits = ctrl.text.replaceAll(RegExp(r'[^0-9]'), '');
              final value = digits.isEmpty ? 0.0 : int.parse(digits) / 100.0;
              provider.updateListBudget(widget.list, value);
              Navigator.of(context).pop();
            },
            child: const Text(Strings.btnSave),
          ),
        ],
      ),
    );
  }

  void _showEditItemDialog(
      BuildContext context, ListsProvider provider, GroceryItem item) {
    final qtyCtrl = TextEditingController(text: item.quantity.toString());
    final priceCtrl =
        TextEditingController(text: Formatters.currency(item.price));

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(Strings.dialogEditItem),
        content: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: Dimensions.paddingS,
              horizontal: Dimensions.paddingXS,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: qtyCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: Strings.labelQuantity,
                    isDense: true,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingM),
                CurrencyField(
                  controller: priceCtrl,
                  labelText: Strings.labelPrice,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(Strings.btnCancel),
          ),
          TextButton(
            onPressed: () {
              final quantity = int.tryParse(qtyCtrl.text) ?? item.quantity;
              final digits = priceCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
              final price = digits.isEmpty ? 0.0 : int.parse(digits) / 100.0;
              provider.updateItem(widget.list, item,
                  quantity: quantity, price: price);
              Navigator.of(context).pop();
            },
            child: const Text(Strings.btnSave),
          ),
        ],
      ),
    );
  }

  void _showEditNameDialog(
      BuildContext context, ListsProvider provider, GroceryItem item) {
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
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(Strings.btnCancel),
          ),
          TextButton(
            onPressed: () {
              final newName = ctrl.text.trim();
              if (newName.isNotEmpty) {
                provider.updateItem(widget.list, item, name: newName);
              }
              Navigator.of(context).pop();
            },
            child: const Text(Strings.btnSave),
          ),
        ],
      ),
    );
  }

  void _shareList(ShoppingList list) {
    final itemsText = list.items.isEmpty
        ? 'Nenhum item na lista.'
        : list.items.map((item) => '- ${item.name} (${item.quantity})').join('\n');
    final text = 'Lista "${list.name}":\n$itemsText';
    Share.share(text);
  }
}
