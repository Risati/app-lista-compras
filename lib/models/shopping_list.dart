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
  bool isCompleted; // Este campo existe mas não está sendo setado corretamente

  @HiveField(3)
  DateTime?
      completedAt; // Este campo existe mas não está sendo setado corretamente

  ShoppingList({
    required this.name,
    required this.items,
    this.isCompleted = false,
    this.completedAt,
  });

  void complete() {
    isCompleted = true;
    completedAt = DateTime.now();
  }
}
