class Product {
  final int id;
  final dynamic categoryId;
  final String name;
  final String variant;
  final String sku;
  final String barcode;
  int stockQty;
  final String unit;
  final double costPrice;
  final double sellPrice;
  final String imageUrl;

  Product({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.variant,
    required this.sku,
    required this.barcode,
    required this.stockQty,
    required this.unit,
    required this.costPrice,
    required this.sellPrice,
    required this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'category_id': categoryId,
        'name': name,
        'variant': variant,
        'sku': sku,
        'barcode': barcode,
        'stock_qty': stockQty,
        'unit': unit,
        'cost_price': costPrice,
        'sell_price': sellPrice,
        'image_url': imageUrl,
      };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
        categoryId: json['category_id'] ?? 'all',
        name: json['name'] ?? '',
        variant: json['variant'] ?? '',
        sku: json['sku'] ?? '',
        barcode: json['barcode'] ?? '',
        stockQty: json['stock_qty'] != null ? (json['stock_qty'] as num).toInt() : 0,
        unit: json['unit'] ?? 'Porsi',
        costPrice: (json['cost_price'] as num?)?.toDouble() ?? 0.0,
        sellPrice: (json['sell_price'] as num?)?.toDouble() ?? 0.0,
        imageUrl: json['image_url'] ?? '',
      );
}

class Category {
  final dynamic id;
  final String name;
  final String label;

  Category({
    required this.id,
    required this.name,
    required this.label,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'label': label,
      };

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'] ?? 'all',
        name: json['name'] ?? '',
        label: json['label'] ?? json['name'] ?? '',
      );
}
