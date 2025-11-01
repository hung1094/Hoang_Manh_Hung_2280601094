import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // CÁCH MỚI: Dùng .instance (không dùng constructor)
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  /// Đăng nhập bằng Google
  /// Trả về [User?] nếu thành công, null nếu thất bại hoặc hủy
  Future<User?> signInWithGoogle() async {
    try {
      // Bước 1: Mở popup chọn tài khoản (authenticate thay vì signIn)
      final GoogleSignInAccount? googleUser = await _googleSignIn
          .authenticate();

      if (googleUser == null) {
        return null; // Người dùng hủy
      }

      // Bước 2: Lấy thông tin xác thực
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null) {
        print("Lỗi: idToken là null");
        return null;
      }

      // Bước 3: Tạo credential cho Firebase (chỉ cần idToken)
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Bước 4: Đăng nhập Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print("Firebase Auth Error: ${e.message}");
      return null;
    } on GoogleSignInException catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    } catch (e) {
      print("Lỗi không xác định: $e");
      return null;
    }
  }

  /// Đăng xuất
  Future<void> signOut() async {
    try {
      await Future.wait([_googleSignIn.signOut(), _auth.signOut()]);
    } catch (e) {
      print("Lỗi đăng xuất: $e");
    }
  }

  /// Lấy user hiện tại
  User? get currentUser => _auth.currentUser;

  /// Stream trạng thái đăng nhập
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
