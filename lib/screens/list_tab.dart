import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/shopping_provider.dart';
import '../theme.dart';  // necessário para acessar primaryColor

class ListTab extends StatelessWidget {
  const ListTab({super.key}); // ✅ já está const

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ShoppingProvider>();
    final items = prov.availableItems;

    if (items.isEmpty) {
      return const Center(child: Text('Nenhum item'));
    }

    // Agrupar por categoria
    final Map<String, List> grouped = {};
    for (var item in items) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }

    return Column(
      children: [
        // Quick-add bar
        const Padding(
          padding: EdgeInsets.all(16),
          child: _QuickAddBar(),
        ),
        Expanded(
          child: ListView(
            children: [
              for (var entry in grouped.entries) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    entry.key,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: primaryColor),
                  ),
                ),
                for (var item in entry.value)
                  Card(
                    child: ListTile(
                      title: Text(item.name),
                      subtitle: Text('Qtd: ${item.quantity}'),
                      onTap: () {
                        prov.togglePurchased(item);
                        DefaultTabController.of(context)?.animateTo(1);
                      },
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickAddBar extends StatefulWidget {
  const _QuickAddBar({super.key}); // ✅ também const

  @override
  State<_QuickAddBar> createState() => _QuickAddBarState();
}

class _QuickAddBarState extends State<_QuickAddBar> {
  final _nameCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '1');

  @override
  Widget build(BuildContext context) {
    final prov = context.read<ShoppingProvider>();
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              hintText: 'Nome do produto',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _addItem(prov),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: TextField(
            controller: _qtyCtrl,
            decoration: const InputDecoration(
              hintText: 'Qtd',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onSubmitted: (_) => _addItem(prov),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => _addItem(prov),
          child: const Icon(Icons.add),
        ),
      ],
    );
  }

  void _addItem(ShoppingProvider prov) {
    final name = _nameCtrl.text.trim();
    final qty = int.tryParse(_qtyCtrl.text) ?? 1;
    if (name.isEmpty) return;

    prov.addItem(name, qty);
    _nameCtrl.clear();
    _qtyCtrl.text = '1';
    FocusScope.of(context).unfocus();
  }
}