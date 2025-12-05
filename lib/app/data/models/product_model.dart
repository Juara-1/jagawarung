/// Product Model
/// Model untuk data produk/barang di warung
class ProductModel {
  final String? id;
  final String name;
  final double buyPrice;  // Harga modal/beli
  final double sellPrice; // Harga jual
  final int stock;
  final String? category;
  final String? unit; // satuan: pcs, kg, liter, dll
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? merchantId;

  ProductModel({
    this.id,
    required this.name,
    required this.buyPrice,
    required this.sellPrice,
    required this.stock,
    this.category,
    this.unit,
    required this.createdAt,
    required this.updatedAt,
    this.merchantId,
  });

  /// Convert from JSON (Supabase response)
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String?,
      name: json['name'] as String,
      buyPrice: (json['buy_price'] as num).toDouble(),
      sellPrice: (json['sell_price'] as num).toDouble(),
      stock: json['stock'] as int,
      category: json['category'] as String?,
      unit: json['unit'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      merchantId: json['merchant_id'] as String?,
    );
  }

  /// Convert to JSON (for Supabase insert/update)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'buy_price': buyPrice,
      'sell_price': sellPrice,
      'stock': stock,
      if (category != null) 'category': category,
      if (unit != null) 'unit': unit,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (merchantId != null) 'merchant_id': merchantId,
    };
  }

  /// Copy with method
  ProductModel copyWith({
    String? id,
    String? name,
    double? buyPrice,
    double? sellPrice,
    int? stock,
    String? category,
    String? unit,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? merchantId,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      buyPrice: buyPrice ?? this.buyPrice,
      sellPrice: sellPrice ?? this.sellPrice,
      stock: stock ?? this.stock,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      merchantId: merchantId ?? this.merchantId,
    );
  }
}
