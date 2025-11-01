import 'dart:async'; // THÊM DÒNG NÀY
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // CÁCH MỚI: DÙNG .instance
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  @override
  void initState() {
    super.initState();
    // KHỞI TẠO (tùy chọn)
    unawaited(
      _googleSignIn.initialize().then((_) {
        _googleSignIn.authenticationEvents.listen((event) {
          // Xử lý nếu cần
        });
      }),
    );
  }

  Future<void> _signInWithGoogle() async {
    try {
      // CÁCH MỚI: authenticate() → trả về GoogleSignInAccount
      final GoogleSignInAccount? user = await _googleSignIn.authenticate();

      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Đăng nhập bị hủy')));
        }
        return;
      }

      // CÁCH MỚI: Dùng authentication thay vì authorizationClient
      final GoogleSignInAuthentication auth = await user.authentication;

      if (auth.idToken == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không lấy được idToken')),
          );
        }
        return;
      }

      // Tạo credential cho Firebase
      final credential = GoogleAuthProvider.credential(idToken: auth.idToken);

      // Đăng nhập Firebase
      await _auth.signInWithCredential(credential);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_circle, size: 120, color: Colors.blue),
              const SizedBox(height: 30),
              const Text(
                'Đăng nhập bằng Google',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.grey),
                  ),
                  elevation: 3,
                ),
                icon: Image.asset('assets/google_logo.png', height: 28),
                label: const Text(
                  'Tiếp tục với Google',
                  style: TextStyle(color: Colors.black87, fontSize: 16),
                ),
                onPressed: _signInWithGoogle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
