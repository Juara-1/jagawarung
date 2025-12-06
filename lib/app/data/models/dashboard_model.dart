class DashboardSummary {
  final double todayIncome;
  final double todayExpense;
  final double totalDebt;
  final int transactionCount;

  DashboardSummary({
    required this.todayIncome,
    required this.todayExpense,
    required this.totalDebt,
    this.transactionCount = 0,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      todayIncome: (json['today_income'] as num?)?.toDouble() ?? 0,
      todayExpense: (json['today_expense'] as num?)?.toDouble() ?? 0,
      totalDebt: (json['total_debt'] as num?)?.toDouble() ?? 0,
      transactionCount: json['transaction_count'] as int? ?? 0,
    );
  }

  double get netProfit => todayIncome - todayExpense;

  factory DashboardSummary.empty() {
    return DashboardSummary(
      todayIncome: 0,
      todayExpense: 0,
      totalDebt: 0,
      transactionCount: 0,
    );
  }
}



