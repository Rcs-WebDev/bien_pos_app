class ShiftClosing {
  final int id;
  final String shiftNo;
  final String employeeName;
  final String startTime;
  final String endTime;
  final double totalSales;
  final double cashSales;
  final double qrisSales;
  final double transferSales;
  final int voidCount;
  final double voidTotal;
  final double commissionEarned;
  final String notes;
  final String createdAt;

  ShiftClosing({
    required this.id,
    required this.shiftNo,
    required this.employeeName,
    required this.startTime,
    required this.endTime,
    required this.totalSales,
    required this.cashSales,
    required this.qrisSales,
    required this.transferSales,
    required this.voidCount,
    required this.voidTotal,
    required this.commissionEarned,
    required this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'shift_no': shiftNo,
        'employee_name': employeeName,
        'start_time': startTime,
        'end_time': endTime,
        'total_sales': totalSales,
        'cash_sales': cashSales,
        'qris_sales': qrisSales,
        'transfer_sales': transferSales,
        'void_count': voidCount,
        'void_total': voidTotal,
        'commission_earned': commissionEarned,
        'notes': notes,
        'created_at': createdAt,
      };

  factory ShiftClosing.fromJson(Map<String, dynamic> json) => ShiftClosing(
        id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
        shiftNo: json['shift_no'] ?? '',
        employeeName: json['employee_name'] ?? 'Kasir',
        startTime: json['start_time'] ?? '',
        endTime: json['end_time'] ?? '',
        totalSales: (json['total_sales'] as num?)?.toDouble() ?? 0.0,
        cashSales: (json['cash_sales'] as num?)?.toDouble() ?? 0.0,
        qrisSales: (json['qris_sales'] as num?)?.toDouble() ?? 0.0,
        transferSales: (json['transfer_sales'] as num?)?.toDouble() ?? 0.0,
        voidCount: (json['void_count'] as num?)?.toInt() ?? 0,
        voidTotal: (json['void_total'] as num?)?.toDouble() ?? 0.0,
        commissionEarned: (json['commission_earned'] as num?)?.toDouble() ?? 0.0,
        notes: json['notes'] ?? '',
        createdAt: json['created_at'] ?? '',
      );
}
