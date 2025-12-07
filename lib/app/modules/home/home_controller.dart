import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jagawarung/app/data/models/transaction_model.dart';
import '../../data/services/debt_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../routes/app_routes.dart';
import '../../common/utils/format_utils.dart';
import '../../common/mixins/voice_mixin.dart';

class DebtController extends GetxController with VoiceMixin {
  final DebtService _debtService = DebtService();
  final AuthRepository _authRepository = AuthRepository();

  final isProcessing = false.obs;
  final lastResponseText = ''.obs;
  final debts = <TransactionModel>[].obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    initializeSpeech();
    initializeTts();
    loadDebts();
  }

  /// Wrapper to start voice input using VoiceMixin
  Future<void> startVoiceInput() async {
    if (!isSpeechAvailable.value) {
      errorMessage.value = 'Speech recognition tidak tersedia';
      Get.snackbar('Error', 'Speech recognition tidak tersedia');
      return;
    }

    errorMessage.value = '';
    recognizedText.value = '';
    await super.startListening(
      onResult: (text) {
        if (text.trim().isNotEmpty) {
          processVoiceCommand(text);
        }
      },
    );
  }


  Future<void> stopVoiceInput() async {
    await super.stopListening();
  }


  /// Proses voice command dengan backend agent API

  Future<void> processVoiceCommand(String command) async {
    isListening.value = false;
    isProcessing.value = true;
    errorMessage.value = '';

    try {
      lastResponseText.value = '🤖 Memproses...';
      final result = await _debtService.addDebtViaAgent(command);

      final response = result.message;
      lastResponseText.value = response;
      await speak(response);
      await loadDebts();

      Get.snackbar(
        '✅ Berhasil',
        response,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
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
      isProcessing.value = false;
    }
  }




  /// Replay last system response via TTS
  Future<void> replayLastResponse() async {
    if (lastResponseText.value.isNotEmpty) {
      await speak(lastResponseText.value);
    }
  }


  Future<void> loadDebts() async {
    try {
      debts.value = await _debtService.getAllDebts();
    } catch (e) {
      errorMessage.value = 'Gagal memuat data hutang: $e';
    }
  }


  String formatCurrency(double amount) => FormatUtils.formatCurrency(amount);

  String formatDate(DateTime date) => FormatUtils.formatDate(date, padZero: false);


  DebtService get debtService => _debtService;


  Future<void> repayDebt(String debtId) async {
    try {
      isProcessing.value = true;

    
      await _debtService.repayDebt(debtId);

      await loadDebts();

      await speak('Pembayaran utang berhasil dicatat');

      Get.snackbar(
        '✅ Lunas!',
        'Utang berhasil dilunasi dan tercatat sebagai pemasukan',
        backgroundColor: Colors.green[400],
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      errorMessage.value = 'Gagal melunasi utang: $e';
      await speak('Gagal melunasi utang');
      Get.snackbar(
        '❌ Gagal',
        errorMessage.value,
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> logout() async {
    try {
      final result = await _authRepository.signOut();
      
      if (result.isSuccess) {
        Get.snackbar(
          'Berhasil',
          'Logout berhasil',
          backgroundColor: Colors.green[400],
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );

        Get.offAllNamed(AppRoutes.login);
      } else {
        Get.snackbar(
          'Error',
          result.errorMessage ?? 'Gagal logout',
          backgroundColor: Colors.red[400],
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  @override
  void onClose() {
    disposeVoice();
    super.onClose();
  }
}
