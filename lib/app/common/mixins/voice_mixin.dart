import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

 mixin VoiceMixin on GetxController {
  late final stt.SpeechToText speech;
  late final FlutterTts flutterTts;

  final isSpeechAvailable = false.obs;
  final isListening = false.obs;
  final recognizedText = ''.obs;
  final currentTtsLanguage = ''.obs;
  final List<String> _cachedTtsLanguages = [];
  String speechLocaleId = 'id_ID';

  
  List<String> get preferredTtsLanguages => const ['id-ID', 'jv-ID', 'su-ID', 'en-US'];

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
            print('[Voice] STT Error: ${error.errorMsg}');
            isListening.value = false;
          },
        );
      } else {
        print('[Voice] Microphone permission denied');
      }
    } catch (e) {
      print('[Voice] Failed to initialize STT: $e');
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
      print('[Voice] Failed to initialize TTS: $e');
    }
  }

  Future<void> _setPreferredLanguage() async {
    try {
      final langs = await loadAvailableTtsLanguages();
      for (final code in preferredTtsLanguages) {
        if (langs.contains(code)) {
          await flutterTts.setLanguage(code);
          print('[Voice] TTS language set to: $code');
          currentTtsLanguage.value = code;
          return;
        }
      }
      // Force fallback to Indonesian if available as a best-effort
      if (langs.contains('id-ID')) {
        await flutterTts.setLanguage('id-ID');
        print('[Voice] TTS fallback set to id-ID');
        currentTtsLanguage.value = 'id-ID';
        return;
      }
      print('[Voice] No preferred TTS language available, using engine default');
    } catch (e) {
      print('[Voice] Error setting TTS language: $e');
    }
  }

  /// Explicitly set TTS language; returns true if applied
  Future<bool> setTtsLanguage(String code) async {
    try {
      final langs = await loadAvailableTtsLanguages();
      if (langs.contains(code)) {
        await flutterTts.setLanguage(code);
        currentTtsLanguage.value = code;
        print('[Voice] TTS language manually set to: $code');
        return true;
      }
      print('[Voice] Requested TTS language not available: $code');
      return false;
    } catch (e) {
      print('[Voice] Error setting TTS language manually: $e');
      return false;
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
      print('[Voice] Failed to load TTS languages: $e');
      return [];
    }
  }

  /// Set speech-to-text locale (default id_ID)
  void setSpeechLocale(String localeId) {
    speechLocaleId = localeId;
    print('[Voice] STT locale set to: $localeId');
  }

  /// Start listening for voice input
  Future<void> startListening({
    required Function(String) onResult,
    Duration listenFor = const Duration(seconds: 10),
    Duration pauseFor = const Duration(seconds: 3),
    String? localeId,
  }) async {
    if (!isSpeechAvailable.value) {
      print('[Voice] Speech not available');
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
      await flutterTts.speak(text);
    } catch (e) {
      print('[Voice] TTS error: $e');
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

