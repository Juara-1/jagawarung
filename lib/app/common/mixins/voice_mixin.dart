import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';

mixin VoiceMixin on GetxController {
  late final stt.SpeechToText speech;
  late final FlutterTts flutterTts;

  final isSpeechAvailable = false.obs;
  final isListening = false.obs;
  final recognizedText = ''.obs;
  final currentTtsLanguage = ''.obs;
  final List<String> _cachedTtsLanguages = [];
  String speechLocaleId = 'id_ID';

  // Language preference key
  static const String _ttsLanguageKey = 'preferred_tts_language';

  /// Available languages with labels
  Map<String, String> get availableLanguages => {
        'id-ID': 'Bahasa Indonesia',
        'jv-ID': 'Bahasa Jawa',
        'su-ID': 'Bahasa Sunda',
      };


  Future<List<String>> get preferredTtsLanguages async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_ttsLanguageKey);
      if (saved != null && availableLanguages.containsKey(saved)) {
        // Prioritize saved language first
        return [saved, ...availableLanguages.keys.where((k) => k != saved)];
      }
    } catch (e) {
    }
    // Default priority: Indonesia > Jawa > Sunda
    return ['id-ID', 'jv-ID', 'su-ID', 'en-US'];
  }

  Future<void> initializeSpeech() async {
    try {
      speech = stt.SpeechToText();
      final status = await Permission.microphone.request();

      if (status.isGranted) {
        isSpeechAvailable.value = await speech.initialize(
          onStatus: (status) {
            if (status == 'done' || status == 'notListening') {
              isListening.value = false;
            }
          },
          onError: (error) {
            isListening.value = false;
            Get.snackbar('Error STT', error.errorMsg, snackPosition: SnackPosition.BOTTOM);
          },
        );
      } else {
        Get.snackbar(
          'Izin Ditolak',
          'Microphone permission diperlukan untuk voice input',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal initialize STT: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  /// Initialize Text-to-Speech with language fallback
  Future<void> initializeTts() async {
    try {
      flutterTts = FlutterTts();
      await _setPreferredLanguage();
      await flutterTts.setSpeechRate(0.5);
      await flutterTts.setVolume(1.0);
      await flutterTts.setPitch(1.0);
    } catch (e) {
      Get.snackbar('Error', 'Gagal initialize TTS: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _setPreferredLanguage() async {
    try {
      final langs = await loadAvailableTtsLanguages();
      final preferred = await preferredTtsLanguages;
      
      for (final code in preferred) {
        if (langs.contains(code)) {
          await flutterTts.setLanguage(code);
          currentTtsLanguage.value = code;
          // Also set voice (for better language support on some devices)
          await _setVoiceForLanguage(code);
          return;
        }
      }
      
      // Force fallback to Indonesian if available
      if (langs.contains('id-ID')) {
        await flutterTts.setLanguage('id-ID');
        currentTtsLanguage.value = 'id-ID';
        await _setVoiceForLanguage('id-ID');
      }
    } catch (e) {
      // Silently fail, use engine default
    }
  }

  /// Set voice for specific language (helps with language support)
  Future<void> _setVoiceForLanguage(String languageCode) async {
    try {
      final voices = await flutterTts.getVoices;
      if (voices != null && voices is List) {
        // Find voice matching the language
        final matchingVoice = voices.firstWhere(
          (voice) => voice['locale']?.toString().startsWith(languageCode.substring(0, 2)) ?? false,
          orElse: () => null,
        );
        if (matchingVoice != null) {
          await flutterTts.setVoice({'name': matchingVoice['name'], 'locale': matchingVoice['locale']});
        }
      }
    } catch (e) {
      // Ignore if voice setting fails
    }
  }

  /// Set TTS language and save preference
  Future<bool> setTtsLanguage(String code) async {
    try {
      final langs = await loadAvailableTtsLanguages();
      if (langs.contains(code)) {
        await flutterTts.setLanguage(code);
        currentTtsLanguage.value = code;
       
        await _setVoiceForLanguage(code);
        
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_ttsLanguageKey, code);
        
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Check if specific language is available on device
  Future<bool> isLanguageAvailable(String code) async {
    try {
      final langs = await loadAvailableTtsLanguages();
      return langs.contains(code);
    } catch (e) {
      return false;
    }
  }

  /// Get saved TTS language preference
  Future<String?> getSavedTtsLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_ttsLanguageKey);
    } catch (e) {
      return null;
    }
  }

  /// Get available TTS languages (cached)
  Future<List<String>> loadAvailableTtsLanguages() async {
    if (_cachedTtsLanguages.isNotEmpty) return _cachedTtsLanguages;
    try {
      final langs = (await flutterTts.getLanguages)?.cast<String>() ?? [];
      _cachedTtsLanguages
        ..clear()
        ..addAll(langs);
      return _cachedTtsLanguages;
    } catch (e) {
      return [];
    }
  }

  /// Set speech-to-text locale (default id_ID)
  void setSpeechLocale(String localeId) {
    speechLocaleId = localeId;
  }

  /// Start listening for voice input
  Future<void> startListening({
    required Function(String) onResult,
    Duration listenFor = const Duration(seconds: 10),
    Duration pauseFor = const Duration(seconds: 3),
    String? localeId,
  }) async {
    if (!isSpeechAvailable.value) {
      Get.snackbar(
        'Speech Tidak Tersedia',
        'Silakan restart aplikasi atau cek izin microphone',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    recognizedText.value = '';
    isListening.value = true;

    await speech.listen(
      onResult: (result) {
        recognizedText.value = result.recognizedWords;
        if (result.finalResult) {
          onResult(result.recognizedWords);
        }
      },
      listenFor: listenFor,
      pauseFor: pauseFor,
      localeId: localeId ?? speechLocaleId,
    );
  }

  /// Stop listening
  Future<void> stopListening() async {
    await speech.stop();
    isListening.value = false;
  }

  /// Speak text (TTS)
  Future<void> speak(String text) async {
    try {
      if (currentTtsLanguage.value.isNotEmpty) {
        await flutterTts.setLanguage(currentTtsLanguage.value);
      }
      await flutterTts.speak(text);
    } catch (e) {
      // Silently fail
    }
  }

  /// Stop speaking
  Future<void> stopSpeaking() async {
    await flutterTts.stop();
  }

  /// Cleanup voice resources
  void disposeVoice() {
    speech.stop();
    flutterTts.stop();
  }
}


