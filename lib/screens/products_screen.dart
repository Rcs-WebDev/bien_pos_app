import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/product_provider.dart';
import '../providers/language_provider.dart';
import '../models/product.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final langProvider = Provider.of<LanguageProvider>(context);
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: Text(langProvider.tr('products_title'), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.indigo, size: 26),
            onPressed: () => _showAddProductDialog(context, langProvider),
            tooltip: langProvider.tr('add_product'),
          )
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: langProvider.tr('search_product_sku_hint'),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (val) => productProvider.setSearchQuery(val),
            ),
          ),

          // Products ListView
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: productProvider.filteredProducts.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final product = productProvider.filteredProducts[index];
                final isUrl = product.imageUrl.startsWith('http://') || product.imageUrl.startsWith('https://');

                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: isUrl
                        ? Image.network(
                            product.imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 50,
                              height: 50,
                              color: Colors.indigo.shade50,
                              child: const Icon(Icons.fastfood, color: Colors.indigo),
                            ),
                          )
                        : Container(
                            width: 50,
                            height: 50,
                            color: Colors.indigo.shade50,
                            child: const Icon(Icons.image, color: Colors.indigo),
                          ),
                  ),
                  title: Text(product.getLocalizedName(langProvider), style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    '${langProvider.tr("sku")}: ${product.sku} | ${langProvider.tr("variant")}: ${product.getLocalizedVariant(langProvider)}\n${langProvider.tr("price")}: ${currencyFormatter.format(product.sellPrice)} | ${langProvider.tr("cost")}: ${currencyFormatter.format(product.costPrice)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Reorder Move Buttons (Up / Down)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: index > 0 ? () => productProvider.moveUp(product.id) : null,
                            child: Icon(
                              Icons.keyboard_arrow_up,
                              size: 20,
                              color: index > 0 ? Colors.indigo : Colors.grey.shade300,
                            ),
                          ),
                          InkWell(
                            onTap: index < productProvider.filteredProducts.length - 1
                                ? () => productProvider.moveDown(product.id)
                                : null,
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              size: 20,
                              color: index < productProvider.filteredProducts.length - 1
                                  ? Colors.indigo
                                  : Colors.grey.shade300,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 6),

                      // Stock Chip Button
                      InkWell(
                        onTap: () => _showStockDialog(context, product, langProvider),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.indigo.shade200),
                          ),
                          child: Text(
                            '${langProvider.tr("stock")}: ${product.stockQty}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo, fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),

                      // Edit Product Button
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.indigo, size: 20),
                        onPressed: () => _showEditProductDialog(context, product, langProvider),
                        tooltip: langProvider.tr('edit_product_tooltip'),
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
                      ),

                      // Delete Product Button
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        onPressed: () => _showDeleteConfirmDialog(context, productProvider, product, langProvider),
                        tooltip: langProvider.tr('delete_product_tooltip'),
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showStockDialog(BuildContext context, Product product, LanguageProvider langProvider) {
    final controller = TextEditingController(text: product.stockQty.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${langProvider.tr("stock_adjustment_title")}: ${product.name}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: langProvider.tr('new_stock_qty')),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(langProvider.tr('cancel'))),
          ElevatedButton(
            onPressed: () {
              final newQty = int.tryParse(controller.text) ?? product.stockQty;
              Provider.of<ProductProvider>(context, listen: false).adjustStock(product.id, newQty);
              Navigator.pop(context);
            },
            child: Text(langProvider.tr('save')),
          )
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, ProductProvider provider, Product product, LanguageProvider langProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(langProvider.tr('delete_product')),
        content: Text(langProvider.tr('confirm_delete', args: {'name': product.name})),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(langProvider.tr('cancel'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              provider.deleteProduct(product.id);
              Navigator.pop(context);
            },
            child: Text(langProvider.tr('delete')),
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog(BuildContext context, LanguageProvider langProvider) {
    final nameCtrl = TextEditingController();
    final variantCtrl = TextEditingController(text: 'Regular');
    final skuCtrl = TextEditingController(text: 'PROD-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}');
    final priceCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    final stockCtrl = TextEditingController(text: '100');
    final unitCtrl = TextEditingController(text: 'Porsi');
    final imageCtrl = TextEditingController(
      text: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=400&q=80',
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.add_box_outlined, color: Colors.indigo),
                const SizedBox(width: 8),
                Text(langProvider.tr('add_product'), style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: nameCtrl, decoration: InputDecoration(labelText: langProvider.tr('product_name'))),
                    TextField(controller: variantCtrl, decoration: InputDecoration(labelText: langProvider.tr('variant_desc'))),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: skuCtrl, decoration: InputDecoration(labelText: langProvider.tr('sku')))),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: unitCtrl, decoration: InputDecoration(labelText: langProvider.tr('unit')))),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: costCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: langProvider.tr('product_cost')))),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: langProvider.tr('product_price')))),
                      ],
                    ),
                    TextField(controller: stockCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: langProvider.tr('initial_stock'))),
                    const SizedBox(height: 12),
                    
                    // Image selector box
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(langProvider.tr('product_photo'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: imageCtrl,
                            decoration: InputDecoration(
                              labelText: langProvider.tr('url_file_path'),
                              hintText: langProvider.tr('photo_hint'),
                              prefixIcon: const Icon(Icons.link, size: 20),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.file_upload_outlined, size: 16),
                            label: Text(langProvider.tr('select_from_device'), style: const TextStyle(fontSize: 12)),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo.shade50, foregroundColor: Colors.indigo),
                            onPressed: () {
                              imageCtrl.text = 'file:///sdcard/Download/produk_sample_${DateTime.now().millisecondsSinceEpoch % 1000}.jpg';
                              setState(() {});
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(langProvider.tr('photo_selected_snack'))),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text(langProvider.tr('cancel'))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                onPressed: () {
                  if (nameCtrl.text.isNotEmpty && priceCtrl.text.isNotEmpty) {
                    final sellPrice = double.tryParse(priceCtrl.text) ?? 10000;
                    final costPrice = double.tryParse(costCtrl.text) ?? (sellPrice * 0.6);
                    final newProd = Product(
                      id: DateTime.now().millisecondsSinceEpoch,
                      categoryId: 1,
                      name: nameCtrl.text.trim(),
                      variant: variantCtrl.text.trim(),
                      sku: skuCtrl.text.trim(),
                      barcode: '899${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
                      stockQty: int.tryParse(stockCtrl.text) ?? 100,
                      unit: unitCtrl.text.trim().isNotEmpty ? unitCtrl.text.trim() : 'Porsi',
                      costPrice: costPrice,
                      sellPrice: sellPrice,
                      imageUrl: imageCtrl.text.trim().isNotEmpty
                          ? imageCtrl.text.trim()
                          : 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=400&q=80',
                    );
                    Provider.of<ProductProvider>(context, listen: false).addProduct(newProd);
                    Navigator.pop(context);
                  }
                },
                child: Text(langProvider.tr('save_product')),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditProductDialog(BuildContext context, Product product, LanguageProvider langProvider) {
    final nameCtrl = TextEditingController(text: product.name);
    final variantCtrl = TextEditingController(text: product.variant);
    final skuCtrl = TextEditingController(text: product.sku);
    final barcodeCtrl = TextEditingController(text: product.barcode);
    final costCtrl = TextEditingController(text: product.costPrice.toInt().toString());
    final priceCtrl = TextEditingController(text: product.sellPrice.toInt().toString());
    final stockCtrl = TextEditingController(text: product.stockQty.toString());
    final unitCtrl = TextEditingController(text: product.unit);
    final imageCtrl = TextEditingController(text: product.imageUrl);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.edit_note, color: Colors.indigo, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('${langProvider.tr("edit_product_tooltip")}: ${product.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(labelText: langProvider.tr('product_name'), border: const OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: variantCtrl,
                      decoration: InputDecoration(labelText: langProvider.tr('variant_desc'), border: const OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: skuCtrl,
                            decoration: InputDecoration(labelText: langProvider.tr('sku'), border: const OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: barcodeCtrl,
                            decoration: InputDecoration(labelText: langProvider.tr('barcode'), border: const OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: costCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(labelText: langProvider.tr('product_cost'), border: const OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: priceCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(labelText: langProvider.tr('product_price'), border: const OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: stockCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(labelText: langProvider.tr('product_stock'), border: const OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: unitCtrl,
                            decoration: InputDecoration(labelText: langProvider.tr('unit_desc'), border: const OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Foto Upload Container Box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.indigo.shade100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.image, size: 18, color: Colors.indigo),
                              const SizedBox(width: 6),
                              Text(langProvider.tr('change_photo_device'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.indigo)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: imageCtrl,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              labelText: langProvider.tr('url_file_path'),
                              hintText: langProvider.tr('photo_hint'),
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                icon: const Icon(Icons.photo_library_outlined, size: 18),
                                label: Text(langProvider.tr('upload_gallery')),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  imageCtrl.text = 'file:///storage/emulated/0/DCIM/Camera/produk_${product.id}.jpg';
                                  setState(() {});
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(langProvider.tr('photo_success_snack'))),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(langProvider.tr('cancel')),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.save, size: 18),
                label: Text(langProvider.tr('save_changes'), style: const TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (nameCtrl.text.isNotEmpty && priceCtrl.text.isNotEmpty) {
                    final updatedProduct = Product(
                      id: product.id,
                      categoryId: product.categoryId,
                      name: nameCtrl.text.trim(),
                      variant: variantCtrl.text.trim(),
                      sku: skuCtrl.text.trim(),
                      barcode: barcodeCtrl.text.trim(),
                      stockQty: int.tryParse(stockCtrl.text) ?? product.stockQty,
                      unit: unitCtrl.text.trim().isNotEmpty ? unitCtrl.text.trim() : product.unit,
                      costPrice: double.tryParse(costCtrl.text) ?? product.costPrice,
                      sellPrice: double.tryParse(priceCtrl.text) ?? product.sellPrice,
                      imageUrl: imageCtrl.text.trim().isNotEmpty ? imageCtrl.text.trim() : product.imageUrl,
                    );

                    Provider.of<ProductProvider>(context, listen: false).updateProduct(product.id, updatedProduct);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(langProvider.tr('product_updated_snack', args: {'name': updatedProduct.name}))),
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
