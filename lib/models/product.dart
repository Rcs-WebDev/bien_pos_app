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

  String getLocalizedName(dynamic langProvider) {
    if (langProvider.isEnglish) {
      switch (id) {
        case 1:
          return 'Spicy Meatball Soup';
        case 2:
          return 'Fried Chicken w/ Green Chili';
        case 3:
          return 'Special Fried Rice';
        case 4:
          return 'Palm Sugar Iced Coffee';
        case 5:
          return 'Sweet Iced Tea';
        case 6:
          return 'Chocolate Cheese Toast';
        default:
          return name;
      }
    }
    return name;
  }

  String getLocalizedVariant(dynamic langProvider) {
    if (langProvider.isEnglish) {
      switch (id) {
        case 1:
          return 'Special Spicy Broth';
        case 2:
          return 'Breast / Thigh';
        case 3:
          return 'Complete Egg + Sausage';
        case 4:
          return 'Less Ice';
        case 5:
          return 'Cold';
        case 6:
          return 'Large Portion';
        default:
          return variant;
      }
    }
    return variant;
  }

  String getLocalizedUnit(dynamic langProvider) {
    if (langProvider.isEnglish) {
      if (unit.toLowerCase() == 'porsi') return 'Portion';
      if (unit.toLowerCase() == 'gelas') return 'Cup';
    }
    return unit;
  }
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

  String getLocalizedLabel(dynamic langProvider) {
    final idStr = id.toString();
    if (idStr == 'all') return langProvider.tr('cat_all_short');
    if (idStr == '1') return langProvider.tr('cat_food');
    if (idStr == '2') return langProvider.tr('cat_drink');
    if (idStr == '3') return langProvider.tr('cat_snack');
    if (idStr == '4') return langProvider.tr('cat_combo');
    return label;
  }
}
