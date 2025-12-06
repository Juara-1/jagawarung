import 'package:get/get.dart';
import 'main_navigation_controller.dart';
import '../dashboard/dashboard_controller.dart';
import '../home/home_controller.dart';

class MainNavigationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainNavigationController>(() => MainNavigationController());
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<DebtController>(() => DebtController());
  }
}



