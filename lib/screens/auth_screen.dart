import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import 'main_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLogin = true; // Chuyển đổi giữa Đăng nhập và Đăng ký
  bool _isLoading = false; // Trạng thái tải

  // Controller
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage("https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=1000&q=80"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken)
          )
        ),
        child: Center(
          child: SingleChildScrollView( // Thêm cuộn để không bị che bàn phím
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.food_bank, size: 60, color: Colors.green),
                    const SizedBox(height: 10),
                    Text(isLogin ? "ĐĂNG NHẬP" : "ĐĂNG KÝ", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    
                    if (!isLogin) ...[
                       TextField(controller: _nameController, decoration: InputDecoration(labelText: "Họ tên", prefixIcon: const Icon(Icons.person), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
                       const SizedBox(height: 10),
                       TextField(controller: _phoneController, decoration: InputDecoration(labelText: "Số điện thoại", prefixIcon: const Icon(Icons.phone), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
                       const SizedBox(height: 10),
                       TextField(controller: _addressController, decoration: InputDecoration(labelText: "Địa chỉ", prefixIcon: const Icon(Icons.location_on), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
                       const SizedBox(height: 10),
                    ],

                    TextField(controller: _emailController, decoration: InputDecoration(labelText: "Email", prefixIcon: const Icon(Icons.email), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
                    const SizedBox(height: 10),
                    TextField(controller: _passController, obscureText: true, decoration: InputDecoration(labelText: "Mật khẩu", prefixIcon: const Icon(Icons.lock), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        onPressed: _isLoading ? null : () async {
                          if (_emailController.text.isEmpty || _passController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")));
                            return;
                          }

                          setState(() => _isLoading = true);
                          try {
                            if (isLogin) {
                              await FirebaseService().signIn(_emailController.text.trim(), _passController.text.trim());
                            } else {
                              await FirebaseService().signUp(
                                _emailController.text.trim(),
                                _passController.text.trim(),
                                _nameController.text.trim(),
                                _phoneController.text.trim(),
                                _addressController.text.trim()
                              );
                            }
                            // Chuyển màn hình khi thành công
                            if (mounted) {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen()));
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: ${e.toString()}"), backgroundColor: Colors.red));
                          } finally {
                            if (mounted) setState(() => _isLoading = false);
                          }
                        },
                        child: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.white) 
                          : Text(isLogin ? "ĐĂNG NHẬP" : "ĐĂNG KÝ", style: const TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => isLogin = !isLogin),
                      child: Text(isLogin ? "Chưa có tài khoản? Đăng ký" : "Đã có tài khoản? Đăng nhập"),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}