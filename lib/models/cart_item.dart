import 'product.dart';

class CartItem {
  final Product product;
  int qty;
  String notes;

  CartItem({
    required this.product,
    this.qty = 1,
    this.notes = '',
  });

  double get subtotal => product.sellPrice * qty;

  Map<String, dynamic> toJson() => {
        'product': product.toJson(),
        'qty': qty,
        'notes': notes,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        product: Product.fromJson(json['product']),
        qty: json['qty'] ?? 1,
        notes: json['notes'] ?? '',
      );
}
