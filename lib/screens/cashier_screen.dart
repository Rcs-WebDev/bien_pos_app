import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/pos_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/cart_drawer.dart';

class CashierScreen extends StatelessWidget {
  const CashierScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final posProvider = Provider.of<PosProvider>(context);
    final isTabletLandscape = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      body: Row(
        children: [
          // Left Main Content: Products Grid & Search & Category Filter
          Expanded(
            flex: 3,
            child: Column(
              children: [
                // Top Search Bar & Category Filter
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.white,
                  child: Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Cari Produk, SKU, atau Scan Barcode...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: const Icon(Icons.qr_code_scanner),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onChanged: (val) => productProvider.setSearchQuery(val),
                      ),
                      const SizedBox(height: 8),

                      // Category Horizontal ListView
                      SizedBox(
                        height: 38,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: productProvider.categories.length,
                          itemBuilder: (context, index) {
                            final cat = productProvider.categories[index];
                            final isSelected = productProvider.selectedCategory == cat.id;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(cat.label),
                                selected: isSelected,
                                selectedColor: Colors.indigo,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black87,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                                onSelected: (selected) {
                                  if (selected) productProvider.setCategory(cat.id);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Products Grid
                Expanded(
                  child: productProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : productProvider.filteredProducts.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade300),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Tidak ada produk ditemukan',
                                    style: TextStyle(color: Colors.grey.shade500),
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.all(12),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isTabletLandscape ? 3 : 2,
                                childAspectRatio: 0.8,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: productProvider.filteredProducts.length,
                              itemBuilder: (context, index) {
                                final product = productProvider.filteredProducts[index];
                                return ProductCard(
                                  product: product,
                                  onTap: () => posProvider.addToCart(product),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),

          // Right Cart Panel (If Landscape/Tablet)
          if (isTabletLandscape)
            const SizedBox(
              width: 360,
              child: CartDrawer(),
            ),
        ],
      ),

      // Floating Action Button for Cart (On Mobile View)
      floatingActionButton: isTabletLandscape
          ? null
          : FloatingActionButton.extended(
              backgroundColor: Colors.indigo,
              icon: const Icon(Icons.shopping_cart, color: Colors.white),
              label: Text(
                'Keranjang (${posProvider.totalItemsCount})',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) => const SizedBox(
                    height: 550,
                    child: CartDrawer(),
                  ),
                );
              },
            ),
    );
  }
}
