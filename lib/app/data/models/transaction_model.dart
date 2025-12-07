class TransactionModel {
  final String? id;
  final TransactionType type;
  final double amount;
  final String? customerName;
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? invoiceUrl;
  final Map<String, dynamic>? invoiceData;

  TransactionModel({
    this.id,
    required this.type,
    required this.amount,
    this.customerName,
    this.description,
    required this.createdAt,
    this.updatedAt,
    this.invoiceUrl,
    this.invoiceData,
  });


  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String?,
      type: TransactionType.fromString(json['type'] as String? ?? 'earning'),
      amount: (json['nominal'] as num).toDouble(),
      customerName: json['debtor_name'] as String?,
      description: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
      invoiceUrl: json['invoice_url'] as String?,
      invoiceData: json['invoice_data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (type == TransactionType.debts &&
          customerName != null &&
          customerName!.isNotEmpty)
        'debtor_name': customerName,
      'nominal': amount,
      'type': type.value,
      'note': description ?? '',
      if (invoiceUrl != null) 'invoiceUrl': invoiceUrl,
      if (invoiceData != null) 'invoiceData': invoiceData,
    };
  }

  TransactionModel copyWith({
    String? id,
    TransactionType? type,
    double? amount,
    String? customerName,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? invoiceUrl,
    Map<String, dynamic>? invoiceData,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      customerName: customerName ?? this.customerName,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      invoiceUrl: invoiceUrl ?? this.invoiceUrl,
      invoiceData: invoiceData ?? this.invoiceData,
    );
  }
}

enum TransactionType {
  earning,
  spending,
  debts;

  String get value {
    switch (this) {
      case TransactionType.earning:
        return 'earning';
      case TransactionType.spending:
        return 'spending';
      case TransactionType.debts:
        return 'debts';
    }
  }

  static TransactionType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'earning':
        return TransactionType.earning;
      case 'spending':
        return TransactionType.spending;
      case 'debts':
        return TransactionType.debts;
      default:
        return TransactionType.earning;
    }
  }
}

class ParsedVoiceResult {
  final String intent;
  final String? debtorName;
  final String? customerName;
  final double? nominal;
  final String message;

  ParsedVoiceResult({
    required this.intent,
    this.debtorName,
    this.customerName,
    this.nominal,
    required this.message,
  });

  factory ParsedVoiceResult.fromJson(Map<String, dynamic> json) {
    return ParsedVoiceResult(
      intent: json['intent'] as String,
      debtorName: json['debtor_name'] as String?,
      customerName: json['customer_name'] as String?,
      nominal: json['nominal'] != null ? (json['nominal'] as num).toDouble() : null,
      message: json['message'] as String? ?? '',
    );
  }

  TransactionType get transactionType {
    switch (intent.toUpperCase()) {
      case 'ADD_INCOME':
        return TransactionType.earning;
      case 'ADD_EXPENSE':
        return TransactionType.spending;
      case 'ADD_DEBT':
        return TransactionType.debts;
      default:
        return TransactionType.earning;
    }
  }
}


