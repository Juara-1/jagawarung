import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'main_navigation_controller.dart';

class MainNavigationPage extends GetView<MainNavigationController> {
  const MainNavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Obx(() => controller.pages[controller.selectedIndex.value]),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
            border: Border(
              top: BorderSide(color: Colors.grey.withOpacity(0.15)),
            ),
          ),
          child: SafeArea(
            top: false,
            child: NavigationBar(
              selectedIndex: controller.selectedIndex.value,
              onDestinationSelected: controller.changePage,
              elevation: 0,
              backgroundColor: Colors.transparent,
              indicatorColor: colorScheme.primaryContainer.withOpacity(0.7),
              height: 88,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              animationDuration: const Duration(milliseconds: 250),
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.dashboard_outlined, size: 28),
                  selectedIcon: Icon(Icons.dashboard, size: 30, color: colorScheme.primary),
                  label: 'Dashboard',
                  tooltip: 'Ringkasan pemasukan & pengeluaran',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.receipt_long_outlined, size: 28),
                  selectedIcon: Icon(Icons.receipt_long, size: 30, color: colorScheme.primary),
                  label: 'Utang',
                  tooltip: 'Kelola catatan utang pelanggan',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


