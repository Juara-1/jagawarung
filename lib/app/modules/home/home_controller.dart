import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jagawarung/app/data/models/transaction_model.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/services/debt_service.dart';
import '../../data/services/ai_parsing_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../routes/app_routes.dart';

class DebtController extends GetxController {
  final DebtService _debtService = DebtService();
  final AiParsingService _aiService = AiParsingService();
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
  final List<String> _preferredTtsLangs = const ['jv-ID'];

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


  Future<void> processVoiceCommand(String command) async {
    isListening.value = false;
    isProcessing.value = true;
    errorMessage.value = '';

    try {
      lastResponseText.value = '🤖 Memproses dengan AI...';
      final parsed = await _aiService.parseVoiceCommand(command);

      print('AI Parsed: $parsed');

      final action = parsed['action'] as String;
      final name = parsed['name'] as String;
      final amount = parsed['amount'] as double?;
      final confidence = parsed['confidence'] as String;

      
      if (confidence == 'low') {
        lastResponseText.value = '⚠️ Kurang yakin, tapi akan diproses...';
      } else {
        lastResponseText.value = '✓ Perintah dipahami';
      }

   
      switch (action) {
        case 'catat_hutang':
          if (name.isNotEmpty && amount != null && amount > 0) {
            await _handleAddDebtAI(name, amount);
          } else {
            throw Exception(
                'Nama atau jumlah tidak valid. Coba ulangi dengan jelas.');
          }
          break;

        case 'cek_hutang':
          if (name.isNotEmpty) {
            await _handleCheckDebtAI(name);
          } else {
            throw Exception('Nama tidak terdeteksi. Coba ulangi.');
          }
          break;

        case 'hapus_hutang':
          if (name.isNotEmpty) {
            await _handleDeleteDebtAI(name);
          } else {
            throw Exception('Nama tidak terdeteksi. Coba ulangi.');
          }
          break;

        default:
          errorMessage.value =
              'Perintah tidak dikenali. Coba: "Catat hutang Budi satu juta" atau "Berapa hutang Budi?"';
          await _speak('Maaf, saya tidak mengerti perintah Anda');
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
      await _speak('Terjadi kesalahan. ${e.toString()}');
    } finally {
      isProcessing.value = false;
    }
  }


  Future<void> _handleAddDebt(String command) async {
    try {
    
      final result = await _debtService.addDebtViaAgent(command);

      final response = result.message;
      lastResponseText.value = response;
      await _speak(response);
      await loadDebts();

      Get.snackbar(
        '✅ Berhasil',
        response,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = 'Gagal mencatat hutang: $e';
      print(" error ${e}");
      await _speak('Gagal mencatat hutang');
      Get.snackbar('Error', errorMessage.value);
    }
  }


  Future<void> _handleCheckDebt(String command) async {
    try {
 
      final regex = RegExp(
        r'berapa\s+(?:hutang|utang)\s+([a-zA-Z\s]+?)(?:\?|$)',
        caseSensitive: false,
      );

      final match = regex.firstMatch(command);

      if (match != null) {
        final name = match.group(1)!.trim();

   
        final summary = await _debtService.getDebtSummary(name);

        if (summary.debts.isEmpty) {
          final response = '$name tidak memiliki hutang';
          lastResponseText.value = response;
          await _speak(response);
          Get.snackbar('ℹ️ Info', response);
        } else {
          final simpleResponse =
              'Total hutang $name adalah ${formatCurrency(summary.totalDebt)}';

          lastResponseText.value = simpleResponse;
          await _speak(simpleResponse);

          Get.defaultDialog(
            title: '💰 Hutang $name',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total: ${formatCurrency(summary.totalDebt)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6C5CE7),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Rincian:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...summary.debts.map((debt) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(formatDate(debt.createdAt)),
                          Text(
                            formatCurrency(debt.amount),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
            textConfirm: 'OK',
            onConfirm: () => Get.back(),
          );
        }
      } else {
        throw Exception('Format perintah salah. Contoh: "Berapa hutang Budi?"');
      }
    } catch (e) {
      errorMessage.value = 'Gagal mengecek hutang: $e';
      await _speak('Gagal mengecek hutang');
      Get.snackbar('Error', errorMessage.value);
    }
  }


  Future<void> _handleDeleteDebt(String command) async {
    try {
      final regex = RegExp(
        r'hapus\s+(?:hutang|utang)\s+([a-zA-Z\s]+?)(?:\?|$)',
        caseSensitive: false,
      );

      final match = regex.firstMatch(command);

      if (match != null) {
        final name = match.group(1)!.trim();
        final customerDebts = await _debtService.getDebtsByCustomer(name);

        if (customerDebts.isEmpty) {
          final response = '$name tidak memiliki hutang';
          lastResponseText.value = response;
          await _speak(response);
          return;
        }

        for (var debt in customerDebts) {
          await _debtService.deleteDebt(debt.id!);
        }

        await loadDebts();
        final response = 'Semua hutang $name berhasil dihapus';
        lastResponseText.value = response;
        await _speak(response);
        Get.snackbar('✅ Berhasil', response);
      }
    } catch (e) {
      errorMessage.value = 'Gagal menghapus hutang: $e';
      await _speak('Gagal menghapus hutang');
    }
  }


  Future<void> _handleAddDebtAI(String name, double amount) async {
    try {

      final prompt = '$name ${amount.toStringAsFixed(0)}';
      final result = await _debtService.addDebtViaAgent(prompt);

      final response = result.message;
      lastResponseText.value = response;
      await _speak(response);
      await loadDebts();
      Get.snackbar(
        '✅ Berhasil',
        response,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      errorMessage.value = 'Gagal mencatat hutang: $e';
      print("error ${e}");
      await _speak('Gagal mencatat hutang');
      Get.snackbar('Error', errorMessage.value);
    }
  }

 
  Future<void> _handleCheckDebtAI(String name) async {
    try {
      final summary = await _debtService.getDebtSummary(name);

      if (summary.debts.isEmpty) {
        final response = '$name tidak memiliki hutang';
        lastResponseText.value = response;
        await _speak(response);
        Get.snackbar('ℹ️ Info', response);
      } else {
        final simpleResponse =
            'Total hutang $name adalah ${formatCurrency(summary.totalDebt)}';

        lastResponseText.value = simpleResponse;
        await _speak(simpleResponse);

        
        Get.defaultDialog(
          title: '💰 Hutang $name',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total: ${formatCurrency(summary.totalDebt)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6C5CE7),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Rincian:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...summary.debts.take(10).map((debt) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(formatDate(debt.createdAt)),
                        Text(
                          formatCurrency(debt.amount),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
          textConfirm: 'OK',
          onConfirm: () => Get.back(),
        );
      }
    } catch (e) {
      errorMessage.value = 'Gagal mengecek hutang: $e';
      await _speak('Gagal mengecek hutang');
      Get.snackbar('Error', errorMessage.value);
    }
  }


  Future<void> _handleDeleteDebtAI(String name) async {
    try {
      final customerDebts = await _debtService.getDebtsByCustomer(name);

      if (customerDebts.isEmpty) {
        final response = '$name tidak memiliki hutang';
        lastResponseText.value = response;
        await _speak(response);
        return;
      }

     
      for (var debt in customerDebts) {
        await _debtService.deleteDebt(debt.id!);
      }

      await loadDebts();
      final response = 'Semua hutang $name berhasil dihapus';
      lastResponseText.value = response;
      await _speak(response);
      Get.snackbar('✅ Berhasil', response);
    } catch (e) {
      errorMessage.value = 'Gagal menghapus hutang: $e';
      await _speak('Gagal menghapus hutang');
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
