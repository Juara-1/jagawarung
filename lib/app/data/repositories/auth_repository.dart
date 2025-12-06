import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/auth_result.dart';
import '../services/token_service.dart';

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

      if (response.user == null || response.session == null) {
        return AuthResult.failure('Login gagal. Email atau password mungkin salah.');
      }

     
      await TokenService.saveTokens(
        accessToken: response.session!.accessToken,
        refreshToken: response.session!.refreshToken,
        userId: response.user!.id,
        email: response.user!.email ?? '',
      );

      print('[AuthRepository] Tokens saved successfully');

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

      if (response.user == null || response.session == null) {
        return AuthResult.failure('Pendaftaran gagal. Silakan coba lagi.');
      }

    
      await TokenService.saveTokens(
        accessToken: response.session!.accessToken,
        refreshToken: response.session!.refreshToken,
        userId: response.user!.id,
        email: response.user!.email ?? '',
      );

      print('[AuthRepository] SignUp - Tokens saved successfully');

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
      
  
      await TokenService.clearTokens();
      
      print('[AuthRepository] Logout successful, tokens cleared');
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


  Future<bool> hasValidToken() async {
    return await TokenService.hasToken();
  }


  Future<AuthResult<UserModel>> restoreSession() async {
    try {
      final hasToken = await TokenService.hasToken();
      
      if (!hasToken) {
        return AuthResult.failure('No saved token');
      }

      
      final session = _supabase.auth.currentSession;
      
      if (session == null) {
        final refreshToken = await TokenService.getRefreshToken();
        
        if (refreshToken != null) {
          print('[AuthRepository] Refreshing session...');
          final response = await _supabase.auth.refreshSession(refreshToken);
          
          if (response.session != null && response.user != null) {
     
            await TokenService.saveTokens(
              accessToken: response.session!.accessToken,
              refreshToken: response.session!.refreshToken ?? refreshToken,
              userId: response.user!.id,
              email: response.user!.email ?? '',
            );
            
            print('[AuthRepository] Session refreshed successfully');
            final user = UserModel.fromJson(response.user!.toJson());
            return AuthResult.success(user);
          }
        }
        
  
        await TokenService.clearTokens();
        return AuthResult.failure('Session expired');
      }

      
      final user = _supabase.auth.currentUser;
      if (user != null) {
        print('[AuthRepository] Session restored from saved token');
        return AuthResult.success(UserModel.fromJson(user.toJson()));
      }

      return AuthResult.failure('Failed to restore session');
    } catch (e) {
      print('[AuthRepository] Error restoring session: $e');
      await TokenService.clearTokens();
      return AuthResult.failure('Failed to restore session: $e');
    }
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
