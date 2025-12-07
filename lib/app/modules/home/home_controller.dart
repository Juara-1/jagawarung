import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jagawarung/app/data/models/transaction_model.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/services/debt_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../routes/app_routes.dart';

class DebtController extends GetxController {
  final DebtService _debtService = DebtService();
  final AuthRepository _authRepository = AuthRepository();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();


  final isListening = false.obs;
  final recognizedText = ''.obs;
  final isProcessing = false.obs;
  final lastResponseText = ''.obs;
  final debts = <TransactionModel>[].obs;
  final errorMessage = ''.obs;
  final isSpeechAvailable = false.obs;
  final List<String> _preferredTtsLangs = const ['id-ID', 'jv-ID', 'en-US'];

  @override
  void onInit() {
    super.onInit();
    _initializeSpeech();
    _initializeTts();
    loadDebts();
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
        errorMessage.value = 'Izin mikrofon diperlukan untuk fitur ini';
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
      // ignore errors, keep default
    }
  }


  Future<void> startListening() async {
    if (!isSpeechAvailable.value) {
      errorMessage.value = 'Speech recognition tidak tersedia';
      Get.snackbar('Error', 'Speech recognition tidak tersedia');
      return;
    }

    errorMessage.value = '';
    recognizedText.value = '';
    isListening.value = true;

    await _speech.listen(
      onResult: (result) {
        recognizedText.value = result.recognizedWords;

        if (result.finalResult) {
          processVoiceCommand(result.recognizedWords);
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
      await _speak(response);
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
      await _speak('Maaf, saya tidak mengerti perintah Anda');
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




  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  /// Replay last system response via TTS
  Future<void> replayLastResponse() async {
    if (lastResponseText.value.isNotEmpty) {
      await _speak(lastResponseText.value);
    }
  }


  Future<void> loadDebts() async {
    try {
      debts.value = await _debtService.getAllDebts();
    } catch (e) {
      errorMessage.value = 'Gagal memuat data hutang: $e';
    }
  }


  String formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }


  DebtService get debtService => _debtService;


  Future<void> repayDebt(String debtId) async {
    try {
      isProcessing.value = true;

    
      await _debtService.repayDebt(debtId);

      await loadDebts();

      await _speak('Pembayaran utang berhasil dicatat');

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
      await _speak('Gagal melunasi utang');
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
    _speech.stop();
    _flutterTts.stop();
    super.onClose();
  }
}
