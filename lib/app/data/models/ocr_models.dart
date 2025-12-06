
class OcrInvoiceItem {
  final String name;      
  final int quantity;     
  final double price;   
  final double total;     
  
  
  String? matchedProductId;
  String? matchedProductName;
  double matchConfidence;
  
 
 bool isManuallyEdited;
  
  OcrInvoiceItem({
    required this.name,
    required this.quantity,
    required this.price,
    required this.total,
    this.matchedProductId,
    this.matchedProductName,
    this.matchConfidence = 0.0,
    this.isManuallyEdited = false,
  });

  factory OcrInvoiceItem.fromJson(Map<String, dynamic> json) {
    return OcrInvoiceItem(
      name: json['name'] as String? ?? '',
      quantity: json['quantity'] as int? ?? json['qty'] as int? ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  OcrInvoiceItem copyWith({
    String? name,
    int? quantity,
    double? price,
    double? total,
    String? matchedProductId,
    String? matchedProductName,
    double? matchConfidence,
    bool? isManuallyEdited,
  }) {
    return OcrInvoiceItem(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      total: total ?? this.total,
      matchedProductId: matchedProductId ?? this.matchedProductId,
      matchedProductName: matchedProductName ?? this.matchedProductName,
      matchConfidence: matchConfidence ?? this.matchConfidence,
      isManuallyEdited: isManuallyEdited ?? this.isManuallyEdited,
    );
  }
}


class OcrInvoiceResponse {
  final String? supplierName;
  final String? invoiceNumber;
  final DateTime? invoiceDate;
  final double? totalAmount;
  final List<OcrInvoiceItem> items;
  final String rawText;
  
  OcrInvoiceResponse({
    this.supplierName,
    this.invoiceNumber,
    this.invoiceDate,
    this.totalAmount,
    required this.items,
    required this.rawText,
  });

  factory OcrInvoiceResponse.fromJson(Map<String, dynamic> json) {
    List<OcrInvoiceItem> items = [];
    
    // Parse items dari OCR results
    if (json['items'] != null && json['items'] is List) {
      items = (json['items'] as List)
          .map((item) => OcrInvoiceItem.fromJson(item))
          .toList();
    } else if (json['results'] != null && json['results'] is List) {
      items = (json['results'] as List)
          .map((item) => OcrInvoiceItem.fromJson(item))
          .toList();
    }
    
    return OcrInvoiceResponse(
      supplierName: json['supplier'] as String? ?? json['merchant'] as String?,
      invoiceNumber: json['invoice_number'] as String? ?? json['invoice_no'] as String?,
      invoiceDate: json['date'] != null 
          ? DateTime.tryParse(json['date'] as String)
          : null,
      totalAmount: (json['total'] as num?)?.toDouble() ?? 
                   (json['grand_total'] as num?)?.toDouble(),
      items: items,
      rawText: json['raw_text'] as String? ?? json['text'] as String? ?? '',
    );
  }
}
