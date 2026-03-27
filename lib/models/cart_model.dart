import 'food_model.dart';

class CartItem {
  final FoodItem food;
  int quantity;
  CartItem({required this.food, this.quantity = 1});
}