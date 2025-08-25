import 'package:hive/hive.dart';
import 'grocery_item.dart';

part 'shopping_list.g.dart';

@HiveType(typeId: 2)
class ShoppingList extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  List<GroceryItem> items;

  @HiveField(2)
  double budget;

  ShoppingList({
    required this.name,
    required this.items,
    this.budget = 0.0, // Inicialize aqui
  });

}
