import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/dashboard/stat_card.dart';
import '../widgets/dashboard/sales_chart.dart';
import '../widgets/dashboard/payment_mode_chart.dart';
import '../bloc/report/report_bloc.dart';
import '../bloc/report/report_event.dart';
import '../bloc/report/report_state.dart';
import '../../domain/entities/report_data.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<ReportBloc>().add(GenerateSalesReport(
      'temp_tenant_id', 
      DateTime.now().subtract(const Duration(days: 30)), 
      DateTime.now(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () {
              context.read<ReportBloc>().add(GenerateSalesReport(
                'temp_tenant_id', 
                DateTime.now().subtract(const Duration(days: 30)), 
                DateTime.now(),
              ));
            },
          ),
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFF006C47),
            child: Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: BlocBuilder<ReportBloc, ReportState>(
        builder: (context, state) {
          if (state is ReportLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SalesReportLoaded) {
            final data = state.data;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Business Analytics',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  
                  // Stats Grid
                  LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: constraints.maxWidth > 600 ? 1.4 : 1.1,
                        children: [
                           StatCard(
                            title: 'Total Revenue',
                            value: '₹${data.totalSales.toStringAsFixed(0)}',
                            icon: Icons.currency_rupee,
                            color: Theme.of(context).colorScheme.primary,
                            trend: '12%',
                          ),
                          StatCard(
                            title: 'Total Sales',
                            value: '${data.invoiceCount}',
                            icon: Icons.shopping_bag_outlined,
                            color: Theme.of(context).colorScheme.secondary,
                            trend: '8%',
                          ),
                          StatCard(
                            title: 'Avg. Order',
                            value: '₹${data.averageOrderValue.toStringAsFixed(0)}',
                            icon: Icons.analytics_outlined,
                            color: Colors.teal,
                            trend: '5%',
                          ),
                          StatCard(
                            title: 'Low Stock',
                            value: '0',
                            icon: Icons.warning_amber_rounded,
                            color: Theme.of(context).colorScheme.error,
                            trend: '0%',
                            isPositive: false,
                          ),
                        ],
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(flex: 2, child: SalesChart(trendData: data.revenueTrend)),
                      const SizedBox(width: 24),
                      Expanded(child: PaymentModeChart(data: data.salesByPaymentMode)),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildRecentTransactions(context, data.recentTransactions),
                      ),
                      if (MediaQuery.of(context).size.width > 900) ...[
                        const SizedBox(width: 24),
                        Expanded(
                          child: _buildTopProducts(context, data.topProducts),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('Generate report to see analytics'));
        },
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context, List<RecentTransaction> transactions) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6EFEA), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
              TextButton(
                onPressed: () {}, 
                child: Text('View All', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (transactions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'No recent transactions found',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            )
          else
            ...transactions.map((tx) {
              Color statusColor;
              switch (tx.status.toLowerCase()) {
                case 'paid':
                  statusColor = const Color(0xFF006C47);
                  break;
                case 'pending':
                  statusColor = Colors.orange;
                  break;
                default:
                  statusColor = Colors.red;
              }
              return _transactionItem(tx.customerName, tx.invoiceId, '₹${tx.amount.toStringAsFixed(0)}', tx.status, statusColor);
            }),
        ],
      ),
    );
  }

  Widget _transactionItem(String name, String id, String amount, String status, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFE1F5EC), 
            child: Text(name.isNotEmpty ? name[0] : 'U', style: const TextStyle(color: Color(0xFF006C47), fontWeight: FontWeight.bold))
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(id, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopProducts(BuildContext context, List<TopProductItem> products) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6EFEA), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Top Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
          const SizedBox(height: 20),
          if (products.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'No top products sold yet',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            )
          else
            ...products.map((p) => _productItem(context, p.name, '${p.quantitySold.toStringAsFixed(0)} sold', '₹${p.revenue.toStringAsFixed(0)}')),
        ],
      ),
    );
  }

  Widget _productItem(BuildContext context, String name, String sold, String revenue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(sold, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
          Text(revenue, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
        ],
      ),
    );
  }
}
