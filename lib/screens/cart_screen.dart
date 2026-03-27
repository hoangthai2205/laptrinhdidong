import 'package:flutter/material.dart';
import '../services/data_store.dart';
import '../services/firebase_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int get totalAmount => AppData.cart.fold(0, (sum, item) => sum + (item.food.price * item.quantity));
  bool _isOrdering = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Giỏ hàng của bạn")),
      body: AppData.cart.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey), SizedBox(height: 10), Text("Giỏ hàng trống")]))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: AppData.cart.length,
                    itemBuilder: (context, index) {
                      final item = AppData.cart[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          leading: Image.network(item.food.image, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => const Icon(Icons.image)),
                          title: Text(item.food.name),
                          subtitle: Text(AppData.formatCurrency(item.food.price)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () {
                                  setState(() {
                                    if (item.quantity > 1) {
                                      item.quantity--;
                                    } else {
                                      AppData.cart.removeAt(index);
                                    }
                                  });
                                },
                              ),
                              Text("${item.quantity}", style: const TextStyle(fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                                onPressed: () => setState(() => item.quantity++),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))]),
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text("Tổng cộng:", style: TextStyle(fontSize: 18)),
                        Text(AppData.formatCurrency(totalAmount), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
                      ]),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          onPressed: _isOrdering ? null : () async {
                            if (AppData.cart.isEmpty) return;
                            
                            setState(() => _isOrdering = true);
                            try {
                              // Gửi đơn hàng lên Firebase
                              await FirebaseService().saveOrder(AppData.cart, totalAmount);
                              
                              // Xóa giỏ hàng sau khi đặt thành công
                              setState(() {
                                AppData.cart.clear();
                              });

                              if(mounted) {
                                showDialog(context: context, builder: (ctx) => AlertDialog(
                                  title: const Text("Thành công!"),
                                  content: const Text("Đơn hàng của bạn đã được gửi đi."),
                                  actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))],
                                ));
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
                            } finally {
                              if(mounted) setState(() => _isOrdering = false);
                            }
                          },
                          child: _isOrdering 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("THANH TOÁN NGAY", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
    );
  }
}