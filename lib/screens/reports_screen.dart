import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/pos_provider.dart';
import '../providers/auth_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  double _cogsPercent = 45.0;
  double _opexEstimate = 100000.0;
  DateTime? _selectedReportDate;

  @override
  Widget build(BuildContext context) {
    final posProvider = Provider.of<PosProvider>(context);
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormat = DateFormat('yyyy-MM-dd');

    // Filtered Transactions List based on _selectedReportDate
    final filteredTransactions = _selectedReportDate == null
        ? posProvider.transactionsHistory
        : posProvider.transactionsHistory
            .where((tx) => tx.createdAt.contains(dateFormat.format(_selectedReportDate!)))
            .toList();

    final totalSales = filteredTransactions.fold(0.0, (sum, tx) => sum + tx.totalAmount);
    final totalTxCount = filteredTransactions.length;

    // Payment Method Breakdowns
    final cashTransactions = filteredTransactions.where((tx) => tx.paymentMethod == 'CASH').toList();
    final totalCashSales = cashTransactions.fold(0.0, (sum, tx) => sum + tx.totalAmount);

    final qrisTransactions = filteredTransactions.where((tx) => tx.paymentMethod.contains('QRIS')).toList();
    final totalQrisSales = qrisTransactions.fold(0.0, (sum, tx) => sum + tx.totalAmount);

    // Order Type Breakdowns (Dine-In vs Takeaway)
    final dineInTransactions = filteredTransactions.where((tx) => tx.orderType.toUpperCase().contains('DINE-IN')).toList();
    final totalDineInSales = dineInTransactions.fold(0.0, (sum, tx) => sum + tx.totalAmount);

    final takeawayTransactions = filteredTransactions.where((tx) => tx.orderType.toUpperCase().contains('TAKEAWAY')).toList();
    final totalTakeawaySales = takeawayTransactions.fold(0.0, (sum, tx) => sum + tx.totalAmount);

    // Filtered Calculations for P&L / Income Statement
    final pnlCashFlow = _selectedReportDate == null
        ? posProvider.cashFlowHistory.where((cf) => cf.type == 'Kas Keluar').toList()
        : posProvider.cashFlowHistory
            .where((cf) => cf.type == 'Kas Keluar' && cf.date.contains(dateFormat.format(_selectedReportDate!)))
            .toList();

    final totalDiscountPnl = filteredTransactions.fold(0.0, (sum, tx) => sum + tx.discount);
    final grossRevenue = totalSales + totalDiscountPnl;
    final netRevenue = totalSales;
    final cogsAmount = netRevenue * (_cogsPercent / 100);
    final grossProfit = netRevenue - cogsAmount;
    final totalCashOut = pnlCashFlow.fold(0.0, (sum, cf) => sum + cf.amount);
    final totalOpex = totalCashOut + _opexEstimate;
    final netProfit = grossProfit - totalOpex;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Laporan & Analisis POS', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 1,
          bottom: const TabBar(
            labelColor: Colors.indigo,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.indigo,
            tabs: [
              Tab(icon: Icon(Icons.bar_chart), text: 'Laporan Shift & Metode'),
              Tab(icon: Icon(Icons.show_chart), text: 'Ringkasan Laba Rugi (P&L)'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Universal Date Filter Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.grey.shade100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_month, color: Colors.indigo, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _selectedReportDate == null
                            ? 'Filter Tanggal: Semua Periode'
                            : 'Filter Tanggal: ${dateFormat.format(_selectedReportDate!)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.indigo),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.filter_alt_outlined, size: 16),
                        label: Text(_selectedReportDate == null ? 'Pilih Tanggal' : 'Ubah'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.indigo,
                          side: const BorderSide(color: Colors.indigo),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedReportDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setState(() {
                              _selectedReportDate = picked;
                            });
                          }
                        },
                      ),
                      if (_selectedReportDate != null) ...[
                        const SizedBox(width: 6),
                        IconButton(
                          icon: const Icon(Icons.clear, color: Colors.red, size: 20),
                          tooltip: 'Reset Filter Tanggal',
                          onPressed: () {
                            setState(() {
                              _selectedReportDate = null;
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                children: [
                  // TAB 1: LAPORAN METODE PEMBAYARAN & SHIFT
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row 1: Total Omzet & Total Transaksi
                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryCard(
                                title: 'Total Omzet Penjualan',
                                value: currencyFormatter.format(totalSales),
                                subtitle: 'Keseluruhan metode',
                                icon: Icons.monetization_on_outlined,
                                color: Colors.teal,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildSummaryCard(
                                title: 'Total Transaksi',
                                value: '$totalTxCount Transaksi',
                                subtitle: 'Jumlah struk terbit',
                                icon: Icons.receipt_long,
                                color: Colors.indigo,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Row 2: Total Cash & Total QRIS
                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryCard(
                                title: 'Total Transaksi Cash',
                                value: currencyFormatter.format(totalCashSales),
                                subtitle: '${cashTransactions.length} Transaksi Tunai',
                                icon: Icons.money,
                                color: Colors.green.shade700,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildSummaryCard(
                                title: 'Total Transaksi QRIS',
                                value: currencyFormatter.format(totalQrisSales),
                                subtitle: '${qrisTransactions.length} Transaksi Non-Tunai',
                                icon: Icons.qr_code_2,
                                color: Colors.deepOrange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Row 3: Dine-In vs Takeaway Total
                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryCard(
                                title: 'Total Dine-In',
                                value: currencyFormatter.format(totalDineInSales),
                                subtitle: '${dineInTransactions.length} Pesanan Makan di Tempat',
                                icon: Icons.restaurant,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildSummaryCard(
                                title: 'Total Takeaway',
                                value: currencyFormatter.format(totalTakeawaySales),
                                subtitle: '${takeawayTransactions.length} Pesanan Bawa Pulang',
                                icon: Icons.takeout_dining,
                                color: Colors.purple.shade700,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Penutupan Shift Kasir', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    SizedBox(height: 2),
                                    Text('Rekap omzet, QRIS, & tunai shift ini', style: TextStyle(color: Colors.black54, fontSize: 12)),
                                  ],
                                ),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.lock_clock),
                                  label: const Text('Tutup Shift'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: () => _showShiftClosingDialog(context, posProvider),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text('Riwayat Penutupan Shift', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 12),
                        posProvider.shiftClosingsHistory.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Text('Belum ada penutupan shift recorded', style: TextStyle(color: Colors.grey.shade500)),
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: posProvider.shiftClosingsHistory.length,
                                separatorBuilder: (context, index) => const Divider(),
                                itemBuilder: (context, index) {
                                  final closing = posProvider.shiftClosingsHistory[index];
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.indigo.shade50,
                                      child: const Icon(Icons.history_outlined, color: Colors.indigo),
                                    ),
                                    title: Text('${closing.shiftNo} - ${closing.employeeName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text(
                                      'Omzet: ${currencyFormatter.format(closing.totalSales)} | Tunai: ${currencyFormatter.format(closing.cashSales)} | QRIS: ${currencyFormatter.format(closing.qrisSales)}\nWaktu: ${closing.createdAt}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),

                  // TAB 2: LAPORAN RINGKASAN LABA RUGI (INCOME STATEMENT)
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Laporan Ringkasan Laba Rugi',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '(Income Statement / P&L)',
                                      style: TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_note, color: Colors.indigo),
                                  onPressed: () => _showEditPnlDialog(context),
                                ),
                              ],
                            ),
                            const Divider(height: 24),

                            // 1. PENDAPATAN OPERASIONAL
                            _buildPnlSectionTitle('1. PENDAPATAN OPERASIONAL'),
                            _buildPnlRow('Penjualan Kotor Kasir POS', currencyFormatter.format(grossRevenue)),
                            _buildPnlRow('Potongan Diskon Pesanan', '- ${currencyFormatter.format(totalDiscountPnl)}'),
                            const SizedBox(height: 4),
                            _buildPnlSubtotalRow('PENDAPATAN BERSIH (NET REVENUE)', currencyFormatter.format(netRevenue), Colors.blue.shade700),

                            const SizedBox(height: 16),

                            // 2. HARGA POKOK PENJUALAN (HPP / COGS)
                            _buildPnlSectionTitle('2. HARGA POKOK PENJUALAN (HPP / COGS)'),
                            _buildPnlRow('Biaya Bahan Baku Terpakai (${_cogsPercent.toInt()}%)', '- ${currencyFormatter.format(cogsAmount)}'),
                            const SizedBox(height: 4),
                            _buildPnlSubtotalRow('LABA KOTOR (GROSS PROFIT)', currencyFormatter.format(grossProfit), Colors.teal.shade700),

                            const SizedBox(height: 16),

                            // 3. BEBAN OPERASIONAL (OPEX)
                            _buildPnlSectionTitle('3. BEBAN OPERASIONAL (OPEX)'),
                            _buildPnlRow('Pengeluaran Kas Keluar (Petty Cash)', '- ${currencyFormatter.format(totalCashOut)}'),
                            _buildPnlRow('Estimasi Gaji & Operasional', '- ${currencyFormatter.format(_opexEstimate)}'),
                            const SizedBox(height: 4),
                            _buildPnlSubtotalRow('TOTAL BEBAN OPERASIONAL', '- ${currencyFormatter.format(totalOpex)}', Colors.orange.shade800),

                            const SizedBox(height: 20),

                            // 4. NET PROFIT BOX
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: netProfit >= 0 ? Colors.green.shade50 : Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: netProfit >= 0 ? Colors.green.shade300 : Colors.red.shade300,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'LABA / (RUGI) BERSIH RESTO\n(NET PROFIT)',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: netProfit >= 0 ? Colors.green.shade900 : Colors.red.shade900,
                                    ),
                                  ),
                                  Text(
                                    currencyFormatter.format(netProfit),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: netProfit >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 11, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _buildPnlSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
      ),
    );
  }

  Widget _buildPnlRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildPnlSubtotalRow(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      color: Colors.grey.shade100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }

  void _showEditPnlDialog(BuildContext context) {
    final cogsCtrl = TextEditingController(text: _cogsPercent.toInt().toString());
    final opexCtrl = TextEditingController(text: _opexEstimate.toInt().toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pengaturan Parameter P&L'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: cogsCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Persentase Estimasi HPP / COGS (%)',
                hintText: 'Misal: 45',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: opexCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Estimasi Beban Operasional OPEX (Rp)',
                hintText: 'Misal: 100000',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
            onPressed: () {
              setState(() {
                _cogsPercent = double.tryParse(cogsCtrl.text) ?? _cogsPercent;
                _opexEstimate = double.tryParse(opexCtrl.text) ?? _opexEstimate;
              });
              Navigator.pop(context);
            },
            child: const Text('SIMPAN'),
          ),
        ],
      ),
    );
  }

  void _showShiftClosingDialog(BuildContext context, PosProvider posProvider) {
    final notesCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Tutup Shift Kasir'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kasir Aktif: ${posProvider.cashierName}'),
            const SizedBox(height: 12),
            TextField(
              controller: notesCtrl,
              decoration: const InputDecoration(labelText: 'Catatan Penutupan Shift (Opsional)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
            onPressed: () async {
              final closing = await posProvider.closeShift(notesCtrl.text.trim(), 0.0);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Shift ${closing.shiftNo} berhasil ditutup!')),
              );
            },
            child: const Text('PROSES TUTUP SHIFT'),
          ),
        ],
      ),
    );
  }
}
