
class DebtModel {
  final String? id;
  final String customerName;
  final double amount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  DebtModel({
    this.id,
    required this.customerName,
    required this.amount,
    required this.createdAt,
    this.updatedAt,
  });


  factory DebtModel.fromJson(Map<String, dynamic> json) {
    return DebtModel(
      id: json['id'] as String?,
      customerName: json['debtor_name'] as String,
      amount: (json['total_nominal'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'debtor_name': customerName,
      'total_nominal': amount,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }


  DebtModel copyWith({
    String? id,
    String? customerName,
    double? amount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DebtModel(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class DebtSummary {
  final String customerName;
  final double totalDebt;
  final List<DebtModel> debts;

  DebtSummary({
    required this.customerName,
    required this.totalDebt,
    required this.debts,
  });
}
