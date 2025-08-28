import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/shopping_list.dart';
import '../models/grocery_item.dart';
import 'package:diacritic/diacritic.dart';

class ListsProvider extends ChangeNotifier {
  late Box<ShoppingList> _listsBox;
  late Box<GroceryItem> _favoritesBox;
  late Box _settings;
  List<ShoppingList> lists = [];

  // Getters
  List<ShoppingList> get activeLists =>
      lists.where((list) => !list.isCompleted).toList();

  List<ShoppingList> get completedLists =>
      lists.where((list) => list.isCompleted).toList();

  List<GroceryItem> getCartItems(ShoppingList list) {
    return list.items.where((item) => item.purchased).toList();
  }

  List<GroceryItem> get favorites {
    return _favoritesBox.values.toList();
  }

  // Inicialização
  Future<void> init() async {
    _listsBox = Hive.box<ShoppingList>('lists_box');
    if (!Hive.isBoxOpen('favorites_box')) {
      await Hive.openBox<GroceryItem>('favorites_box');
    }
    _favoritesBox = Hive.box<GroceryItem>('favorites_box');
    if (!Hive.isBoxOpen('settings')) {
      await Hive.openBox('settings');
    }
    _settings = Hive.box('settings');
    lists = _listsBox.values.toList();
    notifyListeners();
  }

  // Operações com Listas
  Future<void> addList(String name) async {
    final newList = ShoppingList(name: name, items: []);
    await _listsBox.add(newList);
    lists.add(newList);
    notifyListeners();
  }

  Future<void> removeList(ShoppingList list) async {
    await list.delete();
    lists.remove(list);
    notifyListeners();
  }

  Future<void> renameList(ShoppingList list, String newName) async {
    list.name = newName;
    await list.save();
    notifyListeners();
  }

  Future<void> completeList(ShoppingList list) async {
    list.complete();
    await list.save();
    notifyListeners();
  }

  // Operações com Itens
  void addItemToList(ShoppingList list, String name, int quantity) {
    final item = GroceryItem(
      name: name,
      quantity: quantity,
      price: 0.0,
      purchased: false,
      isFavorite: false,
    );
    list.items.add(item);
    list.save();
    notifyListeners();
  }

  void addFavoriteToList(ShoppingList list, GroceryItem item) {
    list.items.add(item);
    list.save();
    notifyListeners();
  }

  void removeItemFromList(ShoppingList list, GroceryItem item) {
    list.items.remove(item);
    list.save();
    notifyListeners();
  }

  void clearCart(ShoppingList list) {
    list.items.removeWhere((item) => item.purchased);
    list.save();
    notifyListeners();
  }

  void togglePurchased(ShoppingList list, GroceryItem item) {
    item.purchased = !item.purchased;
    list.save(); // salva a lista inteira
    notifyListeners();
  }

  void remove(ShoppingList list, GroceryItem item) {
    list.items.remove(item);
    list.save();
    notifyListeners();
  }

  void toggleItemPurchased(ShoppingList list, GroceryItem item) {
    item.purchased = !item.purchased;
    list.save();
    notifyListeners();
  }

  void updateItem(
    ShoppingList list,
    GroceryItem item, {
    String? name,
    int? quantity,
    double? price,
  }) {
    if (name != null) item.name = name;
    if (quantity != null) item.quantity = quantity;
    if (price != null) item.price = price;
    list.save();
    notifyListeners();
  }

  bool isListAscending(ShoppingList list) {
    return _settings.get('list_${list.key}_ascending', defaultValue: true);
  }

  void toggleListSort(ShoppingList list) {
    final key = 'list_${list.key}_ascending';
    final newAscending = !isListAscending(list);
    _settings.put(key, newAscending);
    sortList(list, ascending: newAscending); // aplica a ordenação
    notifyListeners();
  }

  double getBudget() {
    return _settings.get('budget', defaultValue: 0.0);
  }

  void updateBudget(double value) {
    _settings.put('budget', value);
    notifyListeners();
  }

  // Favoritos
  void toggleFavorite(GroceryItem item) {
    final exists = favorites.any((fav) => fav.name == item.name);
    if (exists) {
      final key = _favoritesBox.keys.firstWhere(
        (k) => _favoritesBox.get(k)?.name == item.name,
      );
      _favoritesBox.delete(key);
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
    notifyListeners();
  }

  // Estatísticas e Cálculos
  double getListTotal(ShoppingList list) =>
      list.items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  double getListPurchasedTotal(ShoppingList list) => list.items
      .where((item) => item.purchased)
      .fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  int getRemainingItems(ShoppingList list) =>
      list.items.where((item) => !item.purchased).length;

  List<GroceryItem> getAvailableItems(ShoppingList list) =>
      list.items.where((i) => !i.purchased).toList();

  bool isListComplete(ShoppingList list) =>
      list.items.isNotEmpty && list.items.every((item) => item.purchased);

  // Ordenação
  void sortList(ShoppingList list, {bool ascending = true}) {
    list.items.sort((a, b) {
      final an = removeDiacritics(a.name).toLowerCase();
      final bn = removeDiacritics(b.name).toLowerCase();
      return ascending ? an.compareTo(bn) : bn.compareTo(an);
    });
    list.save();
    notifyListeners();
  }

  double getListBudget(ShoppingList list) => list.budget;

  void updateListBudget(ShoppingList list, double value) {
    list.budget = value;
    list.save(); // persiste no Hive
    notifyListeners();
  }
}
