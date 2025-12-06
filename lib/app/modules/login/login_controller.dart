import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:jagawarung/app/data/repositories/auth_repository.dart';
import '../../routes/app_routes.dart';

class LoginController extends GetxController {

  final AuthRepository _authRepository = AuthRepository();

  
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;


  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }


  bool _validateInputs() {
    if (emailController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Email tidak boleh kosong',
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }

    if (!GetUtils.isEmail(emailController.text.trim())) {
      Get.snackbar(
        'Error',
        'Format email tidak valid',
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }

    if (passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Password tidak boleh kosong',
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }

    return true;
  }


  Future<void> login() async {
    if (!_validateInputs()) return;

    try {
      isLoading.value = true;

      final result = await _authRepository.signIn(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (result.isSuccess) {
        Get.snackbar(
          'Berhasil',
          'Login berhasil! Selamat datang ${result.data?.email}',
          backgroundColor: Colors.green[400],
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        
        Get.offAllNamed(AppRoutes.main);
      } else {
        Get.snackbar(
          'Login Gagal',
          result.errorMessage ?? 'Terjadi kesalahan saat login',
          backgroundColor: Colors.red[400],
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: ${e.toString()}',
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  
  void goToRegister() {
    Get.toNamed(AppRoutes.register);
  }
}
