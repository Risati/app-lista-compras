import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/item.dart';
import '../services/ai_service.dart';

class ShoppingProvider extends ChangeNotifier {
  static const _boxName    = 'items';
  static const _budgetKey  = 'budget';

  late Box<Item> _box;
  late Box _settingsBox;

  List<Item> _items = [];
  double budget      = 0.0;
  bool _ascending    = true;

  ShoppingProvider() {
    _init();
  }

  Future<void> _init() async {
    _box = Hive.box<Item>(_boxName);
    _settingsBox = Hive.box('settings');
    budget = _settingsBox.get(_budgetKey, defaultValue: 0.0) as double;
    _items = _box.values.toList();
    await _categorizeAll();
    notifyListeners();
  }

  Future<void> _categorizeAll() async {
    for (var item in _items) {
      if (item.category == 'Sem categoria') {
        item.category = await AIService.categorize(item.name);
        item.save();
      }
    }
  }

  List<Item> get availableItems =>
      _sorted(_items.where((i) => !i.purchased));

  List<Item> get cartItems =>
      _sorted(_items.where((i) => i.purchased));

  double get totalCost =>
      cartItems.fold(0.0, (sum, i) => sum + i.price * i.quantity);

  double get remaining => budget - totalCost;

  void addItem(String name, int quantity) async {
    final item = Item(name: name, quantity: quantity);
    item.category = await AIService.categorize(name);
    await _box.add(item);
    _items.add(item);
    notifyListeners();
  }

  void togglePurchased(Item item) {
    item.purchased = !item.purchased;
    item.save();
    notifyListeners();
  }

  void updateBudget(double value) {
    budget = value;
    _settingsBox.put(_budgetKey, value);
    notifyListeners();
  }

  void clearCart() {
    for (var i in cartItems) {
      i.purchased = false;
      i.save();
    }
    notifyListeners();
  }

  void toggleSort() {
    _ascending = !_ascending;
    notifyListeners();
  }

  List<Item> _sorted(Iterable<Item> items) {
    final list = items.toList();
    list.sort((a, b) {
      final cmp = a.category
          .toLowerCase()
          .compareTo(b.category.toLowerCase());
      if (cmp != 0) return _ascending ? cmp : -cmp;
      return _ascending
          ? a.name.compareTo(b.name)
          : b.name.compareTo(a.name);
    });
    return list;
  }
}