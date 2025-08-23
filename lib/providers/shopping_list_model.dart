import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/grocery_item.dart';
import '../models/shopping_list.dart';

class ShoppingListModel extends ChangeNotifier {
  late Box<GroceryItem> _favoritesBox;
  late Box _settings;
  final ShoppingList list;
  bool isAsc = true;
  double budget = 0.0;

  ShoppingListModel(this.list) {
    _initFavoritesBox();
    _initSettings();
  }

  Future<void> _initFavoritesBox() async {
    if (!Hive.isBoxOpen('favorites_box')) {
      await Hive.openBox<GroceryItem>('favorites_box');
    }
    _favoritesBox = Hive.box<GroceryItem>('favorites_box');
    notifyListeners();
  }

  Future<void> _initSettings() async {
    if (!Hive.isBoxOpen('settings')) {
      await Hive.openBox('settings');
    }
    _settings = Hive.box('settings');
    budget = _settings.get('budget', defaultValue: 0.0) as double;
    notifyListeners();
  }

  List<GroceryItem> get items => list.items;

  List<GroceryItem> get available => items.where((i) => !i.purchased).toList();

  List<GroceryItem> get cart => items.where((i) => i.purchased).toList();

  List<GroceryItem> get favorites =>
      _favoritesBox.isOpen ? _favoritesBox.values.toList() : [];

  double get total => cart.fold(0.0, (sum, i) => sum + i.price * i.quantity);

  double get remaining => budget - total;

  void addQuick(String name, int qty) {
    final item = GroceryItem(name: name, quantity: qty);
    items.add(item);
    _sort();
    list.save();
    notifyListeners();
  }

  void remove(GroceryItem item) {
    items.remove(item);
    list.save();
    notifyListeners();
  }

  void togglePurchased(GroceryItem item) {
    item.purchased = !item.purchased;
    list.save();
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
    list.save();
    notifyListeners();
  }

  void clearCart() {
    final toRemove = cart.toList();
    for (var i in toRemove) {
      items.remove(i);
    }
    list.save();
    notifyListeners();
  }

  void toggleSort() {
    isAsc = !isAsc;
    _sort();
    notifyListeners();
  }

  void _sort() {
    items.sort(
      (a, b) => isAsc ? a.name.compareTo(b.name) : b.name.compareTo(a.name),
    );
  }

  void updateBudget(double value) {
    budget = value;
    _settings.put('budget', value);
    notifyListeners();
  }

  void toggleFavorite(GroceryItem item) {
    final exists = _favoritesBox.values.any((fav) => fav.name == item.name);
    if (exists) {
      final key = _favoritesBox.keys.firstWhere(
        (k) => _favoritesBox.get(k)?.name == item.name,
        orElse: () => null,
      );
      if (key != null) _favoritesBox.delete(key);
      item.isFavorite = false;
    } else {
      item.isFavorite = true;
      final fav = GroceryItem(
        name: item.name,
        quantity: item.quantity,
        price: item.price,
        purchased: item.purchased,
        category: item.category,
        isFavorite: true,
      );
      _favoritesBox.add(fav);
    }
    list.save();
    notifyListeners();
  }

  void addFavoriteToList(GroceryItem favorite) {
    final item = GroceryItem(
      name: favorite.name,
      quantity: favorite.quantity,
      price: favorite.price,
      purchased: false,
      category: favorite.category,
      isFavorite: true,
    );
    items.add(item);
    _sort();
    list.save();
    notifyListeners();
  }
}