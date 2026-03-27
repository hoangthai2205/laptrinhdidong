import 'package:flutter/material.dart';
import '../models/food_model.dart';
import '../models/cart_model.dart';
import '../services/data_store.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _keyword = "";
  String _selectedCategory = "Tất cả";
  RangeValues _priceRange = const RangeValues(0, 500000);

  @override
  Widget build(BuildContext context) {
    List<FoodItem> filteredList = AppData.foodList.where((item) {
      bool matchName = item.name.toLowerCase().contains(_keyword.toLowerCase());
      bool matchCategory = _selectedCategory == "Tất cả" || item.category == _selectedCategory;
      bool matchPrice = item.price >= _priceRange.start && item.price <= _priceRange.end;
      return matchName && matchCategory && matchPrice;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Tìm kiếm & Bộ lọc")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (val) => setState(() => _keyword = val),
              decoration: InputDecoration(
                hintText: "Phong cách của bạn là gì?...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true, fillColor: Colors.white
              ),
            ),
          ),
          ExpansionTile(
            title: const Text("Bộ lọc nâng cao", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Danh mục:"),
                    Wrap(
                      spacing: 8,
                      children: ["Tất cả", "Quần", "Áo", "Giày", "Kính"].map((e) {
                        return ChoiceChip(
                          label: Text(e),
                          selected: _selectedCategory == e,
                          onSelected: (selected) => setState(() => _selectedCategory = e),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    const Text("Khoảng giá:"),
                    RangeSlider(
                      values: _priceRange,
                      min: 0, max: 500000, divisions: 10,
                      labels: RangeLabels(AppData.formatCurrency(_priceRange.start.toInt()), AppData.formatCurrency(_priceRange.end.toInt())),
                      activeColor: Colors.green,
                      onChanged: (val) => setState(() => _priceRange = val),
                    )
                  ],
                ),
              )
            ],
          ),
          const Divider(),
          Expanded(
            child: filteredList.isEmpty
              ? const Center(child: Text("Không tìm thấy món nào!"))
              : ListView.builder(
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final item = filteredList[index];
                    return ListTile(
                      leading: Image.network(item.image, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => const Icon(Icons.image)),
                      title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(item.category),
                      trailing: Text(AppData.formatCurrency(item.price), style: const TextStyle(color: Colors.red)),
                      onTap: () {
                         bool exists = false;
                        for(var cartItem in AppData.cart) {
                          if(cartItem.food.id == item.id) {
                            cartItem.quantity++;
                            exists = true;
                            break;
                          }
                        }
                        if(!exists) AppData.cart.add(CartItem(food: item));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã thêm vào giỏ hàng"), duration: Duration(milliseconds: 500)));
                      },
                    );
                  },
                ),
          )
        ],
      ),
    );
  }
}