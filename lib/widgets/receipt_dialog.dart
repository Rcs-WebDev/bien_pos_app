import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../providers/language_provider.dart';
import '../services/storage_service.dart';
import '../services/bluetooth_printer_service.dart';

class ReceiptDialog extends StatefulWidget {
  final PosTransaction transaction;

  const ReceiptDialog({Key? key, required this.transaction}) : super(key: key);

  @override
  State<ReceiptDialog> createState() => _ReceiptDialogState();
}

class _ReceiptDialogState extends State<ReceiptDialog> {
  String _headerText =
      'BIEN POS\nJl. Malioboro No. 45, Yogyakarta\nTelp: 0812-3456-7890';
  String _footerText = '--- Terima Kasih atas Kunjungan Anda ---';
  bool _isLoading = true;
  int _copyCount = 1;

  @override
  void initState() {
    super.initState();
    _loadReceiptSettings();
  }

  Future<void> _loadReceiptSettings() async {
    final settings = await StorageService.getReceiptSettings();
    setState(() {
      _headerText = settings['header'] ?? _headerText;
      _footerText = settings['footer'] ?? _footerText;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.teal, size: 28),
          const SizedBox(width: 8),
          Text(langProvider.tr('receipt_title'),
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: _isLoading
          ? const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
              child: SizedBox(
                width: 360,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Thermal Receipt Preview Box
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.yellow.shade50.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _headerText,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const Divider(height: 24, thickness: 1),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'No: ${widget.transaction.transactionNo.length > 12 ? widget.transaction.transactionNo.substring(0, 12) + '...' : widget.transaction.transactionNo}',
                                style: const TextStyle(fontSize: 11),
                              ),
                              Text(widget.transaction.createdAt,
                                  style: const TextStyle(fontSize: 11)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${langProvider.tr("cashier")}: ${widget.transaction.cashierName}',
                                  style: const TextStyle(fontSize: 11)),
                              Text(
                                  '${langProvider.tr("customer")}: ${widget.transaction.customerName}',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${langProvider.tr("type")}: ${widget.transaction.orderType}',
                                  style: const TextStyle(fontSize: 11)),
                              Text(langProvider.tr('status_success'),
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal)),
                            ],
                          ),
                          const Divider(height: 24, thickness: 1),

                          // Items List
                          ...widget.transaction.items.map((item) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${item['name']} x${item['qty']}',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    Text(
                                      currencyFormatter.format(
                                          (item['sell_price'] ?? 0) *
                                              (item['qty'] ?? 1)),
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              )),

                          const Divider(height: 24, thickness: 1),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                              Text(
                                  currencyFormatter
                                      .format(widget.transaction.totalAmount),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  '${langProvider.tr("payment_method")}: ${widget.transaction.paymentMethod}',
                                  style: const TextStyle(fontSize: 11)),
                              Text(
                                  '${langProvider.tr("amount_paid_rp")}: ${currencyFormatter.format(widget.transaction.tenderedAmount)}',
                                  style: const TextStyle(fontSize: 11)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${langProvider.tr("change_due_label")}:',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                  currencyFormatter
                                      .format(widget.transaction.changeAmount),
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal)),
                            ],
                          ),

                          const SizedBox(height: 16),
                          Text(
                            _footerText,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                                color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Copy Count Selector Widget
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.copy, size: 16, color: Colors.indigo),
                              const SizedBox(width: 6),
                              Text(langProvider.tr('receipt_copy_count'),
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline,
                                    size: 20),
                                color: Colors.red,
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(4),
                                onPressed: _copyCount > 1
                                    ? () => setState(() => _copyCount--)
                                    : null,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text('$_copyCount',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline,
                                    size: 20),
                                color: Colors.teal,
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(4),
                                onPressed: () => setState(() => _copyCount++),
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
        OutlinedButton.icon(
          icon: const Icon(Icons.print),
          label: Text(_copyCount > 1
              ? langProvider.tr('print_copy', args: {'count': _copyCount.toString()})
              : langProvider.tr('print_receipt')),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.indigo,
            side: const BorderSide(color: Colors.indigo),
          ),
          onPressed: () {
            BluetoothPrinterService().handleReceiptPrint(
              context,
              widget.transaction,
              headerText: _headerText,
              footerText: _footerText,
              copyCount: _copyCount,
            );
          },
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
          child: Text(langProvider.tr('new_transaction')),
        ),
      ],
    );
  }
}
