import 'package:string_similarity/string_similarity.dart';
import '../models/product_model.dart';
import '../models/ocr_models.dart';

/// Product Matcher Service
/// Smart matching antara nama produk dari OCR dengan database
/// Handles "Different Naming" problem
class ProductMatcherService {
  /// Match OCR item dengan produk di database
  /// Returns best match dengan confidence score
  Future<ProductMatchResult?> matchProduct(
    String ocrName,
    List<ProductModel> allProducts,
  ) async {
    if (allProducts.isEmpty) return null;

    // Clean OCR name
    final cleanedOcrName = _cleanProductName(ocrName);
    
    // Extract keywords
    final keywords = _extractKeywords(cleanedOcrName);

    List<ProductMatchResult> matches = [];

    for (var product in allProducts) {
      final cleanedDbName = _cleanProductName(product.name);
      
      // Method 1: Exact match (100%)
      if (cleanedOcrName.toLowerCase() == cleanedDbName.toLowerCase()) {
        return ProductMatchResult(
          product: product,
          confidence: 100.0,
          matchMethod: 'exact',
        );
      }

      // Method 2: Contains all keywords (high confidence)
      int keywordMatches = 0;
      for (var keyword in keywords) {
        if (cleanedDbName.toLowerCase().contains(keyword.toLowerCase())) {
          keywordMatches++;
        }
      }
      
      if (keywordMatches == keywords.length && keywords.isNotEmpty) {
        matches.add(ProductMatchResult(
          product: product,
          confidence: 85.0 + (keywordMatches * 2.0), // 85-95%
          matchMethod: 'keywords',
        ));
        continue;
      }

      // Method 3: Fuzzy string similarity
      final similarity = cleanedOcrName.similarityTo(cleanedDbName) * 100;
      
      if (similarity >= 60.0) {
        matches.add(ProductMatchResult(
          product: product,
          confidence: similarity,
          matchMethod: 'fuzzy',
        ));
      }

      // Method 4: Partial match (contains either way)
      if (cleanedDbName.toLowerCase().contains(cleanedOcrName.toLowerCase()) ||
          cleanedOcrName.toLowerCase().contains(cleanedDbName.toLowerCase())) {
        matches.add(ProductMatchResult(
          product: product,
          confidence: 70.0,
          matchMethod: 'partial',
        ));
      }
    }

    // Sort by confidence descending
    matches.sort((a, b) => b.confidence.compareTo(a.confidence));

    // Return best match if above threshold
    if (matches.isNotEmpty && matches.first.confidence >= 60.0) {
      return matches.first;
    }

    return null;
  }

  /// Match multiple OCR items dengan database
  Future<List<OcrInvoiceItem>> matchMultipleItems(
    List<OcrInvoiceItem> ocrItems,
    List<ProductModel> allProducts,
  ) async {
    List<OcrInvoiceItem> matchedItems = [];

    for (var ocrItem in ocrItems) {
      final match = await matchProduct(ocrItem.name, allProducts);
      
      if (match != null) {
        matchedItems.add(ocrItem.copyWith(
          matchedProductId: match.product.id,
          matchedProductName: match.product.name,
          matchConfidence: match.confidence,
        ));
      } else {
        matchedItems.add(ocrItem); // No match found
      }
    }

    return matchedItems;
  }

  /// Clean product name untuk matching
  String _cleanProductName(String name) {
    return name
        .replaceAll(RegExp(r'[^\w\s]'), ' ') // Remove special chars
        .replaceAll(RegExp(r'\s+'), ' ')     // Normalize spaces
        .trim();
  }

  /// Extract important keywords dari nama produk
  List<String> _extractKeywords(String name) {
    // Remove common stop words
    final stopWords = [
      'dan', 'atau', 'di', 'ke', 'dari', 'untuk', 'yang',
      'the', 'and', 'or', 'in', 'to', 'from', 'for',
      'bks', 'pcs', 'pack', 'box', 'btl', 'bottle',
    ];

    final words = name.toLowerCase().split(' ');
    
    return words
        .where((word) => word.length > 2 && !stopWords.contains(word))
        .toList();
  }

  /// Get alternative product suggestions
  Future<List<ProductModel>> getSuggestions(
    String ocrName,
    List<ProductModel> allProducts,
    {int maxSuggestions = 5}
  ) async {
    List<ProductMatchResult> suggestions = [];

    for (var product in allProducts) {
      final cleanedOcrName = _cleanProductName(ocrName);
      final cleanedDbName = _cleanProductName(product.name);
      
      final similarity = cleanedOcrName.similarityTo(cleanedDbName) * 100;
      
      if (similarity >= 30.0) {
        suggestions.add(ProductMatchResult(
          product: product,
          confidence: similarity,
          matchMethod: 'suggestion',
        ));
      }
    }

    // Sort and limit
    suggestions.sort((a, b) => b.confidence.compareTo(a.confidence));
    
    return suggestions
        .take(maxSuggestions)
        .map((s) => s.product)
        .toList();
  }
}

/// Product Match Result
/// Result dari matching process
class ProductMatchResult {
  final ProductModel product;
  final double confidence; // 0-100
  final String matchMethod; // exact, keywords, fuzzy, partial, suggestion

  ProductMatchResult({
    required this.product,
    required this.confidence,
    required this.matchMethod,
  });

  bool get isHighConfidence => confidence >= 80.0;
  bool get isMediumConfidence => confidence >= 60.0 && confidence < 80.0;
  bool get isLowConfidence => confidence < 60.0;
}
