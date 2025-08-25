import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/shopping_list.dart';
import '../providers/shopping_list_model.dart';

// ...imports...

class CartPage extends StatelessWidget {
  final ShoppingList list;
  const CartPage({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return Consumer<ShoppingListModel>(
      builder: (_, model, __) {
        final cart = model.cart;
        final totalGasto = cart.fold<double>(
          0.0,
          (sum, item) => sum + (item.price * item.quantity),
        );
        final budget = model.budget;
        final remaining = budget - totalGasto;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Carrinho'),
            centerTitle: true,
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
                          const Icon(Icons.account_balance_wallet, color: Colors.blue),
                          const SizedBox(height: 4),
                          const Text(
                            'Orçamento',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            currency.format(budget),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Icons.shopping_cart_checkout, color: Colors.green[700]),
                          const SizedBox(height: 4),
                          const Text('Gasto',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            currency.format(totalGasto),
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
                          Icon(Icons.account_balance, color: Colors.orange[700]),
                          const SizedBox(height: 4),
                          const Text('Restante',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            currency.format(remaining),
                            style: TextStyle(
                              fontSize: 16,
                              color: remaining >= 0 ? Colors.orange[700] : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: cart.isEmpty
                    ? const Center(child: Text('Nenhum item no carrinho'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(8),
                        itemCount: cart.length + 1, // +1 para o botão
                        separatorBuilder: (_, __) => const SizedBox(height: 4),
                        itemBuilder: (_, i) {
                          if (i == cart.length) {
                            // Botão no final da lista
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.check_circle_outline),
                                  label: const Text('Finalizar compra'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: cart.isEmpty
                                      ? null
                                      : () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                              title: const Text('Finalizar compra'),
                                              content: const Text('Deseja limpar todo o carrinho?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, false),
                                                  child: const Text('Cancelar'),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, true),
                                                  child: const Text('Finalizar'),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            model.clearCart();
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Carrinho limpo com sucesso!'),
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          }
                                        },
                                ),
                              ),
                            );
                          }

                          final item = cart[i];
                          return Dismissible(
                            key: ValueKey(item.name + item.quantity.toString()),
                            background: Container(
                              color: Colors.orange,
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 24),
                              child: const Icon(Icons.undo, color: Colors.white, size: 32),
                            ),
                            secondaryBackground: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 24),
                              child: const Icon(Icons.delete, color: Colors.white, size: 32),
                            ),
                            confirmDismiss: (direction) async {
                              if (direction == DismissDirection.startToEnd) {
                                model.togglePurchased(item);
                                return false;
                              } else if (direction == DismissDirection.endToStart) {
                                model.remove(item);
                                return true;
                              }
                              return false;
                            },
                            child: Card(
                              child: ListTile(
                                visualDensity: const VisualDensity(vertical: -4),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                tileColor: Theme.of(context).colorScheme.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                title: Text(
                                  item.name,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                subtitle: Row(
                                  children: [
                                    Text(
                                      'Qtd: ${item.quantity}',
                                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'R\$ ${item.price.toStringAsFixed(2)}',
                                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Total: R\$ ${(item.quantity * item.price).toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    item.isFavorite ? Icons.star : Icons.star_border,
                                    color: item.isFavorite
                                        ? Colors.amber
                                        : Theme.of(context).iconTheme.color?.withOpacity(0.6),
                                  ),
                                  onPressed: () {
                                    Provider.of<ShoppingListModel>(context, listen: false)
                                        .toggleFavorite(item);
                                  },
                                ),
                              ),
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
}
