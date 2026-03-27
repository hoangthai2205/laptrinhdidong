import 'dart:math';

class FoodItem {
  final String id;
  final String name;
  final String image;
  final int price;
  final String category;
  final String description;

  FoodItem({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.category,
    required this.description,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'].toString(),
      name: json['name'] ?? "Hàng chưa về",
      image: (json['image'] != null && json['image'].toString().isNotEmpty)
          ? json['image']
          : "https://via.placeholder.com/150",
      price: double.parse(json['price'].toString()).toInt(),
      description: json['description'] ?? "",
      
      // Dòng này đã được sửa để lấy đúng danh mục từ MockAPI
      category: json['category']?.toString() ?? "Chưa phân loại",
    ); // FoodItem
  }
}