import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/shopping_list_model.dart';
import '../models/grocery_item.dart';
import 'barcode_scanner_page.dart';

class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({super.key});
  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  final _nameCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '1');
  String _searchQuery = '';
  bool _showSearch = false;
  final _searchCtrl = TextEditingController();
  final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  Widget build(BuildContext context) {
    return Consumer<ShoppingListModel>(
      builder: (_, model, __) {
        final total = model.items.fold<double>(
          0.0,
          (sum, item) => sum + (item.price * item.quantity),
        );
        final totalGasto = model.items
            .where((item) => item.purchased)
            .fold<double>(
                0.0, (sum, item) => sum + (item.price * item.quantity));
        final itensRestantes =
            model.items.where((item) => !item.purchased).length;

        final filtered = model.available
            .where((item) =>
                item.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Lembra AÍ'),
            centerTitle: true,
            actions: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _showSearch ? 220 : 48,
                child: Row(
                  children: [
                    if (_showSearch)
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          autofocus: true,
                          decoration: const InputDecoration(
                            hintText: 'Buscar...',
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                          ),
                          onChanged: (query) {
                            setState(() => _searchQuery = query);
                          },
                        ),
                      ),
                    IconButton(
                      icon: Icon(_showSearch ? Icons.close : Icons.search),
                      onPressed: () {
                        setState(() {
                          if (_showSearch) {
                            _searchQuery = '';
                            _searchCtrl.clear();
                          }
                          _showSearch = !_showSearch;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        model.isAsc
                            ? Icons.sort_by_alpha
                            : Icons.sort_by_alpha_outlined,
                        color: Colors.white,
                      ),
                      onPressed: model.toggleSort,
                    ),
                    const Spacer(),
                    Text(
                      'Orçamento: ${currency.format(model.budget)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () => _showBudgetDialog(context, model),
                    ),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            tooltip: 'Escanear código de barras',
            heroTag: 'scan_fab',
            child: const Icon(Icons.qr_code_scanner),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BarcodeScannerPage()),
            ),
          ),
          body: Column(
            children: [
              Card(
                margin: const EdgeInsets.all(12),
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Icon(Icons.shopping_cart, color: Colors.blue),
                          const SizedBox(height: 4),
                          const Text(
                            'Total',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'R\$ ${total.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[700]),
                          const SizedBox(height: 4),
                          const Text('Gasto',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            'R\$ ${totalGasto.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Icons.pending_actions,
                              color: Colors.orange[700]),
                          const SizedBox(height: 4),
                          const Text('Restantes',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            '$itensRestantes',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.orange[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: TextField(
                        controller: _nameCtrl,
                        decoration: InputDecoration(
                          hintText: 'Produto',
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                        onSubmitted: (_) => _add(model),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 60,
                      child: TextField(
                        controller: _qtyCtrl,
                        decoration: InputDecoration(
                          hintText: 'Qtd',
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onSubmitted: (_) => _add(model),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: () => _add(model),
                        child: const Icon(Icons.add,
                            color: Colors.white, size: 24),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemBuilder: (_, i) {
                    final item = filtered[i];
                    final qtyCtrl =
                        TextEditingController(text: item.quantity.toString());
                    final priceCtrl = TextEditingController(
                        text: item.price.toStringAsFixed(2));
                    bool editing = false;

                    return StatefulBuilder(
                      builder: (context, setState) {
                        return Card(
                          color:
                              item.purchased ? Colors.green[50] : Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: Checkbox(
                              value: item.purchased,
                              onChanged: (_) => model.togglePurchased(item),
                              activeColor: Colors.green,
                            ),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () =>
                                      _showEditNameDialog(context, model, item),
                                  child: Text(
                                    item.name,
                                    style: TextStyle(
                                      decoration: item.purchased
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: item.purchased
                                          ? Colors.grey
                                          : Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                !editing
                                    ? GestureDetector(
                                        onTap: () =>
                                            setState(() => editing = true),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text('Qtd: ${item.quantity}'),
                                              const SizedBox(width: 8),
                                              Text(currency.format(item.price)),
                                              const SizedBox(width: 8),
                                              Text(currency.format(
                                                  item.quantity * item.price)),
                                              const SizedBox(width: 4),
                                              const Icon(Icons.edit,
                                                  size: 16, color: Colors.grey),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 50,
                                            child: TextField(
                                              controller: qtyCtrl,
                                              autofocus: true,
                                              decoration: const InputDecoration(
                                                isDense: true,
                                                contentPadding:
                                                    EdgeInsets.all(8),
                                                border: OutlineInputBorder(),
                                                labelText: 'Qtd',
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly
                                              ],
                                              onSubmitted: (val) {
                                                final q = int.tryParse(val) ??
                                                    item.quantity;
                                                model.updateItem(item, qty: q);
                                                setState(() => editing = false);
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          SizedBox(
                                            width: 80,
                                            child: TextField(
                                              controller: priceCtrl,
                                              decoration: const InputDecoration(
                                                isDense: true,
                                                contentPadding:
                                                    EdgeInsets.all(8),
                                                border: OutlineInputBorder(),
                                                labelText: 'R\$',
                                              ),
                                              keyboardType: const TextInputType
                                                  .numberWithOptions(
                                                  decimal: true),
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .allow(RegExp(
                                                        r'^\d+\.?\d{0,2}$')),
                                              ],
                                              onSubmitted: (val) {
                                                final p = double.tryParse(
                                                        val.replaceAll(
                                                            ',', '.')) ??
                                                    item.price;
                                                model.updateItem(item,
                                                    price: p);
                                                setState(() => editing = false);
                                              },
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.check,
                                                color: Colors.green),
                                            onPressed: () {
                                              final q =
                                                  int.tryParse(qtyCtrl.text) ??
                                                      item.quantity;
                                              final p = double.tryParse(
                                                      priceCtrl.text.replaceAll(
                                                          ',', '.')) ??
                                                  item.price;
                                              model.updateItem(item,
                                                  qty: q, price: p);
                                              setState(() => editing = false);
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.close,
                                                color: Colors.red),
                                            onPressed: () =>
                                                setState(() => editing = false),
                                          ),
                                        ],
                                      ),
                              ],
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.redAccent),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Remover item'),
                                    content: Text(
                                        'Deseja remover "${item.name}" da lista?'),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancelar')),
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Remover')),
                                    ],
                                  ),
                                );
                                if (confirm == true) model.remove(item);
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _add(ShoppingListModel model) {
    final name = _nameCtrl.text.trim();
    final qty = int.tryParse(_qtyCtrl.text) ?? 1;
    if (name.isEmpty) return;
    model.addQuick(name, qty);
    _nameCtrl.clear();
    _qtyCtrl.text = '1';
  }

  void _showBudgetDialog(BuildContext context, ShoppingListModel model) {
    final ctrl = TextEditingController(text: model.budget.toStringAsFixed(2));
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ajustar Orçamento'),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+[.,]?\d{0,2}$')),
          ],
          decoration: const InputDecoration(labelText: 'Valor (R\$)'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              final v = double.tryParse(ctrl.text.replaceAll(',', '.')) ?? 0.0;
              model.updateBudget(v);
              Navigator.of(context).pop();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showEditNameDialog(
      BuildContext context, ShoppingListModel model, GroceryItem item) {
    final ctrl = TextEditingController(text: item.name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar Nome'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Nome'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              final newName = ctrl.text.trim();
              if (newName.isNotEmpty) {
                model.updateItem(item, name: newName);
              }
              Navigator.of(context).pop();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}
