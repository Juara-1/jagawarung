import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../env.dart';


class AiParsingService {
  late final GenerativeModel _model;

  AiParsingService() {
    _model = GenerativeModel(
      model: 'gemini-2.0-flash-lite',
      apiKey: Environment.geminiApiKey,
    );
  }


  Future<Map<String, dynamic>> parseVoiceCommand(String voiceText) async {
    try {
      final prompt = '''
Kamu adalah asisten AI untuk aplikasi pencatatan hutang warung. Tugasmu adalah menganalisis perintah suara dari merchant dan mengekstrak informasi penting.

ATURAN PARSING:
1. Identifikasi ACTION (catat_hutang, cek_hutang, atau hapus_hutang)
2. Ekstrak NAMA customer (bisa 1-3 kata)
3. Ekstrak JUMLAH uang jika ada (konversi ke angka)

KONVERSI ANGKA INDONESIA:
- "satu juta" = 1000000
- "lima ratus ribu" = 500000
- "seratus lima puluh ribu" = 150000
- "dua puluh ribu" = 20000
- "lima ribu" = 5000
- "lima ratus" = 500
- "seratus" = 100
- "dua juta lima ratus ribu" = 2500000
- dll.

POLA YANG DITERIMA:
- "catat hutang [nama] [jumlah]"
- "catat utang [nama] [jumlah]"
- "berapa hutang [nama]"
- "berapa utang [nama]"
- "hapus hutang [nama]"
- "hapus utang [nama]"

VARIASI YANG HARUS DIPAHAMI:
- "catet hutang"
- "catt utang"
- "brapa hutang"
- "berpa utang"
- nama dengan typo atau salah dengar
- angka dengan variasi pengucapan

INPUT: "$voiceText"

OUTPUT (HARUS JSON VALID):
{
  "action": "catat_hutang" atau "cek_hutang" atau "hapus_hutang" atau "unknown",
  "name": "nama customer (title case)",
  "amount": angka atau null,
  "confidence": "high" atau "medium" atau "low",
  "original_text": "text asli"
}

Jangan tambahkan penjelasan apapun, HANYA JSON.
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final responseText = response.text?.trim() ?? '';

   
      String jsonText =
          responseText.replaceAll('```json', '').replaceAll('```', '').trim();


      final result = _parseJsonResponse(jsonText);
      return result;
    } catch (e) {
      print('AI Parsing Error: $e');

      return _fallbackParsing(voiceText);
    }
  }


  Map<String, dynamic> _parseJsonResponse(String jsonText) {
    try {
      final json = jsonText.replaceAll('\n', '').replaceAll('  ', '');

    
      final actionMatch = RegExp(r'"action":\s*"([^"]+)"').firstMatch(json);
      final nameMatch = RegExp(r'"name":\s*"([^"]+)"').firstMatch(json);
      final amountMatch = RegExp(r'"amount":\s*(\d+|null)').firstMatch(json);
      final confidenceMatch =
          RegExp(r'"confidence":\s*"([^"]+)"').firstMatch(json);

      return {
        'action': actionMatch?.group(1) ?? 'unknown',
        'name': nameMatch?.group(1) ?? '',
        'amount': amountMatch?.group(1) == 'null'
            ? null
            : double.tryParse(amountMatch?.group(1) ?? '0'),
        'confidence': confidenceMatch?.group(1) ?? 'low',
        'original_text': '',
      };
    } catch (e) {
      print('JSON Parse Error: $e');
      return _fallbackParsing(jsonText);
    }
  }


  Map<String, dynamic> _fallbackParsing(String text) {
    final lowerText = text.toLowerCase();

    String action = 'unknown';
    String name = '';
    double? amount;


    if (lowerText.contains(RegExp(r'cat[ae]t?\s+(hutang|utang)'))) {
      action = 'catat_hutang';
    } else if (lowerText.contains(RegExp(r'b[ae]r[ae]pa\s+(hutang|utang)'))) {
      action = 'cek_hutang';
    } else if (lowerText.contains(RegExp(r'hapus\s+(hutang|utang)'))) {
      action = 'hapus_hutang';
    }

  
    if (action == 'catat_hutang') {
      final match = RegExp(
        r'cat[ae]t?\s+(?:hutang|utang)\s+([a-zA-Z\s]+?)\s+(.+)',
        caseSensitive: false,
      ).firstMatch(text);

      if (match != null) {
        name = _capitalizeWords(match.group(1)?.trim() ?? '');
        amount = _parseIndonesianNumber(match.group(2)?.trim() ?? '');
      }
    } else {
      final match = RegExp(
        r'(?:b[ae]r[ae]pa|hapus)\s+(?:hutang|utang)\s+([a-zA-Z\s]+?)(?:\?|$)',
        caseSensitive: false,
      ).firstMatch(text);

      if (match != null) {
        name = _capitalizeWords(match.group(1)?.trim() ?? '');
      }
    }

    return {
      'action': action,
      'name': name,
      'amount': amount,
      'confidence': 'low',
      'original_text': text,
    };
  }

 
  double _parseIndonesianNumber(String text) {
    final lower = text.toLowerCase().trim();

 
    final directNumber = double.tryParse(lower);
    if (directNumber != null) return directNumber;


    final Map<String, int> numbers = {
      'nol': 0,
      'satu': 1,
      'dua': 2,
      'tiga': 3,
      'empat': 4,
      'lima': 5,
      'enam': 6,
      'tujuh': 7,
      'delapan': 8,
      'sembilan': 9,
      'sepuluh': 10,
      'sebelas': 11,
      'belas': 10,
      'puluh': 10,
      'ratus': 100,
      'ribu': 1000,
      'juta': 1000000,
      'miliar': 1000000000
    };

    double result = 0;
    double current = 0;

    final words = lower.split(RegExp(r'\s+'));

    for (final word in words) {
      if (word.isEmpty) continue;

   
      if (word.startsWith('se')) {
        final base = word.substring(2);
        if (numbers.containsKey(base)) {
          final value = numbers[base]!;
          if (value >= 100) {
            current = value.toDouble();
          } else {
            current = 1;
          }
          continue;
        }
      }

      if (numbers.containsKey(word)) {
        final value = numbers[word]!;

        if (value >= 1000000) {
       
          result += (current == 0 ? 1 : current) * value;
          current = 0;
        } else if (value >= 1000) {
 
          if (current == 0) current = 1;
          result += current * value;
          current = 0;
        } else if (value >= 100) {
      
          if (current == 0) current = 1;
          current *= value;
        } else if (value >= 10 && word == 'puluh') {
      
          if (current == 0) current = 1;
          current *= value;
        } else if (word == 'belas') {
    
          current += 10;
        } else {
          if (current == 0) {
            current = value.toDouble();
          } else {
            current += value;
          }
        }
      }
    }

    result += current;
    return result > 0 ? result : 0;
  }


  String _capitalizeWords(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
