import 'package:hive/hive.dart';

part 'item.g.dart';

@HiveType(typeId: 0)
class Item extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int quantity;

  @HiveField(2)
  double price;

  @HiveField(3)
  String category;

  @HiveField(4)
  bool purchased;

  Item({
    required this.name,
    required this.quantity,
    this.price = 0.0,
    this.category = 'Sem categoria',
    this.purchased = false,
  });
}