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
  bool isCompleted;

  @HiveField(3)
  DateTime? completedAt;

  @HiveField(4)
  double budget; // NOVO CAMPO: orçamento individual da lista

  ShoppingList({
    required this.name,
    required this.items,
    this.isCompleted = false,
    this.completedAt,
    this.budget = 0.0, // valor padrão
  });

  void complete() {
    isCompleted = true;
    completedAt = DateTime.now();
  }

  void setBudget(double value) {
    budget = value;
    save();
  }
}