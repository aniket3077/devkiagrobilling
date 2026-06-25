import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:uuid/uuid.dart';
import '../bloc/billing/billing_bloc.dart';
import '../bloc/billing/billing_event.dart';
import '../bloc/billing/billing_state.dart';
import '../bloc/product/product_bloc.dart';
import '../bloc/product/product_event.dart';
import '../bloc/product/product_state.dart';
import '../bloc/customer/customer_bloc.dart';
import '../bloc/customer/customer_event.dart';
import '../bloc/customer/customer_state.dart' as customer_state;
import '../../domain/entities/invoice.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/payment.dart';
import '../../core/utils/barcode_handler.dart';
import '../../injection_container.dart';
import '../../services/printer_service.dart';

class BillingPage extends StatelessWidget {
  const BillingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<BillingBloc>(),
      child: Builder(
        builder: (context) {
          return HardwareScannerListener(
            onScan: (barcode) {
              debugPrint('Hardware Scan: $barcode');
              context.read<BillingBloc>().add(AddProductByCode(barcode));
            },
            child: const BillingView(),
          );
        },
      ),
    );
  }
}

class BillingView extends StatefulWidget {
  const BillingView({super.key});

  @override
  State<BillingView> createState() => _BillingViewState();
}

class _BillingViewState extends State<BillingView> {
  final TextEditingController _searchController = TextEditingController();
  bool _showCartOnMobile = false;

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(const LoadProducts('temp_tenant_id'));
    context.read<CustomerBloc>().add(const LoadCustomers('temp_tenant_id'));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BillingBloc, BillingState>(
      listener: (context, state) {
        if (state.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sale processed successfully!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        }
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
          );
        }
      },
      child: BlocBuilder<BillingBloc, BillingState>(
        builder: (context, state) {
          final isMobile = MediaQuery.of(context).size.width < 768;

          return Scaffold(
            appBar: AppBar(
              title: Text(
                isMobile 
                    ? (_showCartOnMobile ? 'Cart' : 'New Sale')
                    : 'New Sale',
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (isMobile && _showCartOnMobile) {
                    setState(() {
                      _showCartOnMobile = false;
                    });
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
              actions: [
                if (!isMobile || !_showCartOnMobile)
                  IconButton(
                    icon: Icon(Icons.qr_code_scanner, color: Theme.of(context).colorScheme.primary, size: 28),
                    onPressed: () => _showScanner(context),
                  ),
                const SizedBox(width: 8),
              ],
            ),
            body: isMobile
                ? (_showCartOnMobile 
                    ? _buildCartSection() 
                    : Column(
                        children: [
                          Expanded(child: _buildProductSelection()),
                          if (state.cartItems.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, -2),
                                  )
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${state.cartItems.fold<double>(0, (sum, item) => sum + item.quantity).toInt()} Items Added',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      Text(
                                        'Total: ₹${state.grandTotal.toStringAsFixed(2)}',
                                        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _showCartOnMobile = true;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).colorScheme.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: const Text('VIEW CART', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ))
                : Row(
                    children: [
                      // Left Side: Product Search & Selection
                      Expanded(
                        flex: 3,
                        child: _buildProductSelection(),
                      ),

                      // Right Side: Cart & Checkout
                      Expanded(
                        flex: 2,
                        child: _buildCartSection(),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildProductSelection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Colors.grey, width: 0.2)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (val) {
              context.read<ProductBloc>().add(SearchProducts('temp_tenant_id', val));
            },
            decoration: const InputDecoration(
              hintText: 'Search products by name or SKU...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is ProductLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ProductsLoaded) {
                  final products = state.products;
                  if (products.isEmpty) {
                    return const Center(child: Text('No products found. Add some in Inventory first.'));
                  }
                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 220,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return _buildProductCard(product);
                    },
                  );
                }
                return const Center(child: Text('Add products to display here.'));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final isLowStock = product.currentStock <= product.lowStockThreshold;
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isLowStock ? Theme.of(context).colorScheme.error.withOpacity(0.3) : const Color(0xFFE6EFEA)),
      ),
      child: InkWell(
        onTap: () {
          context.read<BillingBloc>().add(AddProductToCart(product));
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isLowStock ? Colors.red[50] : const Color(0xFFE1F5EC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.inventory_2_outlined, size: 40, color: isLowStock ? Colors.red : Theme.of(context).colorScheme.primary),
                ),
              ),
              const SizedBox(height: 8),
              Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text('₹${product.sellingPrice.toStringAsFixed(2)}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
              Text('Stock: ${product.currentStock.toInt()}', style: TextStyle(fontSize: 10, color: isLowStock ? Colors.red : Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartSection() {
    return BlocBuilder<BillingBloc, BillingState>(
      builder: (context, state) {
        return Container(
          color: Colors.white,
          child: Column(
            children: [
              // Customer Selection
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Row(
                  children: [
                    Icon(Icons.person_outline, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.selectedCustomer?.name ?? 'Walk-in Customer',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showCustomerSelectionDialog(context),
                      style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.primary),
                      child: const Text('Change'),
                    ),
                  ],
                ),
              ),

              // Cart Items
              Expanded(
                child: state.cartItems.isEmpty
                    ? _buildEmptyCart()
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.cartItems.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final item = state.cartItems[index];
                          return _buildCartItem(context, item);
                        },
                      ),
              ),

              // Summary & Checkout
              _buildCheckoutSummary(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCartItem(BuildContext context, InvoiceItem item) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text('₹${item.unitPrice.toStringAsFixed(2)}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              onPressed: () => context.read<BillingBloc>().add(UpdateProductQuantity(item.productId, item.quantity - 1)),
            ),
            Text('${item.quantity.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.green),
              onPressed: () => context.read<BillingBloc>().add(UpdateProductQuantity(item.productId, item.quantity + 1)),
            ),
          ],
        ),
        SizedBox(
          width: 80,
          child: Text(
            '₹${item.total.toStringAsFixed(2)}',
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Your cart is empty', style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildCheckoutSummary(BuildContext context, BillingState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal'),
              Text('₹${state.subTotal.toStringAsFixed(2)}'),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total GST'),
              Text('₹${state.taxTotal.toStringAsFixed(2)}'),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Amount', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                '₹${state.grandTotal.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: state.cartItems.isEmpty ? null : () => _showCheckoutDialog(context, state),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('PROCEED TO CHECKOUT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _showScanner(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (dialogContext) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            AppBar(
              title: const Text('Scan Barcode'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(dialogContext),
              ),
            ),
            Expanded(
              child: MobileScanner(
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty) {
                    final String? code = barcodes.first.rawValue;
                    if (code != null) {
                      context.read<BillingBloc>().add(AddProductByCode(code));
                    }
                    Navigator.pop(dialogContext);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomerSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Select Customer'),
          content: SizedBox(
            width: 400,
            height: 500,
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search customer by name or phone...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (val) {
                    context.read<CustomerBloc>().add(SearchCustomers('temp_tenant_id', val));
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: BlocBuilder<CustomerBloc, customer_state.CustomerState>(
                    builder: (context, state) {
                      if (state is customer_state.CustomerLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state is customer_state.CustomersLoaded) {
                        final customers = state.customers;
                        return ListView(
                          children: [
                            ListTile(
                              leading: const CircleAvatar(child: Icon(Icons.person)),
                              title: const Text('Walk-in Customer'),
                              onTap: () {
                                context.read<BillingBloc>().add(const SetCustomer(null));
                                Navigator.pop(dialogContext);
                              },
                            ),
                            const Divider(),
                            ...customers.map((customer) => ListTile(
                                  leading: CircleAvatar(child: Text(customer.name[0].toUpperCase())),
                                  title: Text(customer.name),
                                  subtitle: Text(customer.phoneNumber),
                                  onTap: () {
                                    context.read<BillingBloc>().add(SetCustomer(customer));
                                    Navigator.pop(dialogContext);
                                  },
                                )),
                          ],
                        );
                      }
                      return const Center(child: Text('No customers found'));
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
              child: const Text('CANCEL'),
            ),
          ],
        );
      },
    );
  }

  void _showCheckoutDialog(BuildContext context, BillingState state) {
    PaymentMode selectedMode = PaymentMode.cash;
    final paidAmountController = TextEditingController(text: state.grandTotal.toStringAsFixed(2));
    double changeAmount = 0.0;
    bool printReceipt = true;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final double paidAmount = double.tryParse(paidAmountController.text) ?? 0.0;
            if (paidAmount > state.grandTotal) {
              changeAmount = paidAmount - state.grandTotal;
            } else {
              changeAmount = 0.0;
            }

            return AlertDialog(
              title: const Text('Checkout Sale', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Amount: ₹${state.grandTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    const Text('Select Payment Mode', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<PaymentMode>(
                      value: selectedMode,
                      items: PaymentMode.values.map((mode) {
                        return DropdownMenuItem<PaymentMode>(
                          value: mode,
                          child: Text(mode.name.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (mode) {
                        if (mode != null) {
                          setState(() {
                            selectedMode = mode;
                            if (mode == PaymentMode.credit) {
                              paidAmountController.text = '0.0';
                            } else {
                              paidAmountController.text = state.grandTotal.toStringAsFixed(2);
                            }
                          });
                        }
                      },
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: paidAmountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Amount Paid (₹)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) {
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 12),
                    if (selectedMode == PaymentMode.cash && changeAmount > 0)
                      Text(
                        'Change to Return: ₹${changeAmount.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: const Text('Print Receipt via Bluetooth'),
                      value: printReceipt,
                      onChanged: (val) {
                        setState(() {
                          printReceipt = val ?? false;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final payment = PaymentDetail(
                      mode: selectedMode,
                      amount: selectedMode == PaymentMode.credit ? 0.0 : paidAmount,
                      date: DateTime.now(),
                    );
                    
                    context.read<BillingBloc>().add(AddPayment(payment));
                    
                    if (printReceipt) {
                      final invoice = Invoice(
                        id: const Uuid().v4(),
                        tenantId: 'temp_tenant_id',
                        branchId: 'temp_branch_id',
                        invoiceNumber: 'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
                        customerName: state.selectedCustomer?.name ?? 'Walk-in Customer',
                        customerId: state.selectedCustomer?.id,
                        staffId: 'temp_staff_id',
                        date: DateTime.now(),
                        items: state.cartItems,
                        subTotal: state.subTotal,
                        cgstTotal: state.cgstTotal,
                        sgstTotal: state.sgstTotal,
                        igstTotal: state.igstTotal,
                        taxTotal: state.taxTotal,
                        discount: 0.0,
                        grandTotal: state.grandTotal,
                        paidAmount: selectedMode == PaymentMode.credit ? 0.0 : paidAmount,
                        balanceAmount: selectedMode == PaymentMode.credit ? state.grandTotal : (state.grandTotal - paidAmount),
                        paymentStatus: selectedMode == PaymentMode.credit ? 'credit' : (paidAmount >= state.grandTotal ? 'paid' : 'partial'),
                        payments: [payment],
                      );
                      
                      try {
                        await sl<PrinterService>().printInvoice(invoice);
                      } catch (e) {
                        debugPrint('Printer error: $e');
                      }
                    }

                    context.read<BillingBloc>().add(CreateInvoice());
                    Navigator.pop(dialogContext);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('COMPLETE SALE', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
