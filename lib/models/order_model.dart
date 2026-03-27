import 'cart_model.dart';

class Order {
  final String id;
  final DateTime date;
  final List<CartItem> items;
  final int total;
  final String status;

  Order({required this.id, required this.date, required this.items, required this.total, required this.status});
}