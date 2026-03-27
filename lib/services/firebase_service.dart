import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/cart_model.dart';
import 'data_store.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- 1. XỬ LÝ TÀI KHOẢN ---

  // Đăng ký
  Future<void> signUp(String email, String password, String name, String phone, String address) async {
    try {
      // Tạo tài khoản Auth
      UserCredential cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      
      // Tạo thông tin UserProfile để lưu
      UserProfile newUser = UserProfile(
        id: cred.user!.uid,
        name: name,
        phone: phone,
        address: address,
        email: email,
      );

      // Lưu thông tin vào Firestore collection 'users'
      await _db.collection('users').doc(newUser.id).set(newUser.toMap());
      
      // Cập nhật vào AppData để dùng ngay
      AppData.currentUser = newUser;
    } catch (e) {
      throw Exception("Đăng ký thất bại: ${e.toString()}");
    }
  }

  // Đăng nhập
  Future<void> signIn(String email, String password) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      
      // Lấy thông tin user từ Firestore về
      DocumentSnapshot doc = await _db.collection('users').doc(cred.user!.uid).get();
      if (doc.exists) {
        AppData.currentUser = UserProfile.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      throw Exception("Email hoặc mật khẩu không đúng!");
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // --- 2. XỬ LÝ ĐƠN HÀNG ---

  // Lưu đơn hàng
  Future<void> saveOrder(List<CartItem> cartItems, int total) async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception("Bạn chưa đăng nhập");

    String orderId = "DH${DateTime.now().millisecondsSinceEpoch}";
    
    final orderData = {
      'id': orderId,
      'date': DateTime.now().toIso8601String(), // Lưu ngày dạng chuỗi
      'total': total,
      'status': 'Đang xử lý',
      'items': cartItems.map((e) => {
        'foodName': e.food.name,
        'price': e.food.price,
        'quantity': e.quantity,
        'image': e.food.image
      }).toList()
    };

    // Lưu vào: users -> [ID người dùng] -> orders -> [Mã đơn]
    await _db.collection('users').doc(user.uid).collection('orders').doc(orderId).set(orderData);
  }

  // Lấy luồng dữ liệu đơn hàng (Real-time)
  Stream<QuerySnapshot> getOrderStream() {
    User? user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _db.collection('users')
        .doc(user.uid)
        .collection('orders')
        .orderBy('date', descending: true) // Mới nhất lên đầu
        .snapshots();
  }
}