import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/providers/real_transaction_provider.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/dashboard_model.dart';

class DashboardController extends GetxController {
  final RealTransactionProvider _provider = RealTransactionProvider();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  final dashboardSummary = Rx<DashboardSummary>(DashboardSummary.empty());
  final recentTransactions = <TransactionModel>[].obs;
  
  final isLoading = false.obs;
  final isListening = false.obs;
  final isSpeechAvailable = false.obs;
  final recognizedText = ''.obs;
  final errorMessage = ''.obs;

  final List<String> _preferredTtsLangs = const ['id-ID'];

  @override
  void onInit() {
    super.onInit();
    _initializeSpeech();
    _initializeTts();
    loadDashboard();
  }

  Future<void> _initializeSpeech() async {
    try {
      final status = await Permission.microphone.request();

      if (status.isGranted) {
        isSpeechAvailable.value = await _speech.initialize(
          onStatus: (status) {
            if (status == 'done' || status == 'notListening') {
              isListening.value = false;
            }
          },
          onError: (error) {
            errorMessage.value = 'Error: ${error.errorMsg}';
            isListening.value = false;
          },
        );
      } else {
        errorMessage.value = 'Izin mikrofon diperlukan';
      }
    } catch (e) {
      errorMessage.value = 'Gagal menginisialisasi speech: $e';
    }
  }

  Future<void> _initializeTts() async {
    await _setPreferredLanguage();
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _setPreferredLanguage() async {
    try {
      final langs = (await _flutterTts.getLanguages)?.cast<String>() ?? [];
      for (final code in _preferredTtsLangs) {
        if (langs.contains(code)) {
          await _flutterTts.setLanguage(code);
          return;
        }
      }
    } catch (_) {
      // swallow errors and use default engine language
      
    }
  }

  Future<void> loadDashboard() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final summary = await _provider.getDashboardSummary();
      dashboardSummary.value = summary;

      final transactions = await _provider.getTransactions();
      recentTransactions.value = transactions.take(10).toList();
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
      isLoading.value = false;
    }
  }

  Future<void> startListening() async {
    if (!isSpeechAvailable.value) {
      errorMessage.value = 'Speech recognition tidak tersedia';
      Get.snackbar('Error', errorMessage.value);
      return;
    }

    errorMessage.value = '';
    recognizedText.value = '';
    isListening.value = true;

    await _speech.listen(
      onResult: (result) {
        recognizedText.value = result.recognizedWords;
        if (result.finalResult) {
          _handleVoiceResult(result.recognizedWords);
        }
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      localeId: 'id_ID',
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
    isListening.value = false;
  }

  Future<void> _handleVoiceResult(String transcript) async {
    if (transcript.trim().isEmpty) {
      isListening.value = false;
      return;
    }

    try {
      isLoading.value = true;
      isListening.value = false;
      final type = _inferType(transcript);

      final agentResult = await _provider.voiceAgentTransaction(
        type: type,
        prompt: transcript,
      );

      await _speak(agentResult.message);

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
      await _speak('Maaf, saya tidak mengerti perintah Anda');
      Get.snackbar(
        'Error',
        errorMessage.value,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
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
      isLoading.value = true;

      final transaction = TransactionModel(
        type: type,
        amount: amount,
        customerName: customerName,
        description: 'Voice Input',
        createdAt: DateTime.now(),
      );

      await _provider.createTransaction(transaction);

      await _speak('Transaksi berhasil disimpan');
      
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
      await _speak('Gagal menyimpan transaksi');
      Get.snackbar(
        'Error',
        errorMessage.value,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  String formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  @override
  void onClose() {
    _speech.stop();
    _flutterTts.stop();
    super.onClose();
  }
}

