import 'package:get/get.dart';
import 'package:jagawarung/app/modules/home/home_page.dart';
import '../modules/login/login_page.dart';
import '../modules/login/login_binding.dart';
import '../modules/register/register_page.dart';
import '../modules/register/register_binding.dart';
import '../modules/main/main_navigation_page.dart';
import '../modules/main/main_navigation_binding.dart';
import '../modules/dashboard/dashboard_view.dart';
import '../modules/dashboard/dashboard_binding.dart';
import '../modules/home/home_binding.dart';
import '../modules/smart_restock/smart_restock_page.dart';
import '../modules/smart_restock/reconciliation_page.dart';
import '../modules/transactions/transactions_view.dart';
import '../modules/transactions/transactions_binding.dart';
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
      name: AppRoutes.main,
      page: () => const MainNavigationPage(),
      binding: MainNavigationBinding(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.smartRestock,
      page: () => const SmartRestockPage(),
    ),
    GetPage(
      name: AppRoutes.reconciliation,
      page: () => const ReconciliationPage(),
    ),
    GetPage(
      name: AppRoutes.transactions,
      page: () => const TransactionsView(),
      binding: TransactionsBinding(),
    ),
  ];
}
