import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart'; // File này được tạo ra bởi lệnh 'flutterfire configure'

// Import các màn hình
import 'screens/auth_screen.dart';
import 'screens/main_screen.dart';
import 'services/data_store.dart';
import 'models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- HÀM MAIN (Điểm bắt đầu của ứng dụng) ---
void main() async {
  // 1. Đảm bảo Flutter Binding được khởi tạo trước khi gọi code bất đồng bộ
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Chạy ứng dụng
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Hàm load dữ liệu người dùng khi đã có session đăng nhập (Auto Login)
  Future<void> _loadUserData(User firebaseUser) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();
          
      if (doc.exists) {
        AppData.currentUser = UserProfile.fromMap(doc.data() as Map<String, dynamic>);
        print("Đã tải dữ liệu user: ${AppData.currentUser!.name}");
      }
    } catch (e) {
      print("Lỗi tải user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cửa Hàng Quần Áo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[50],
        useMaterial3: true,
      ),
      // --- LOGIC ĐIỀU HƯỚNG TỰ ĐỘNG ---
      // StreamBuilder lắng nghe trạng thái đăng nhập từ Firebase
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 1. Đang kiểm tra...
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator(color: Colors.green)),
            );
          }

          // 2. Đã có người đăng nhập (Snapshot có dữ liệu)
          if (snapshot.hasData) {
            // Gọi hàm tải thông tin user vào AppData để dùng trong app
            _loadUserData(snapshot.data!); 
            return const MainScreen();
          }

          // 3. Chưa đăng nhập -> Hiện trang Login
          return const LoginPage();
        },
      ),
    );
  }
}