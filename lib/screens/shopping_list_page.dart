import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../theme.dart';
import '../providers/shopping_list_model.dart';
import '../models/grocery_item.dart';

class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({super.key});
  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  final _nameCtrl = TextEditingController();
  final _qtyCtrl  = TextEditingController(text: '1');

  @override
  Widget build(BuildContext context) {
    return Consumer<ShoppingListModel>(
      builder: (_, model, __) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Lembra AÍ'),
            centerTitle: true,
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
                      'Orçamento: R\$${model.budget.toStringAsFixed(2)}',
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
          body: Column(
            children: [
              // Quick-add
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: TextField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Produto',
                        ),
                        onSubmitted: (_) => _add(model),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 60,
                      child: TextField(
                        controller: _qtyCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Qtd',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onSubmitted: (_) => _add(model),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Botão apenas ícone, mesmo tamanho
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => _add(model),
                        child: const Icon(Icons.add, color: Colors.white, size: 24),
                      ),
                    ),
                  ],
                ),
              ),

              // Lista compacta
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: model.available.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 4),
                  itemBuilder: (_, i) {
                    final item = model.available[i];
                    return ListTile(
                      visualDensity:
                          const VisualDensity(vertical: -4),
                      contentPadding:
                          const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                      tileColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      title: GestureDetector(
                        onTap: () =>
                            _showEditNameDialog(context, model, item),
                        child: Text(item.name),
                      ),
                      subtitle: Row(
                        children: [
                          // Quantidade editável
                          SizedBox(
                            width: 50,
                            child: TextField(
                              controller: TextEditingController(
                                  text: item.quantity.toString()),
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.all(8),
                              ),
                              keyboardType:
                                  TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter
                                    .digitsOnly
                              ],
                              onSubmitted: (val) {
                                final q =
                                    int.tryParse(val) ??
                                        item.quantity;
                                model.updateItem(item, qty: q);
                              },
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Preço editável
                          SizedBox(
                            width: 80,
                            child: TextField(
                              controller: TextEditingController(
                                  text:
                                      item.price.toStringAsFixed(2)),
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.all(8),
                              ),
                              keyboardType:
                                  const TextInputType
                                      .numberWithOptions(
                                          decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,2}$'),
                                )
                              ],
                              onSubmitted: (val) {
                                final p = double.tryParse(val) ??
                                    item.price;
                                model.updateItem(item, price: p);
                              },
                            ),
                          ),

                          const Spacer(),

                          // Valor total
                          Text(
                            'R\$${(item.quantity * item.price).toStringAsFixed(2)}',
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.add_shopping_cart_outlined,
                        ),
                        onPressed: () =>
                            model.togglePurchased(item),
                      ),
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

  void _showBudgetDialog(
      BuildContext context, ShoppingListModel model) {
    final ctrl = TextEditingController(
        text: model.budget.toStringAsFixed(2));
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ajustar Orçamento'),
        content: TextField(
          controller: ctrl,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(
                RegExp(r'^\d+\.?\d{0,2}$')),
          ],
          decoration: const InputDecoration(labelText: 'Valor (R\$)'),
        ),
        actions: [
          TextButton(
              onPressed: Navigator.of(context).pop,
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              final v = double.tryParse(ctrl.text) ?? 0.0;
              model.updateBudget(v);
              Navigator.of(context).pop();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showEditNameDialog(BuildContext context,
      ShoppingListModel model, GroceryItem item) {
    final ctrl = TextEditingController(text: item.name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar Nome do Item'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Nome'),
        ),
        actions: [
          TextButton(
              onPressed: Navigator.of(context).pop,
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