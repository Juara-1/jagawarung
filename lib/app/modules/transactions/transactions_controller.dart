import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/transaction_model.dart';
import '../../data/providers/real_transaction_provider.dart';

class TransactionsController extends GetxController {
  final RealTransactionProvider _provider = RealTransactionProvider();

  final transactions = <TransactionModel>[].obs;
  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final hasMore = true.obs;
  final errorMessage = ''.obs;
  final selectedType = ''.obs; 

  final _page = 1.obs;
  final int _perPage = 20;

  @override
  void onInit() {
    super.onInit();
    fetchTransactions(reset: true);
  }

  Future<void> fetchTransactions({bool reset = false}) async {
    if (isLoading.value) return;
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (reset) {
        _page.value = 1;
        hasMore.value = true;
        transactions.clear();
      }

      final items = await _provider.getTransactions(
        page: _page.value,
        perPage: _perPage,
        type: selectedType.value.isEmpty ? null : selectedType.value,
        orderBy: 'created_at',
        orderDirection: 'desc',
      );

      transactions.addAll(items);
      if (items.length < _perPage) {
        hasMore.value = false;
      } else {
        _page.value += 1;
      }
    } catch (e) {
      errorMessage.value = 'Gagal memuat transaksi: $e';
      Get.snackbar(
        'Error',
        errorMessage.value,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  Future<void> refreshData() async {
    isRefreshing.value = true;
    await fetchTransactions(reset: true);
  }

  void setFilter(String type) {
    selectedType.value = type;
    fetchTransactions(reset: true);
  }

  String formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\\d{1,3})(?=(\\d{3})+(?!\\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  String formatDate(DateTime date) {
    final d = date.toLocal();
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  Color typeColor(TransactionType type) {
    switch (type) {
      case TransactionType.earning:
        return Colors.green;
      case TransactionType.spending:
        return Colors.red;
      case TransactionType.debts:
        return Colors.orange;
    }
  }

  String typeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.earning:
        return 'Pemasukan';
      case TransactionType.spending:
        return 'Pengeluaran';
      case TransactionType.debts:
        return 'Utang';
    }
  }
}

