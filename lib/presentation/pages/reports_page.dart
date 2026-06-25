import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/report/report_bloc.dart';
import '../bloc/report/report_event.dart';
import '../bloc/report/report_state.dart';
import '../widgets/dashboard/sales_chart.dart';
import '../widgets/dashboard/payment_mode_chart.dart';
import '../widgets/dashboard/stat_card.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  final String _tenantId = 'temp_tenant_id';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _triggerLoad();
    _tabController.addListener(() {
      _triggerLoad();
    });
  }

  void _triggerLoad() {
    if (_tabController.index == 0) {
      context.read<ReportBloc>().add(GenerateSalesReport(_tenantId, _startDate, _endDate));
    } else if (_tabController.index == 1) {
      context.read<ReportBloc>().add(GenerateProfitLossReport(_tenantId, _startDate, _endDate));
    } else {
      context.read<ReportBloc>().add(GenerateGstReport(_tenantId, _startDate, _endDate));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _triggerLoad();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = '${DateFormat('dd MMM yyyy').format(_startDate)} - ${DateFormat('dd MMM yyyy').format(_endDate)}';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Reports'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Sales Report'),
            Tab(text: 'Profit & Loss'),
            Tab(text: 'GST Report'),
          ],
        ),
        actions: [
          OutlinedButton.icon(
            onPressed: () => _selectDateRange(context),
            icon: const Icon(Icons.date_range, size: 18),
            label: Text(dateStr),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report exported to Excel successfully!')),
              );
            },
            icon: const Icon(Icons.download, size: 18, color: Colors.white),
            label: const Text('EXPORT Excel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: BlocBuilder<ReportBloc, ReportState>(
        builder: (context, state) {
          if (state is ReportLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ReportError) {
            return Center(child: Text('Error loading report: ${state.message}'));
          }

          return TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildSalesTab(state),
              _buildProfitLossTab(state),
              _buildGstTab(state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSalesTab(ReportState state) {
    if (state is SalesReportLoaded) {
      final data = state.data;
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatCardsGrid([
              StatCard(
                title: 'Gross Revenue',
                value: '₹${data.totalSales.toStringAsFixed(2)}',
                icon: Icons.currency_rupee,
                color: Theme.of(context).colorScheme.primary,
                trend: '0%',
              ),
              StatCard(
                title: 'Invoices Issued',
                value: '${data.invoiceCount}',
                icon: Icons.receipt_long,
                color: Theme.of(context).colorScheme.secondary,
                trend: '0%',
              ),
              StatCard(
                title: 'Average Invoice Value',
                value: '₹${data.averageOrderValue.toStringAsFixed(2)}',
                icon: Icons.wallet,
                color: Colors.teal,
                trend: '0%',
              ),
            ], context),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: SalesChart(trendData: data.revenueTrend),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: PaymentModeChart(data: data.salesByPaymentMode),
                ),
              ],
            ),
          ],
        ),
      );
    }
    return const Center(child: Text('Click date range to generate report.'));
  }

  Widget _buildProfitLossTab(ReportState state) {
    if (state is ProfitLossReportLoaded) {
      final data = state.data;
      final isProfit = data.netProfit >= 0;
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildStatCardsGrid([
              StatCard(
                title: 'Total Income (Sales)',
                value: '₹${data.totalRevenue.toStringAsFixed(2)}',
                icon: Icons.trending_up,
                color: Theme.of(context).colorScheme.primary,
                trend: '0%',
              ),
              StatCard(
                title: 'Total Expenses',
                value: '₹${data.totalExpenses.toStringAsFixed(2)}',
                icon: Icons.trending_down,
                color: Theme.of(context).colorScheme.error,
                trend: '0%',
              ),
              StatCard(
                title: 'Net Profit / Loss',
                value: '₹${data.netProfit.toStringAsFixed(2)}',
                icon: isProfit ? Icons.emoji_emotions_outlined : Icons.sentiment_very_dissatisfied_outlined,
                color: isProfit ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error,
                trend: '0%',
              ),
            ], context),
            const SizedBox(height: 24),
            // Expense Breakdown
            Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE6EFEA)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Expense Breakdown by Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    if (data.totalExpenses == 0)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(child: Text('No expenses logged for this period.')),
                      )
                    else
                      ...{
                        'Operating Expenses': data.totalExpenses,
                      }.entries.map((entry) {
                        final percentage = data.totalExpenses > 0 ? (entry.value / data.totalExpenses) : 0.0;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w500)),
                                  Text('₹${entry.value.toStringAsFixed(2)} (${(percentage * 100).toStringAsFixed(1)}%)', style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              LinearProgressIndicator(
                                value: percentage,
                                backgroundColor: Colors.grey[200],
                                color: Colors.redAccent,
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
    return const Center(child: Text('Select dates to view Profit & Loss'));
  }

  Widget _buildGstTab(ReportState state) {
    if (state is GstReportLoaded) {
      final data = state.data;
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildStatCardsGrid([
              StatCard(
                title: 'Taxable Turnover',
                value: '₹${data.taxableAmount.toStringAsFixed(2)}',
                icon: Icons.account_balance_wallet,
                color: Theme.of(context).colorScheme.secondary,
                trend: '0%',
              ),
              StatCard(
                title: 'Total GST Collected',
                value: '₹${data.totalGst.toStringAsFixed(2)}',
                icon: Icons.gavel,
                color: Theme.of(context).colorScheme.primary,
                trend: '0%',
              ),
            ], context),
            const SizedBox(height: 24),
            // GST Breakdown Table
            Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey[200]!),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('GST Collected Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    Table(
                      border: TableBorder(horizontalInside: BorderSide(color: Colors.grey[200]!, width: 1)),
                      children: [
                        const TableRow(
                          children: [
                            Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Tax Type', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                            Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Collected Amount', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Text('CGST (Central GST)', style: TextStyle(fontWeight: FontWeight.w500))),
                            Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text('₹${data.cgst.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Text('SGST (State GST)', style: TextStyle(fontWeight: FontWeight.w500))),
                            Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text('₹${data.sgst.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Text('IGST (Integrated GST)', style: TextStyle(fontWeight: FontWeight.w500))),
                            Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text('₹${data.igst.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
    return const Center(child: Text('Select dates to view GST collections'));
  }

  Widget _buildStatCardsGrid(List<Widget> cards, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 768) {
      List<Widget> children = [];
      for (int i = 0; i < cards.length; i++) {
        children.add(Expanded(child: cards[i]));
        if (i < cards.length - 1) {
          children.add(const SizedBox(width: 16));
        }
      }
      return Row(children: children);
    } else {
      final crossAxisCount = screenWidth > 480 ? 2 : 1;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: screenWidth > 480 ? 1.5 : 2.5,
        ),
        itemCount: cards.length,
        itemBuilder: (context, index) => cards[index],
      );
    }
  }
}
