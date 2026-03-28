import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../services/data_store.dart';
import '../services/firebase_service.dart';
import '../screens/auth_screen.dart';
import 'order_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Uint8List? _avatarBytes;
  
Future<void> pickAvatar() async {
  final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
  if (picked != null) {
    final bytes = await picked.readAsBytes();
    setState(() {
      _avatarBytes = bytes;
    });
  }
}

  // 👉 Upload ảnh lên Firebase Storage
  Future<String?> uploadAvatar(Uint8List bytes, String userId) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('avatars')
          .child('$userId.jpg');

      await ref.putData(bytes);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Upload lỗi: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AppData.currentUser;

    if (user == null) {
      return const Scaffold(
          body: Center(child: Text("Chưa có thông tin người dùng")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hồ sơ cá nhân"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditDialog(context),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.green[50],
              child: Row(
                children: [
                  // 🔥 AVATAR
                  GestureDetector(
                    onTap: pickAvatar,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.green,
                      backgroundImage: _avatarBytes != null
                          ? MemoryImage(_avatarBytes!) as ImageProvider
                          : (user.avatar.isNotEmpty
                              ? NetworkImage(user.avatar)
                              : null),
                      child: (_avatarBytes == null &&
                            user.avatar.isEmpty)
                          ? const Icon(Icons.camera_alt,
                              size: 30, color: Colors.white)
                          : null,
                    ),
                  ),

                  const SizedBox(width: 20),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name.isNotEmpty
                            ? user.name
                            : "Người dùng"),
                        Text(user.email,
                            style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            ListTile(
              leading: const Icon(Icons.history, color: Colors.blue),
              title: const Text("Lịch sử đơn hàng"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const OrderHistoryScreen()));
              },
            ),

            const Divider(),

            ListTile(
              leading:
                  const Icon(Icons.location_on, color: Colors.orange),
              title: const Text("Địa chỉ giao hàng"),
              subtitle: Text(user.address.isNotEmpty
                  ? user.address
                  : "Chưa cập nhật"),
              trailing:
                  const Icon(Icons.edit, size: 16, color: Colors.grey),
              onTap: () => _showEditDialog(context),
            ),

            ListTile(
              leading:
                  const Icon(Icons.phone, color: Colors.purple),
              title: const Text("Số điện thoại"),
              subtitle: Text(user.phone.isNotEmpty
                  ? user.phone
                  : "Chưa cập nhật"),
              trailing:
                  const Icon(Icons.edit, size: 16, color: Colors.grey),
              onTap: () => _showEditDialog(context),
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Đăng xuất"),
              onTap: () async {
                await FirebaseService().signOut();
                AppData.currentUser = null;

                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                      (route) => false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // 👉 Popup sửa + lưu cả avatar
  void _showEditDialog(BuildContext context) {
    final user = AppData.currentUser!;

    final nameController = TextEditingController(text: user.name);
    final phoneController = TextEditingController(text: user.phone);
    final addressController =
        TextEditingController(text: user.address);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Cập nhật thông tin"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                      labelText: "Họ và tên"),
                ),
                TextField(
                  controller: phoneController,
                  decoration:
                      const InputDecoration(labelText: "SĐT"),
                ),
                TextField(
                  controller: addressController,
                  decoration:
                      const InputDecoration(labelText: "Địa chỉ"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Hủy")),

            ElevatedButton(
              onPressed: () async {
                String newName = nameController.text.trim();
                String newPhone = phoneController.text.trim();
                String newAddress = addressController.text.trim();

                try {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (c) =>
                        const Center(child: CircularProgressIndicator()),
                  );

                  String? avatarUrl;

                  if (_avatarBytes != null) {
                    avatarUrl =
                        await uploadAvatar(_avatarBytes!, user.id);
                  }

                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.id)
                      .update({
                    'name': newName,
                    'phone': newPhone,
                    'address': newAddress,
                    if (avatarUrl != null) 'avatar': avatarUrl,
                  });

                  setState(() {
                    user.name = newName;
                    user.phone = newPhone;
                    user.address = newAddress;
                    if (avatarUrl != null) {
                      user.avatar = avatarUrl;
                      _avatarBytes = null;
                    }
                  });

                  Navigator.of(context, rootNavigator: true).pop();
                  Navigator.of(context, rootNavigator: true).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Cập nhật thành công")),
                  );
                } catch (e) {
                  Navigator.of(context, rootNavigator: true).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Lỗi: $e")),
                  );
                }
              },
              child: const Text("Lưu"),
            ),
          ],
        );
      },
    );
  }
}