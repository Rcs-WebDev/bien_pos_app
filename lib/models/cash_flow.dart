class CashFlow {
  final int id;
  final String date;
  final String type; // 'Kas Masuk' | 'Kas Keluar'
  final double amount;
  final String cashier;
  final String notes;

  CashFlow({
    required this.id,
    required this.date,
    required this.type,
    required this.amount,
    required this.cashier,
    required this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'type': type,
        'amount': amount,
        'cashier': cashier,
        'notes': notes,
      };

  factory CashFlow.fromJson(Map<String, dynamic> json) => CashFlow(
        id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
        date: json['date'] ?? '',
        type: json['type'] ?? 'Kas Masuk',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        cashier: json['cashier'] ?? '',
        notes: json['notes'] ?? '',
      );
}
