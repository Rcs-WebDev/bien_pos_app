import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/pos_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/receipt_dialog.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    final posProvider = Provider.of<PosProvider>(context);
    final langProvider = Provider.of<LanguageProvider>(context);
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    final allTransactions = posProvider.transactionsHistory;
    final filteredTransactions = _selectedDate == null
        ? allTransactions
        : allTransactions.where((tx) {
            final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
            return tx.createdAt.contains(dateStr);
          }).toList();

    final totalOmzet = filteredTransactions.fold(0.0, (sum, tx) => sum + tx.totalAmount);

    return Scaffold(
      appBar: AppBar(
        title: Text(langProvider.tr('transactions_title'), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: Column(
        children: [
          // Filter Bar Tanggal
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey.shade50,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_month, color: Colors.indigo, size: 20),
                        label: Text(
                          _selectedDate == null
                              ? langProvider.tr('filter_by_date_all')
                              : langProvider.tr('filter_date_selected', args: {'date': DateFormat('yyyy-MM-dd').format(_selectedDate!)}),
                          style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.indigo.shade200),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setState(() {
                              _selectedDate = picked;
                            });
                          }
                        },
                      ),
                    ),
                    if (_selectedDate != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: langProvider.tr('reset_date_filter'),
                        icon: const Icon(Icons.clear, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _selectedDate = null;
                          });
                        },
                      ),
                    ]
                  ],
                ),
                const SizedBox(height: 8),

                // Ringkasan Total
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        langProvider.tr('total_tx_count_fmt', args: {'count': filteredTransactions.length.toString()}),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                      ),
                      Text(
                        langProvider.tr('total_omzet_fmt', args: {'amount': currencyFormatter.format(totalOmzet)}),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.indigo),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // List Transaksi
          Expanded(
            child: filteredTransactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          _selectedDate == null
                              ? langProvider.tr('no_transactions')
                              : langProvider.tr('no_transactions_date', args: {'date': DateFormat('yyyy-MM-dd').format(_selectedDate!)}),
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredTransactions.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final tx = filteredTransactions[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigo.shade50,
                          child: const Icon(Icons.receipt, color: Colors.indigo),
                        ),
                        title: Text(tx.transactionNo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text('${langProvider.tr("cashier")}: ${tx.cashierName} | ${langProvider.tr("type")}: ${tx.orderType}\n${langProvider.tr("date")}: ${tx.createdAt}'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              currencyFormatter.format(tx.totalAmount),
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.indigo),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                tx.orderType.toUpperCase(),
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.teal.shade700),
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => ReceiptDialog(transaction: tx),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
