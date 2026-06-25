import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../bloc/customer/customer_bloc.dart';
import '../bloc/customer/customer_event.dart';
import '../bloc/customer/customer_state.dart';
import '../../domain/entities/customer.dart';

enum PanelState { billingHistory, paymentMethod, paymentSuccess }

class MockBill {
  final String id;
  final String title;
  final double amount;
  final String paidDate;
  final String status;

  MockBill({
    required this.id,
    required this.title,
    required this.amount,
    required this.paidDate,
    required this.status,
  });
}


class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _searchBillController = TextEditingController();
  Customer? _selectedCustomer;

  String _selectedFilter = 'all';
  bool _showDetailsOnMobile = false;
  PanelState _panelState = PanelState.billingHistory;
  String _selectedPaymentMethod = 'card';
  double _settleAmount = 0.0;
  String _trxId = '';
  String _paymentDate = '';
  String _searchBillQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(const LoadCustomers('temp_tenant_id'));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchBillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Management'),
        actions: [
          ElevatedButton.icon(
            onPressed: () => _showAddCustomerDialog(context),
            icon: const Icon(Icons.person_add, color: Colors.white),
            label: const Text('ADD CUSTOMER', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: isMobile
          ? (_showDetailsOnMobile && _selectedCustomer != null
              ? BlocBuilder<CustomerBloc, CustomerState>(
                  builder: (context, state) {
                    Customer currentCustomer = _selectedCustomer!;
                    if (state is CustomersLoaded) {
                      final matches = state.customers.where((c) => c.id == _selectedCustomer!.id);
                      if (matches.isNotEmpty) {
                        currentCustomer = matches.first;
                      }
                    }
                    return _buildDetailsPanel(context, currentCustomer);
                  },
                )
              : _buildLeftPanel(context))
          : Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildLeftPanel(context),
                ),
                Expanded(
                  flex: 2,
                  child: BlocBuilder<CustomerBloc, CustomerState>(
                    builder: (context, state) {
                      if (_selectedCustomer == null) {
                        return const Center(child: Text('Select a customer to view details'));
                      }
                      Customer currentCustomer = _selectedCustomer!;
                      if (state is CustomersLoaded) {
                        final matches = state.customers.where((c) => c.id == _selectedCustomer!.id);
                        if (matches.isNotEmpty) {
                          currentCustomer = matches.first;
                        }
                      }
                      return _buildDetailsPanel(context, currentCustomer);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLeftPanel(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: TextField(
            controller: _searchController,
            onChanged: (val) {
              context.read<CustomerBloc>().add(SearchCustomers('temp_tenant_id', val));
            },
            decoration: const InputDecoration(
              hintText: 'Search by name or phone number...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        _buildFilterChips(),
        Expanded(
          child: BlocBuilder<CustomerBloc, CustomerState>(
            builder: (context, state) {
              if (state is CustomerLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is CustomersLoaded) {
                var customers = state.customers;

                // Apply filter
                if (_selectedFilter == 'balance') {
                  customers = customers.where((c) => c.creditBalance > 0).toList();
                } else if (_selectedFilter == 'loyal') {
                  customers = customers.where((c) => c.loyaltyPoints > 50).toList();
                  // Sort loyal customers by points descending
                  customers.sort((a, b) => b.loyaltyPoints.compareTo(a.loyaltyPoints));
                }

                if (customers.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        'No customers found matching the filter',
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: customers.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    final isSelected = _selectedCustomer?.id == customer.id;
                    final hasDue = customer.creditBalance > 0;
                    final primaryColor = Theme.of(context).colorScheme.primary;

                    return Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? primaryColor : const Color(0xFFE6EFEA),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        onTap: () {
                          setState(() {
                            _selectedCustomer = customer;
                            _panelState = PanelState.billingHistory;
                            _showDetailsOnMobile = true;
                          });
                        },
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isSelected
                                  ? [primaryColor, primaryColor.withOpacity(0.8)]
                                  : [const Color(0xFFF0F7F4), const Color(0xFFE1EFE8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              customer.name[0].toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isSelected ? Colors.white : primaryColor,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          customer.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Row(
                            children: [
                              const Icon(Icons.phone_outlined, size: 12, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                customer.phoneNumber,
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: hasDue ? const Color(0xFFFEF2F2) : const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                hasDue
                                    ? 'Due: ₹${customer.creditBalance.toStringAsFixed(2)}'
                                    : 'No Due',
                                style: TextStyle(
                                  color: hasDue ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star, color: Color(0xFFD48C00), size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  '${customer.loyaltyPoints} Pts',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
              return const Center(child: Text('Add customers to list'));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsPanel(BuildContext context, Customer customer) {
    switch (_panelState) {
      case PanelState.billingHistory:
        return _buildBillingHistoryView(context, customer);
      case PanelState.paymentMethod:
        return _buildPaymentMethodView(context, customer);
      case PanelState.paymentSuccess:
        return _buildPaymentSuccessView(context, customer);
    }
  }

  Widget _buildBillingHistoryView(BuildContext context, Customer customer) {
    final mockBills = _getMockBills(customer);
    final filteredBills = mockBills.where((bill) {
      if (_searchBillQuery.isEmpty) return true;
      final q = _searchBillQuery.toLowerCase();
      return bill.title.toLowerCase().contains(q) || bill.id.toLowerCase().contains(q);
    }).toList();

    final nextPaymentId = 'BILL-${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header Row
          Row(
            children: [
              if (MediaQuery.of(context).size.width < 768) ...[
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _showDetailsOnMobile = false;
                    });
                  },
                ),
                const SizedBox(width: 8),
              ],
              CircleAvatar(
                radius: 28,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  customer.name[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customer.phoneNumber,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.grey),
                onPressed: () => _showEditCustomerDialog(context, customer),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => _showDeleteConfirmDialog(context, customer),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Collapsible Details
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: const Text(
                'Contact Details',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF4A5D54)),
              ),
              leading: const Icon(Icons.contact_phone_outlined, size: 20, color: Color(0xFF4A5D54)),
              dense: true,
              tilePadding: EdgeInsets.zero,
              children: [
                _detailRow(Icons.email_outlined, 'Email', customer.email ?? 'Not provided'),
                _detailRow(Icons.location_on_outlined, 'Address', customer.address ?? 'Not provided'),
                _detailRow(Icons.stars_outlined, 'Loyalty Points', '${customer.loyaltyPoints} pts'),
              ],
            ),
          ),
          const Divider(),
          const SizedBox(height: 16),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Billing History',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF141C18)),
                  ),
                  const SizedBox(height: 16),
                  
                  // Next Payment Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Next Payment',
                              style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3E8FF),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Basic',
                                style: TextStyle(
                                  color: Color(0xFF7E22CE),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '₹${customer.creditBalance.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                            ),
                            Text(
                              'Due - $nextPaymentId',
                              style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: customer.creditBalance > 0
                                    ? () {
                                        setState(() {
                                          _settleAmount = customer.creditBalance;
                                          _panelState = PanelState.paymentMethod;
                                        });
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E293B),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  elevation: 0,
                                  disabledBackgroundColor: Colors.grey[200],
                                  disabledForegroundColor: Colors.grey[400],
                                ),
                                child: const Text('Pay Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.receipt_long_outlined, color: Color(0xFF64748B)),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Displaying latest statement...')),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Payment History Section
                  const Text(
                    'Payment History',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF141C18)),
                  ),
                  const SizedBox(height: 12),
                  
                  // Search Bar
                  TextField(
                    controller: _searchBillController,
                    onChanged: (val) {
                      setState(() {
                        _searchBillQuery = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search bills...',
                      prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Bills List
                  if (filteredBills.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Text('No invoices found', style: TextStyle(color: Colors.grey)),
                      ),
                    )
                  else
                    ...filteredBills.map((bill) => Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF1F5F9),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.receipt_outlined, color: Color(0xFF64748B), size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          bill.title,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          bill.id,
                                          style: TextStyle(color: Colors.grey[600], fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFECFDF5),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'Paid',
                                      style: TextStyle(
                                        color: Color(0xFF10B981),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Amount', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                      const SizedBox(height: 2),
                                      Text(
                                        '₹${bill.amount.toStringAsFixed(2)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text('Paid on', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                      const SizedBox(height: 2),
                                      Text(
                                        bill.paidDate,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Displaying invoice ${bill.id}...')),
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        backgroundColor: const Color(0xFFF1F5F9),
                                        foregroundColor: const Color(0xFF334155),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                      ),
                                      child: const Text('View Invoice', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.download_outlined, color: Color(0xFF334155), size: 18),
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Downloading invoice ${bill.id} PDF...')),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodView(BuildContext context, Customer customer) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _panelState = PanelState.billingHistory;
                  });
                },
              ),
              const SizedBox(width: 8),
              const Text(
                'Payment',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF141C18)),
              ),
              const Spacer(),
              Icon(Icons.headset_mic_outlined, color: Colors.grey[600]),
            ],
          ),
          const SizedBox(height: 20),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPaymentSummaryCard(customer),
                  const SizedBox(height: 24),
                  
                  const Text(
                    'Payment Method',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF141C18)),
                  ),
                  const SizedBox(height: 12),
                  
                  _buildPaymentMethodCard(
                    title: 'Credit/Debit Card',
                    subtitle: 'Visa/Mastercard',
                    icon: Icons.credit_card_outlined,
                    value: 'card',
                  ),
                  _buildPaymentMethodCard(
                    title: 'Mobile Banking',
                    subtitle: 'UPI / GPay / Netbanking',
                    icon: Icons.phone_android_outlined,
                    value: 'upi',
                  ),
                  _buildPaymentMethodCard(
                    title: 'Digital Wallet',
                    subtitle: 'Paytm / Amazon Pay',
                    icon: Icons.account_balance_wallet_outlined,
                    value: 'wallet',
                  ),
                  _buildPaymentMethodCard(
                    title: 'Cash / Offline',
                    subtitle: 'Pay with Cash / Check',
                    icon: Icons.payments_outlined,
                    value: 'cash',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          ElevatedButton(
            onPressed: () {
              final settleAmount = _settleAmount;
              final updated = Customer(
                id: customer.id,
                tenantId: customer.tenantId,
                name: customer.name,
                phoneNumber: customer.phoneNumber,
                email: customer.email,
                address: customer.address,
                creditBalance: (customer.creditBalance - settleAmount).clamp(0, double.infinity),
                loyaltyPoints: customer.loyaltyPoints + (settleAmount ~/ 100),
                createdAt: customer.createdAt,
              );
              
              context.read<CustomerBloc>().add(UpdateCustomerEvent(updated));
              
              _trxId = 'TXN${const Uuid().v4().substring(0, 8).toUpperCase()}';
              _paymentDate = DateFormat('d MMM, yyyy - h:mm a').format(DateTime.now());
              
              setState(() {
                _selectedCustomer = updated;
                _panelState = PanelState.paymentSuccess;
              });
              
              context.read<CustomerBloc>().add(LoadCustomers(customer.tenantId));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E293B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              minimumSize: const Size(double.infinity, 50),
              elevation: 0,
            ),
            child: const Text('Proceed to Pay', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummaryCard(Customer customer) {
    final billingMonth = DateFormat('MMMM yyyy').format(DateTime.now());
    final billId = 'BILL-${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    billingMonth,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    billId,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Basic',
                  style: TextStyle(
                    color: Color(0xFF7E22CE),
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Amount', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    '₹${_settleAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                ],
              ),
              Text(
                'Due - $billId',
                style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.verified_user_outlined, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                'Secure Payment',
                style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
  }) {
    final isSelected = _selectedPaymentMethod == value;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryColor : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor.withOpacity(0.1) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? primaryColor : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? primaryColor : const Color(0xFFCBD5E1),
                  width: 2,
                ),
                color: isSelected ? primaryColor : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 12,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSuccessView(BuildContext context, Customer customer) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),
          // Success Graphic Illustration
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
                  ),
                ),
                Container(
                  width: 80,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 40, height: 6, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(3))),
                        Container(width: 30, height: 6, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(3))),
                        Container(width: 50, height: 6, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(3))),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(Icons.edit, size: 14, color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Payment Success',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF141C18)),
          ),
          const SizedBox(height: 12),
          Text(
            "We've successfully received your payment, and your account balance has been updated.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 32),
          _buildSuccessDetailsCard(),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _panelState = PanelState.billingHistory;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E293B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              minimumSize: const Size(double.infinity, 50),
              elevation: 0,
            ),
            child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          _buildSuccessDetailRow('Amount', '₹${_settleAmount.toStringAsFixed(2)}', isBold: true),
          const Divider(height: 24),
          _buildSuccessDetailRow('TrxID', _trxId),
          const Divider(height: 24),
          _buildSuccessDetailRow('Date', _paymentDate),
          const Divider(height: 24),
          _buildSuccessDetailRow(
            'Status',
            'Paid',
            customValueWidget: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Paid',
                style: TextStyle(
                  color: Color(0xFF10B981),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessDetailRow(String label, String value, {bool isBold = false, Widget? customValueWidget}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        if (customValueWidget != null)
          customValueWidget
        else
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              fontSize: 14,
              color: const Color(0xFF1E293B),
            ),
          ),
      ],
    );
  }

  List<MockBill> _getMockBills(Customer customer) {
    final int hash = customer.id.hashCode.abs();
    return [
      MockBill(
        id: 'BILL-2024-${((hash + 5) % 12 + 1).toString().padLeft(2, '0')}',
        title: 'December 2024',
        amount: 49.99,
        paidDate: 'Dec 29, 2025',
        status: 'Paid',
      ),
      MockBill(
        id: 'BILL-2024-${((hash + 4) % 12 + 1).toString().padLeft(2, '0')}',
        title: 'November 2024',
        amount: 49.99,
        paidDate: 'Nov 25, 2025',
        status: 'Paid',
      ),
      MockBill(
        id: 'BILL-2024-${((hash + 3) % 12 + 1).toString().padLeft(2, '0')}',
        title: 'October 2024',
        amount: 49.99,
        paidDate: 'Oct 28, 2025',
        status: 'Paid',
      ),
    ];
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(color: Colors.grey)),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          _buildFilterChip('all', 'All', Icons.people_outline),
          const SizedBox(width: 8),
          _buildFilterChip('balance', 'Outstanding', Icons.warning_amber_outlined),
          const SizedBox(width: 8),
          _buildFilterChip('loyal', 'Top Loyalty', Icons.star_outline),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filter, String label, IconData icon) {
    final isSelected = _selectedFilter == filter;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : const Color(0xFF4A5D54),
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (val) {
        if (val) {
          setState(() {
            _selectedFilter = filter;
          });
        }
      },
      selectedColor: primaryColor,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF4A5D54),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? Colors.transparent : const Color(0xFFE6EFEA),
        ),
      ),
      showCheckmark: false,
    );
  }


  void _showAddCustomerDialog(BuildContext context) {
    final nameCont = TextEditingController();
    final phoneCont = TextEditingController();
    final emailCont = TextEditingController();
    final addrCont = TextEditingController();
    final balanceCont = TextEditingController(text: '0.0');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.person_add_outlined, color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Add New Customer',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF141C18)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameCont,
                decoration: const InputDecoration(
                  labelText: 'Customer Name *',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneCont,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number *',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailCont,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addrCont,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: balanceCont,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Starting Balance (INR)',
                  prefixIcon: Icon(Icons.currency_rupee_outlined),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    child: const Text('CANCEL', style: TextStyle(color: Color(0xFF4A5D54), fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (nameCont.text.isEmpty || phoneCont.text.isEmpty) return;
                      final customer = Customer(
                        id: const Uuid().v4(),
                        tenantId: 'temp_tenant_id',
                        name: nameCont.text,
                        phoneNumber: phoneCont.text,
                        email: emailCont.text.isEmpty ? null : emailCont.text,
                        address: addrCont.text.isEmpty ? null : addrCont.text,
                        creditBalance: double.parse(balanceCont.text.isEmpty ? '0.0' : balanceCont.text),
                        loyaltyPoints: 0,
                        createdAt: DateTime.now(),
                      );
                      context.read<CustomerBloc>().add(AddCustomerEvent(customer));
                      Navigator.pop(context);
                      context.read<CustomerBloc>().add(const LoadCustomers('temp_tenant_id'));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('SAVE CUSTOMER', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditCustomerDialog(BuildContext context, Customer customer) {
    final nameCont = TextEditingController(text: customer.name);
    final phoneCont = TextEditingController(text: customer.phoneNumber);
    final emailCont = TextEditingController(text: customer.email ?? '');
    final addrCont = TextEditingController(text: customer.address ?? '');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.edit_outlined, color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Edit Customer Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF141C18)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameCont,
                decoration: const InputDecoration(
                  labelText: 'Customer Name *',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneCont,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number *',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailCont,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addrCont,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    child: const Text('CANCEL', style: TextStyle(color: Color(0xFF4A5D54), fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      final updated = Customer(
                        id: customer.id,
                        tenantId: customer.tenantId,
                        name: nameCont.text,
                        phoneNumber: phoneCont.text,
                        email: emailCont.text.isEmpty ? null : emailCont.text,
                        address: addrCont.text.isEmpty ? null : addrCont.text,
                        creditBalance: customer.creditBalance,
                        loyaltyPoints: customer.loyaltyPoints,
                        createdAt: customer.createdAt,
                      );
                      context.read<CustomerBloc>().add(UpdateCustomerEvent(updated));
                      setState(() {
                        _selectedCustomer = updated;
                      });
                      Navigator.pop(context);
                      context.read<CustomerBloc>().add(const LoadCustomers('temp_tenant_id'));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('SAVE CHANGES', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 450,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Delete Customer Account?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to permanently delete the profile of ${customer.name}? This action cannot be undone and will remove all their records.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      child: const Text('CANCEL', style: TextStyle(color: Color(0xFF4B5563), fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<CustomerBloc>().add(DeleteCustomerEvent(customer.id));
                        setState(() {
                          _selectedCustomer = null;
                        });
                        Navigator.pop(context);
                        context.read<CustomerBloc>().add(const LoadCustomers('temp_tenant_id'));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: const Text('DELETE', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
