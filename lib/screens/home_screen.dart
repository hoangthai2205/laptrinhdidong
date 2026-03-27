import 'package:flutter/material.dart';
import '../models/food_model.dart';
import '../services/data_store.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatelessWidget {
  final Future<List<FoodItem>> futureFoods;
  const HomeScreen({super.key, required this.futureFoods});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Joker Shop", style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 175, 76, 76))),
      ),
      body: FutureBuilder<List<FoodItem>>(
        future: futureFoods,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.green));
          } else if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Không có dữ liệu"));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network("https://images.unsplash.com/photo-1441986300917-64674bd600d8?q=80&w=1000&auto=format&fit=crop", height: 180, width: double.infinity, fit: BoxFit.cover),
                ),
                const SizedBox(height: 20),
                const Text("Danh mục phổ biến", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: ["Tất cả", "Áo", "Quần", "Giày", "Kính"].map((e) => Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Chip(label: Text(e), backgroundColor: Colors.green[50]),
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                const Text("Hôm nay có gì?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: AppData.foodList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, childAspectRatio: 0.70, crossAxisSpacing: 15, mainAxisSpacing: 15
                  ),
                  itemBuilder: (context, index) {
                    final item = AppData.foodList[index];
                    return ProductCard(item: item);
                  },
                )
              ],
            ),
          );
        },
      ),
    );
  }
}