class PosTransaction {
  final int id;
  final String transactionNo;
  final String cashierName;
  final String orderType;
  final int totalItems;
  final double subtotal;
  final double discount;
  final double shippingFee;
  final double tax;
  final double totalAmount;
  final String paymentMethod;
  final double tenderedAmount;
  final double changeAmount;
  final String status;
  final String createdAt;
  final String dateStr;
  final String customerName;
  final List<Map<String, dynamic>> items;

  PosTransaction({
    required this.id,
    required this.transactionNo,
    required this.cashierName,
    this.customerName = 'Umum',
    required this.orderType,
    required this.totalItems,
    required this.subtotal,
    required this.discount,
    required this.shippingFee,
    required this.tax,
    required this.totalAmount,
    required this.paymentMethod,
    required this.tenderedAmount,
    required this.changeAmount,
    required this.status,
    required this.createdAt,
    required this.dateStr,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'transaction_no': transactionNo,
        'cashier_name': cashierName,
        'customer_name': customerName,
        'order_type': orderType,
        'total_items': totalItems,
        'subtotal': subtotal,
        'discount': discount,
        'shipping_fee': shippingFee,
        'tax': tax,
        'total_amount': totalAmount,
        'payment_method': paymentMethod,
        'tendered_amount': tenderedAmount,
        'change_amount': changeAmount,
        'status': status,
        'created_at': createdAt,
        'date_str': dateStr,
        'items': items,
      };

  factory PosTransaction.fromJson(Map<String, dynamic> json) => PosTransaction(
        id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
        transactionNo: json['transaction_no'] ?? '',
        cashierName: json['cashier_name'] ?? 'Kasir',
        customerName: json['customer_name'] ?? 'Umum',
        orderType: json['order_type'] ?? 'DINE-IN',
        totalItems: (json['total_items'] as num?)?.toInt() ?? 0,
        subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
        discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
        shippingFee: (json['shipping_fee'] as num?)?.toDouble() ?? 0.0,
        tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
        totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
        paymentMethod: json['payment_method'] ?? 'CASH',
        tenderedAmount: (json['tendered_amount'] as num?)?.toDouble() ?? 0.0,
        changeAmount: (json['change_amount'] as num?)?.toDouble() ?? 0.0,
        status: json['status'] ?? 'SUKSES',
        createdAt: json['created_at'] ?? '',
        dateStr: json['date_str'] ?? '',
        items: List<Map<String, dynamic>>.from(json['items'] ?? []),
      );
}
