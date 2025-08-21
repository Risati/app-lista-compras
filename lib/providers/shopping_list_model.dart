import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/grocery_item.dart';

class ShoppingListModel extends ChangeNotifier {
  late Box<GroceryItem> _box;
  late Box _settings;

  List<GroceryItem> items = [];
  double budget = 0.0;
  bool isAsc = true;

  Future<void> loadData() async {
    _box = Hive.box<GroceryItem>('grocery_box');
    _settings = Hive.box('settings');
    items = _box.values.toList();
    budget = _settings.get('budget', defaultValue: 0.0) as double;
    _sort();
    notifyListeners();
  }

  List<GroceryItem> get available => items.where((i) => !i.purchased).toList();

  List<GroceryItem> get cart => items.where((i) => i.purchased).toList();

  double get total => cart.fold(0.0, (sum, i) => sum + i.price * i.quantity);

  double get remaining => budget - total;

  void addQuick(String name, int qty) {
    final item = GroceryItem(name: name, quantity: qty);
    _box.add(item);
    items.add(item);
    _sort();
    notifyListeners();
  }

  void togglePurchased(GroceryItem item) {
    item.purchased = !item.purchased;
    item.save();
    notifyListeners();
  }

  void updateItem(
    GroceryItem item, {
    String? name,
    int? qty,
    double? price,
  }) {
    if (name != null) item.name = name;
    if (qty != null) item.quantity = qty;
    if (price != null) item.price = price;
    item.save();
    notifyListeners();
  }

  void updateBudget(double value) {
    budget = value;
    _settings.put('budget', value);
    notifyListeners();
  }

  void clearCart() {
    for (var i in cart) {
      i.purchased = false;
      i.save();
    }
    notifyListeners();
  }

  void toggleSort() {
    isAsc = !isAsc;
    _sort();
    notifyListeners();
  }

  void remove(GroceryItem item) {
    items.remove(item);
    item.delete(); // Remove do Hive também
    notifyListeners();
  }

  void _sort() {
    items.sort(
        (a, b) => isAsc ? a.name.compareTo(b.name) : b.name.compareTo(a.name));
  }
}
