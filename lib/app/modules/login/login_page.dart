import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login_controller.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      // Background color is now handled by the theme's scaffoldBackgroundColor
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildHeader(context, textTheme),
                  const SizedBox(height: 32),
                  _buildForm(context, theme),
                  const SizedBox(height: 24),
                  _buildRegisterLink(context, textTheme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TextTheme textTheme) {
    return Column(
      children: [
        Icon(
          Icons.storefront_outlined,
          size: 80,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'Jaga Warung',
          style: textTheme.headlineLarge?.copyWith(
            color: Theme.of(context).colorScheme.onBackground,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Selamat datang kembali',
          style: textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context, ThemeData theme) {
    return Card(
      // Card styling is now handled by the theme's cardTheme
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildEmailField(),
            const SizedBox(height: 16),
            _buildPasswordField(),
            const SizedBox(height: 24),
            _buildLoginButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: controller.emailController,
      keyboardType: TextInputType.emailAddress,
      // Decoration is now handled by the theme's inputDecorationTheme
      decoration: const InputDecoration(
        labelText: 'Email',
        hintText: 'contoh@email.com',
        prefixIcon: Icon(Icons.email_outlined),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Obx(
      () => TextField(
        controller: controller.passwordController,
        obscureText: !controller.isPasswordVisible.value,
        // Decoration is now handled by the theme's inputDecorationTheme
        decoration: InputDecoration(
          labelText: 'Password',
          hintText: 'Masukkan password',
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(
              controller.isPasswordVisible.value
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
            onPressed: controller.togglePasswordVisibility,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          // Style is now handled by the theme's elevatedButtonTheme
          onPressed: controller.isLoading.value ? null : controller.login,
          child: controller.isLoading.value
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    // The color is inherited from the button's foreground color
                    color: Colors.white,
                  ),
                )
              : const Text('Login'),
        ),
      ),
    );
  }

  Widget _buildRegisterLink(BuildContext context, TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Belum punya akun? ',
          style: textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        // Style is now handled by the theme's textButtonTheme
        TextButton(
          onPressed: controller.goToRegister,
          child: const Text('Daftar Sekarang'),
        ),
      ],
    );
  }
}