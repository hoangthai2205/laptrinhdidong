import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/data_store.dart';
import '../services/firebase_service.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lịch sử đơn hàng")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseService().getOrderStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Bạn chưa có đơn hàng nào."));
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final orderData = orders[index].data() as Map<String, dynamic>;
              
              // Parse dữ liệu an toàn
              final String id = orderData['id'] ?? 'N/A';
              final int total = orderData['total'] ?? 0;
              final String status = orderData['status'] ?? 'Không rõ';
              final List items = orderData['items'] ?? [];
              final DateTime date = DateTime.parse(orderData['date']);

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text("Đơn hàng #${id.substring(id.length - 6)}"),
                  subtitle: Text("${items.length} cái - ${DateFormat('dd/MM/yyyy HH:mm').format(date)}"),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(AppData.formatCurrency(total), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                      Text(status, style: const TextStyle(color: Colors.green, fontSize: 12)),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => OrderDetailScreen(orderData: orderData)));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class OrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> orderData; // Nhận Map dữ liệu
  const OrderDetailScreen({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    final List items = orderData['items'] ?? [];
    final int total = orderData['total'] ?? 0;
    final DateTime date = DateTime.parse(orderData['date']);
    final String id = orderData['id'];

    return Scaffold(
      appBar: AppBar(title: const Text("Chi tiết đơn hàng")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Mã đơn: $id", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text("Ngày đặt: ${DateFormat('dd/MM/yyyy HH:mm').format(date)}"),
            const Divider(thickness: 1, height: 30),
            const Text("Danh sách đã mua:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    // Nếu bạn lưu 'image' trong order thì có thể hiện ảnh ở đây
                    leading: item['image'] != null 
                        ? Image.network(item['image'], width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_,__,___)=>const Icon(Icons.fastfood)) 
                        : const Icon(Icons.fastfood),
                    title: Text("${item['quantity']}x ${item['foodName'] ?? item['name']}"), // Xử lý 2 trường hợp tên key
                    trailing: Text(AppData.formatCurrency((item['price'] ?? 0) * (item['quantity'] ?? 1))),
                  );
                },
              ),
            ),
            const Divider(thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("TỔNG TIỀN:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(AppData.formatCurrency(total), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            )
          ],
        ),
      ),
    );
  }
}