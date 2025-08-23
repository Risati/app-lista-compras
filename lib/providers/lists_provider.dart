import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/shopping_list.dart';

class ListsProvider extends ChangeNotifier {
  late Box<ShoppingList> _listsBox;
  List<ShoppingList> lists = [];

  Future<void> loadLists() async {
    _listsBox = Hive.box<ShoppingList>('lists_box');
    lists = _listsBox.values.toList();
    notifyListeners();
  }

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
}
