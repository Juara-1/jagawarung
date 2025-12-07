import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/providers/real_transaction_provider.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/dashboard_model.dart';
import '../../common/mixins/voice_mixin.dart';
import '../../common/utils/format_utils.dart';

class DashboardController extends GetxController with VoiceMixin {
  final RealTransactionProvider _provider = RealTransactionProvider();

  final dashboardSummary = Rx<DashboardSummary>(DashboardSummary.empty());
  final recentTransactions = <TransactionModel>[].obs;
  
  final isLoadingDashboard = false.obs;
  final isVoiceProcessing = false.obs;
  final errorMessage = ''.obs;
  final summaryRange = 'day'.obs; // day | week | month 

  @override
  void onInit() {
    super.onInit();
    initializeSpeech();
    initializeTts();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      isLoadingDashboard.value = true;
      errorMessage.value = '';

      final summary = await _provider.getDashboardSummary(
        timeRange: summaryRange.value,
      );
      dashboardSummary.value = summary;

      // Fetch transactions, exclude debts (only earning & spending for dashboard)
      final transactions = await _provider.getTransactions();
      recentTransactions.value = transactions
          .where((tx) => tx.type != TransactionType.debts)
          .take(10)
          .toList();
    } catch (e) {
      errorMessage.value = 'Gagal memuat dashboard: $e';
      Get.snackbar(
        'Error',
        errorMessage.value,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingDashboard.value = false;
    }
  }

  void changeSummaryRange(String range) {
    if (summaryRange.value == range) return;
    summaryRange.value = range;
    loadDashboard();
  }

  Future<void> startVoiceInput() async {
    if (!isSpeechAvailable.value) {
      errorMessage.value = 'Speech recognition tidak tersedia';
      Get.snackbar('Error', errorMessage.value);
      return;
    }

    errorMessage.value = '';
    await super.startListening(onResult: _handleVoiceResult);
  }

  Future<void> _handleVoiceResult(String transcript) async {
    if (transcript.trim().isEmpty) {
      isListening.value = false;
      return;
    }

    try {
      isVoiceProcessing.value = true;
      isListening.value = false;
      final type = _inferType(transcript);

      final agentResult = await _provider.voiceAgentTransaction(
        type: type,
        prompt: transcript,
      );

      await speak(agentResult.message);

      Get.snackbar(
        'Berhasil',
        agentResult.message,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
        snackPosition: SnackPosition.BOTTOM,
      );

      await loadDashboard();
    } catch (e) {
      errorMessage.value = 'Gagal memproses: $e';
      await speak('Maaf, saya tidak mengerti perintah Anda');
      Get.snackbar(
        'Error',
        errorMessage.value,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isVoiceProcessing.value = false;
    }
  }

  TransactionType _inferType(String transcript) {
    final lower = transcript.toLowerCase();

    if (lower.contains('utang') ||
        lower.contains('hutang') ||
        lower.contains('bon') ||
        lower.contains('pinjam')) {
      return TransactionType.debts;
    }

    if (lower.contains('beli') ||
        lower.contains('belanja') ||
        lower.contains('keluar') ||
        lower.contains('bayar')) {
      return TransactionType.spending;
    }

    return TransactionType.earning;
  }

  void _showConfirmationDialog(ParsedVoiceResult parsed) {
    final nameController = TextEditingController(
      text: parsed.debtorName ?? parsed.customerName ?? '',
    );
    final amountController = TextEditingController(
      text: parsed.nominal?.toStringAsFixed(0) ?? '',
    );

    Get.dialog(
      AlertDialog(
        title: Text(_getDialogTitle(parsed.intent)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (parsed.intent == 'ADD_DEBT') ...[
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Pelanggan',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nominal',
                border: OutlineInputBorder(),
                prefixText: 'Rp ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _saveTransaction(
                type: parsed.transactionType,
                amount: double.tryParse(amountController.text) ?? 0,
                customerName: nameController.text.trim(),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  String _getDialogTitle(String intent) {
    switch (intent.toUpperCase()) {
      case 'ADD_INCOME':
        return 'Konfirmasi Pemasukan';
      case 'ADD_EXPENSE':
        return 'Konfirmasi Pengeluaran';
      case 'ADD_DEBT':
        return 'Konfirmasi Utang';
      default:
        return 'Konfirmasi Transaksi';
    }
  }

  Future<void> _saveTransaction({
    required TransactionType type,
    required double amount,
    String? customerName,
  }) async {
    try {
      isVoiceProcessing.value = true;

      final transaction = TransactionModel(
        type: type,
        amount: amount,
        customerName: customerName,
        description: 'Voice Input',
        createdAt: DateTime.now(),
      );

      await _provider.createTransaction(transaction);

      await speak('Transaksi berhasil disimpan');
      
      Get.snackbar(
        'Berhasil',
        'Transaksi berhasil disimpan',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
        snackPosition: SnackPosition.BOTTOM,
      );

      await loadDashboard();
    } catch (e) {
      errorMessage.value = 'Gagal menyimpan: $e';
      await speak('Gagal menyimpan transaksi');
      Get.snackbar(
        'Error',
        errorMessage.value,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isVoiceProcessing.value = false;
    }
  }

  String formatCurrency(double amount) => FormatUtils.formatCurrency(amount);

  @override
  void onClose() {
    disposeVoice();
    super.onClose();
  }
}

