/// Restock Model
/// Model untuk data restocking/pembelian barang
class RestockModel {
  final String? id;
  final String productId;
  final String productName;
  final int quantity;
  final double buyPrice;
  final double totalCost;
  final String? supplierName;
  final String? invoiceNumber;
  final DateTime restockDate;
  final DateTime createdAt;
  final String? merchantId;
  final String? notes;

  RestockModel({
    this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.buyPrice,
    required this.totalCost,
    this.supplierName,
    this.invoiceNumber,
    required this.restockDate,
    required this.createdAt,
    this.merchantId,
    this.notes,
  });

  /// Convert from JSON
  factory RestockModel.fromJson(Map<String, dynamic> json) {
    return RestockModel(
      id: json['id'] as String?,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      quantity: json['quantity'] as int,
      buyPrice: (json['buy_price'] as num).toDouble(),
      totalCost: (json['total_cost'] as num).toDouble(),
      supplierName: json['supplier_name'] as String?,
      invoiceNumber: json['invoice_number'] as String?,
      restockDate: DateTime.parse(json['restock_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      merchantId: json['merchant_id'] as String?,
      notes: json['notes'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'buy_price': buyPrice,
      'total_cost': totalCost,
      if (supplierName != null) 'supplier_name': supplierName,
      if (invoiceNumber != null) 'invoice_number': invoiceNumber,
      'restock_date': restockDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      if (merchantId != null) 'merchant_id': merchantId,
      if (notes != null) 'notes': notes,
    };
  }
}
