import 'package:get/get.dart';
import 'home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Use lazyPut to create the controller only when it's needed for the first time.
    // fenix: true ensures the controller is re-created if the user navigates away and comes back.
    Get.lazyPut<DebtController>(() => DebtController(), fenix: true);
  }
}
