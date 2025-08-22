import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/grocery_item.dart';

class ShoppingListModel extends ChangeNotifier {
  late Box<GroceryItem> _box;
  late Box _settings;
  late Box<GroceryItem> _favoritesBox;

  List<GroceryItem> items = [];
  double budget = 0.0;
  bool isAsc = true;

  /// Inicializa as boxes de forma segura
  Future<void> init() async {
    if (!Hive.isBoxOpen('grocery_box')) {
      await Hive.openBox<GroceryItem>('grocery_box');
    }
    if (!Hive.isBoxOpen('settings')) {
      await Hive.openBox('settings');
    }
    if (!Hive.isBoxOpen('favorites_box')) {
      await Hive.openBox<GroceryItem>('favorites_box');
    }

    _box = Hive.box<GroceryItem>('grocery_box');
    _settings = Hive.box('settings');
    _favoritesBox = Hive.box<GroceryItem>('favorites_box');

    items = _box.values.toList();
    budget = _settings.get('budget', defaultValue: 0.0) as double;
    _sort();
    notifyListeners();
  }

  // --------------------
  // Getters seguros
  // --------------------
  List<GroceryItem> get available => items.where((i) => !i.purchased).toList();

  List<GroceryItem> get cart => items.where((i) => i.purchased).toList();

  List<GroceryItem> get favorites =>
      _favoritesBox.isOpen ? _favoritesBox.values.toList() : [];

  double get total => cart.fold(0.0, (sum, i) => sum + i.price * i.quantity);

  double get remaining => budget - total;

  // --------------------
  // Métodos principais
  // --------------------
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
      items.remove(i);
      i.delete(); // Remove do Hive
    }
    notifyListeners();
  }

  void toggleSort() {
    isAsc = !isAsc;
    _sort();
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
      // Atualiza apenas o objeto da lista principal se ele estiver em uma box
      if (item.isInBox) {
        item.isFavorite = false;
        item.save();
      } else {
        item.isFavorite = false;
      }
    } else {
      // Atualiza apenas o objeto da lista principal se ele estiver em uma box
      if (item.isInBox) {
        item.isFavorite = true;
        item.save();
      } else {
        item.isFavorite = true;
      }
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
    notifyListeners();
  }

  void addFavoriteToList(GroceryItem favorite) {
    // Cria uma cópia do favorito para evitar conflitos de Hive
    final item = GroceryItem(
      name: favorite.name,
      quantity: favorite.quantity,
      price: favorite.price,
      purchased: false,
      category: favorite.category,
      isFavorite: true,
    );
    _box.add(item);
    items.add(item);
    _sort();
    notifyListeners();
  }

  void remove(GroceryItem item) {
    items.remove(item);
    item.delete(); // Remove do Hive da lista principal
    notifyListeners();
  }

  // --------------------
  // Ordenação
  // --------------------
  void _sort() {
    items.sort(
      (a, b) => isAsc ? a.name.compareTo(b.name) : b.name.compareTo(a.name),
    );
  }
}
