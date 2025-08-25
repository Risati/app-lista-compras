import 'package:intl/intl.dart';
import 'shopping_list.dart';

class ShoppingListReport {
  final ShoppingList list;
  final DateTime date;
  final double totalCost;
  final int totalItems;
  final int purchasedItems;

  ShoppingListReport({
    required this.list,
    required this.date,
    required this.totalCost,
    required this.totalItems,
    required this.purchasedItems,
  });

  factory ShoppingListReport.fromShoppingList(ShoppingList list) {
    double total = 0;
    int purchased = 0;

    for (var item in list.items) {
      if (item.purchased) {
        total += item.price * item.quantity;
        purchased++;
      }
    }

    return ShoppingListReport(
      list: list,
      date: DateTime.now(),
      totalCost: total,
      totalItems: list.items.length,
      purchasedItems: purchased,
    );
  }

  String get formattedDate => DateFormat('dd/MM/yyyy HH:mm').format(date);
  double get completionRate => (purchasedItems / totalItems) * 100;
}
