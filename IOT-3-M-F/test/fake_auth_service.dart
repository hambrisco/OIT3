import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_uno/services/auth_service.dart';

/// Minimal fake auth service that implements IAuthService but doesn't touch Firebase.
class FakeAuthService implements IAuthService {
  User? _user;

  @override
  Stream<User?> get authStateChanges => const Stream.empty();

  @override
  String? validateEmail(String email) => null;

  @override
  String? validatePassword(String password) => null;

  @override
  Future<void> signIn(String email, String password) async {
    // no-op
  }

  @override
  Future<void> signOut() async {
    // no-op
  }

  @override
  User? get currentUser => _user;
}
