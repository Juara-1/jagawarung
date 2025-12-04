import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/auth_result.dart';


class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<AuthResult<UserModel>> signIn({
    required String email,
    required String password,
  }) async {
    try {

      print('[AuthRepository] signIn called with email: $email');

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );


      print('[AuthRepository] signIn response user: ${response.user?.toJson()}');
     
      print('[AuthRepository] signIn session: ${response.session != null}');

      if (response.user == null) {
        return AuthResult.failure('Login gagal. Email atau password mungkin salah.');
      }

      final user = UserModel.fromJson(response.user!.toJson());
      return AuthResult.success(user);
    } on AuthException catch (e) {

      print('[AuthRepository] AuthException: code=${e.statusCode}, message=${e.message}');
      return AuthResult.failure(_getErrorMessage(e));
    } catch (e) {
      // Handle unexpected errors
      print('[AuthRepository] Unknown error in signIn: $e');
      return AuthResult.failure('Terjadi kesalahan: ${e.toString()}');
    }
  }

 
  Future<AuthResult<UserModel>> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          if (displayName != null) 'display_name': displayName,
        },
      );

      if (response.user == null) {
        return AuthResult.failure('Pendaftaran gagal. Silakan coba lagi.');
      }

      final user = UserModel.fromJson(response.user!.toJson());
      return AuthResult.success(user);
    } on AuthException catch (e) {
      return AuthResult.failure(_getErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('Terjadi kesalahan: ${e.toString()}');
    }
  }


  Future<AuthResult<void>> signOut() async {
    try {
      await _supabase.auth.signOut();
      return AuthResult.success(null);
    } catch (e) {
      return AuthResult.failure('Gagal logout: ${e.toString()}');
    }
  }


  UserModel? getCurrentUser() {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    return UserModel.fromJson(user.toJson());
  }


  bool isAuthenticated() {
    return _supabase.auth.currentUser != null;
  }

  String _getErrorMessage(AuthException exception) {
    switch (exception.statusCode) {
      case '400':
        return 'Email atau password tidak valid.';
      case '422':
        return 'Email sudah terdaftar.';
      case '500':
        return 'Terjadi kesalahan server. Silakan coba lagi.';
      default:
        return exception.message;
    }
  }
}
