import 'package:flutter/material.dart';
import '../models/food_model.dart';
import '../models/cart_model.dart';
import '../services/data_store.dart';

class ProductCard extends StatelessWidget {
  final FoodItem item;
  const ProductCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
         showModalBottomSheet(context: context, builder: (ctx) => Container(
           padding: const EdgeInsets.all(20),
           child: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
               Image.network(item.image, height: 200, fit: BoxFit.cover),
               const SizedBox(height: 10),
               Text(item.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
               Text(AppData.formatCurrency(item.price), style: const TextStyle(fontSize: 18, color: Colors.red)),
               const SizedBox(height: 10),
               Text(item.description),
               const SizedBox(height: 20),
               SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text("Đóng")))
             ],
           ),
         ));
      },
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5)]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)), 
                child: Image.network(
                  item.image, 
                  width: double.infinity, 
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image)),
                )
              )
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(item.category, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  Text(AppData.formatCurrency(item.price), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: double.infinity,
                    height: 30,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: EdgeInsets.zero),
                      onPressed: () {
                        bool exists = false;
                        for(var cartItem in AppData.cart) {
                          if(cartItem.food.id == item.id) {
                            cartItem.quantity++;
                            exists = true;
                            break;
                          }
                        }
                        if(!exists) AppData.cart.add(CartItem(food: item));
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đã thêm ${item.name} vào giỏ!"), duration: const Duration(milliseconds: 500)));
                      },
                      child: const Text("Thêm", style: TextStyle(fontSize: 12, color: Colors.white)),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}