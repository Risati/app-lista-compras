import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme.dart';
import '../providers/shopping_list_model.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<ShoppingListModel>(
      builder: (_, model, __) => Scaffold(
        appBar: AppBar(
          title: const Text('Lembra AÍ'),
          centerTitle: true,
          elevation: 0,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildRow('Total gasto:', model.total),
                  const SizedBox(height: 8),
                  _buildRow('Orçamento:', model.budget),
                  const SizedBox(height: 8),
                  _buildRow(
                    'Restante:',
                    model.remaining,
                    valueColor:
                        model.remaining < 0 ? Colors.red : Colors.green,
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
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 4),
                      itemBuilder: (_, i) {
                        final item = model.cart[i];
                        return Card(
                          child: ListTile(
                            title: Text(item.name),
                            subtitle: Text(
                                'Qtd: ${item.quantity} • R\$${item.price.toStringAsFixed(2)}'),
                            trailing: IconButton(
                              icon: const Icon(
                                  Icons.remove_shopping_cart_rounded),
                              onPressed: () =>
                                  model.togglePurchased(item),
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
      {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          'R\$${value.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}