import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/shopping_list_model.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});
  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return Consumer<ShoppingListModel>(
      builder: (_, model, __) => Scaffold(
        appBar: AppBar(
          title: const Text('Lembra AÍ'),
          centerTitle: true,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.white),
              tooltip: 'Limpar carrinho',
              onPressed: () {
                model.clearCart();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Carrinho limpo!')),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildRow('Total gasto:', model.total, currency: currency),
                  const SizedBox(height: 8),
                  _buildRow('Orçamento:', model.budget, currency: currency),
                  const SizedBox(height: 8),
                  _buildRow(
                    'Restante:',
                    model.remaining,
                    valueColor: model.remaining < 0 ? Colors.red : Colors.green,
                    currency: currency,
                  ),
                ],
              ),
            ),
            Expanded(
              child: model.cart.isEmpty
                  ? const Center(child: Text('Carrinho vazio'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(8),
                      itemCount: model.cart.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 4),
                      itemBuilder: (_, i) {
                        final item = model.cart[i];
                        return Card(
                          child: ListTile(
                            title: Text(item.name),
                            subtitle: Text(
                                'Qtd: ${item.quantity} • ${currency.format(item.price)}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_shopping_cart_rounded),
                                  tooltip: 'Retirar do carrinho',
                                  onPressed: () => model.togglePurchased(item),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  tooltip: 'Excluir item',
                                  onPressed: () {
                                    model.remove(item);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Item removido do carrinho!')),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, double value,
      {Color? valueColor, required NumberFormat currency}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          currency.format(value),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}