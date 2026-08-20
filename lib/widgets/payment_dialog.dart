import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/pos_provider.dart';
import '../providers/product_provider.dart';
import '../providers/language_provider.dart';
import 'receipt_dialog.dart';

class PaymentDialog extends StatefulWidget {
  const PaymentDialog({Key? key}) : super(key: key);

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  final TextEditingController _tenderedController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final posProvider = Provider.of<PosProvider>(context, listen: false);
    _tenderedController.text = posProvider.totalAmount.toInt().toString();
  }

  @override
  Widget build(BuildContext context) {
    final posProvider = Provider.of<PosProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final langProvider = Provider.of<LanguageProvider>(context);
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(langProvider.tr('payment_title'), style: const TextStyle(fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Tagihan Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.indigo.shade100),
                ),
                child: Column(
                  children: [
                    Text(langProvider.tr('total_due_banner'), style: const TextStyle(fontSize: 12, color: Colors.indigo)),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormatter.format(posProvider.totalAmount),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.indigo),
                    ),
                  ],
                ),
              ),

              // Input Nama Customer
              Text(langProvider.tr('customer_name'), style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  hintText: langProvider.tr('customer_name_hint'),
                  prefixIcon: const Icon(Icons.person_outline, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (val) => posProvider.setCustomerName(val),
              ),

              const SizedBox(height: 16),
              Text(langProvider.tr('payment_method'), style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      avatar: const Icon(Icons.money, size: 18),
                      label: Text(langProvider.tr('cash')),
                      selected: posProvider.selectedPaymentMethod == 'CASH',
                      onSelected: (selected) {
                        if (selected) posProvider.setPaymentMethod('CASH');
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      avatar: const Icon(Icons.qr_code, size: 18),
                      label: Text(langProvider.tr('qris_bca')),
                      selected: posProvider.selectedPaymentMethod == 'QRIS_BCA',
                      onSelected: (selected) {
                        if (selected) posProvider.setPaymentMethod('QRIS_BCA');
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Text(langProvider.tr('amount_paid_rp'), style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              TextField(
                controller: _tenderedController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (val) {
                  final amount = double.tryParse(val) ?? 0.0;
                  posProvider.setTenderedAmount(amount);
                },
              ),

              const SizedBox(height: 12),
              // Quick Cash Preset Chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  posProvider.totalAmount,
                  50000.0,
                  100000.0,
                  200000.0,
                ].map((val) {
                  return ActionChip(
                    label: Text(currencyFormatter.format(val)),
                    onPressed: () {
                      _tenderedController.text = val.toInt().toString();
                      posProvider.setTenderedAmount(val);
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),
              // Kembalian Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(langProvider.tr('change_due_label'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                    Text(
                      currencyFormatter.format(posProvider.changeAmount),
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal.shade800),
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
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () async {
            final tx = await posProvider.submitPayment(productProvider);
            if (tx != null) {
              Navigator.pop(context); // Close Payment Dialog
              showDialog(
                context: context,
                builder: (context) => ReceiptDialog(transaction: tx),
              );
            }
          },
          child: Text(langProvider.tr('finish_transaction_btn'), style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
