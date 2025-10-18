import 'package:firebase_auth/firebase_auth.dart';

abstract class IAuthService {
  Stream<User?> get authStateChanges;
  String? validateEmail(String email);
  String? validatePassword(String password);
  Future<void> signIn(String email, String password);
  Future<void> signOut();
  User? get currentUser;
}

class AuthService implements IAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Estado del usuario actual
  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Validar correo y contraseña
  @override
  String? validateEmail(String email) {
    if (email.isEmpty) {
      return 'El correo es requerido';
    }
    if (!email.contains('@')) {
      return 'Ingrese un correo válido';
    }
    return null;
  }

  @override
  String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'La contraseña es requerida';
    }
    if (password.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  // Iniciar sesión
  @override
  Future<void> signIn(String email, String password) async {
    // Validar campos
    final emailError = validateEmail(email);
    if (emailError != null) throw emailError;

    final passwordError = validatePassword(password);
    if (passwordError != null) throw passwordError;

    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e, st) {
      // Log detallado para depuración local (temporal)
      // NO incluir tokens o secretos en logs públicos.
      // Imprime código y mensaje para identificar bloqueos por App Check/reCAPTCHA/quota.
      // Estos prints se verán en la consola (web) o en la salida del run.
      // Si prefieres, reemplaza 'print' por otro sistema de logging.
      print('FirebaseAuthException.code: ${e.code}');
      print('FirebaseAuthException.message: ${e.message}');
      print('FirebaseAuthException.stack: $st');

      if (e.code == 'user-not-found') {
        throw 'No se encontró ningún usuario con ese correo (code: ${e.code})';
      } else if (e.code == 'wrong-password') {
        throw 'Contraseña incorrecta (code: ${e.code})';
      } else {
        // Re-lanzar con el código para que el UI muestre algo útil al usuario.
        throw 'Error al iniciar sesión: ${e.message} (code: ${e.code})';
      }
    }
  }

  // Cerrar sesión
  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Obtener usuario actual
  @override
  User? get currentUser => _auth.currentUser;
}
