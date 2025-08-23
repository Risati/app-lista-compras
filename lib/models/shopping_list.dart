import 'package:hive/hive.dart';
import 'grocery_item.dart';

part 'shopping_list.g.dart';

@HiveType(typeId: 2)
class ShoppingList extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  List<GroceryItem> items;

  ShoppingList({required this.name, required this.items});
}
