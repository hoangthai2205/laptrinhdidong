import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food_model.dart';
import 'data_store.dart';

class ApiService {
  static const String apiUrl = "https://69c32c04b780a9ba03e62ab7.mockapi.io/api/v1/products"; 

  Future<List<FoodItem>> fetchFoodData() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        List<FoodItem> foods = body.map((dynamic item) => FoodItem.fromJson(item)).toList();
        
        // Lưu vào DataStore để dùng chung toàn app
        AppData.foodList = foods;
        return foods;
      } else {
        throw Exception("Lỗi tải dữ liệu: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Lỗi kết nối: $e");
    }
  }
}