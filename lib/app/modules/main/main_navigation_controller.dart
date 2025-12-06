import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../dashboard/dashboard_view.dart';
import '../home/home_page.dart';

class MainNavigationController extends GetxController {
  final selectedIndex = 0.obs;

  final List<Widget> pages = const [
    DashboardView(),
    HomePage(),
  ];

  void changePage(int index) {
    selectedIndex.value = index;
  }
}




