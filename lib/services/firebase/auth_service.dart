import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    }
  }

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Exception _mapAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('Không tìm thấy tài khoản với email này.');
      case 'wrong-password':
        return Exception('Mật khẩu không đúng.');
      case 'email-already-in-use':
        return Exception('Email đã được sử dụng.');
      case 'invalid-email':
        return Exception('Địa chỉ email không hợp lệ.');
      case 'weak-password':
        return Exception('Mật khẩu quá yếu (tối thiểu 6 ký tự).');
      default:
        return Exception(e.message ?? 'Lỗi xác thực không xác định.');
    }
  }
}
