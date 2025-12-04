import 'package:get/get.dart';
import '../modules/login/login_page.dart';
import '../modules/login/login_binding.dart';
import '../modules/register/register_page.dart';
import '../modules/register/register_binding.dart';
import '../modules/home/home_page.dart';
import 'app_routes.dart';

/// App Pages
class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterPage(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
    ),
  ];
}
