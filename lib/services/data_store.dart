import 'package:intl/intl.dart';
import '../models/food_model.dart';
import '../models/cart_model.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';

class AppData {
  static List<FoodItem> foodList = [];
  static List<CartItem> cart = [];
  static List<Order> orderHistory = []; 
  
  // SỬA LỖI Ở ĐÂY: Thêm trường id: "" vào
  static UserProfile? currentUser = UserProfile(
      id: "", // <-- Bắt buộc phải có id (để trống tạm thời)
      name: "", 
      phone: "", 
      address: "", 
      email: ""
      , avatar: ""
  );

  static String formatCurrency(int amount) {
    final format = NumberFormat("#,###", "vi_VN");
    return "${format.format(amount)} đ";
  }
}