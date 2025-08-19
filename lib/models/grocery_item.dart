import 'package:hive/hive.dart';

part 'grocery_item.g.dart';

@HiveType(typeId: 0)
class GroceryItem extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int quantity;

  @HiveField(2)
  double price;

  @HiveField(3)
  bool purchased;

  GroceryItem({
    required this.name,
    required this.quantity,
    this.price = 0.0,
    this.purchased = false,
  });
}