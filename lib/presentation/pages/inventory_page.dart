import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../bloc/product/product_bloc.dart';
import '../bloc/product/product_event.dart' hide LoadCategories;
import '../bloc/product/product_state.dart';
import '../bloc/category/category_bloc.dart';
import '../bloc/category/category_event.dart';
import '../bloc/category/category_state.dart' as cat_state;
import '../../domain/entities/product.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategoryId = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<ProductBloc>().add(const LoadProducts('temp_tenant_id'));
    context.read<CategoryBloc>().add(const LoadCategories('temp_tenant_id'));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Inventory Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Products'),
            Tab(text: 'Categories'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProductsTab(),
          _buildCategoriesTab(),
        ],
      ),
    );
  }

  Widget _buildProductsTab() {
    return Column(
      children: [
        // Controls Row: Search & Filters & Add Product
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    context.read<ProductBloc>().add(SearchProducts('temp_tenant_id', val));
                  },
                  decoration: InputDecoration(
                    hintText: 'Search products by name or SKU...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: const Color(0xFFF3F4F6),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Category Filter Dropdown
              BlocBuilder<CategoryBloc, cat_state.CategoryState>(
                builder: (context, state) {
                  List<Category> categories = [];
                  if (state is cat_state.CategoriesLoaded) {
                    categories = state.categories;
                  }
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategoryId,
                        items: [
                          const DropdownMenuItem(value: 'all', child: Text('All Categories')),
                          ...categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                        ],
                        onChanged: (val) {
                          setState(() {
                            _selectedCategoryId = val ?? 'all';
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _showAddProductDialog(context),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('ADD PRODUCT', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),

        // Product Catalog List
        Expanded(
          child: BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              if (state is ProductLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is ProductsLoaded) {
                var products = state.products;

                // Client filter by category
                if (_selectedCategoryId != 'all') {
                  products = products.where((p) => p.categoryId == _selectedCategoryId).toList();
                }

                if (products.isEmpty) {
                  return const Center(child: Text('No products found.'));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 320,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final isLowStock = product.currentStock <= product.lowStockThreshold;
                    return Card(
                      color: Colors.white,
                      surfaceTintColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isLowStock ? Theme.of(context).colorScheme.error.withOpacity(0.3) : const Color(0xFFE6EFEA),
                          width: isLowStock ? 1.5 : 1,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Thumbnail / Icon
                                Container(
                                  height: 100,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: isLowStock ? Colors.red[50] : const Color(0xFFE1F5EC),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.inventory_2_outlined,
                                    size: 48,
                                    color: isLowStock ? Colors.red : Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  product.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'SKU: ${product.sku}',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                                const Spacer(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '₹${product.sellingPrice.toStringAsFixed(2)}',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.primary),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isLowStock ? Colors.red[50] : const Color(0xFFE1F5EC),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Stock: ${product.currentStock.toInt()}',
                                        style: TextStyle(
                                          color: isLowStock ? Colors.red[700] : Theme.of(context).colorScheme.primary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: PopupMenuButton<String>(
                              onSelected: (val) {
                                if (val == 'edit') {
                                  _showEditProductDialog(context, product);
                                } else if (val == 'delete') {
                                  _showDeleteConfirmDialog(context, product);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit), SizedBox(width: 8), Text('Edit')])),
                                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text('Delete')])),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
              return const Center(child: Text('Add products to list.'));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesTab() {
    return BlocBuilder<CategoryBloc, cat_state.CategoryState>(
      builder: (context, state) {
        if (state is cat_state.CategoryLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is cat_state.CategoriesLoaded) {
          final categories = state.categories;
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: categories.length + 1,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddCategoryDialog(context),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('ADD CATEGORY', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                );
              }
              final category = categories[index - 1];
              return Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE6EFEA)),
                ),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: const Color(0xFFE1F5EC), child: Icon(Icons.category, color: Theme.of(context).colorScheme.primary)),
                  title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(category.description ?? 'No description provided'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () {
                      context.read<CategoryBloc>().add(DeleteCategoryEvent(category.id));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Category deleted')));
                    },
                  ),
                ),
              );
            },
          );
        }
        return const Center(child: Text('No categories found.'));
      },
    );
  }

  void _showAddProductDialog(BuildContext context) {
    final nameCont = TextEditingController();
    final skuCont = TextEditingController();
    final barcodeCont = TextEditingController();
    final descCont = TextEditingController();
    final purchasePriceCont = TextEditingController();
    final sellingPriceCont = TextEditingController();
    final stockCont = TextEditingController();
    final taxCont = TextEditingController();
    final thresholdCont = TextEditingController();
    final unitCont = TextEditingController(text: 'Pcs');
    String? categoryId;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Product', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 450,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Category selection
                      BlocBuilder<CategoryBloc, cat_state.CategoryState>(
                        builder: (context, state) {
                          List<Category> categories = [];
                          if (state is cat_state.CategoriesLoaded) {
                            categories = state.categories;
                          }
                          return DropdownButtonFormField<String>(
                            decoration: const InputDecoration(labelText: 'Category *'),
                            value: categoryId,
                            items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                            onChanged: (val) {
                              setDialogState(() {
                                categoryId = val;
                              });
                            },
                          );
                        },
                      ),
                      TextField(controller: nameCont, decoration: const InputDecoration(labelText: 'Product Name *')),
                      TextField(controller: skuCont, decoration: const InputDecoration(labelText: 'SKU *')),
                      TextField(
                        controller: barcodeCont,
                        decoration: InputDecoration(
                          labelText: 'Barcode',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.qr_code_scanner, color: Color(0xFF10B981)),
                            onPressed: () => _scanBarcodeForField(context, barcodeCont, skuCont),
                          ),
                        ),
                      ),
                      TextField(controller: descCont, decoration: const InputDecoration(labelText: 'Description')),
                      Row(
                        children: [
                          Expanded(child: TextField(controller: purchasePriceCont, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Purchase Price *'))),
                          const SizedBox(width: 12),
                          Expanded(child: TextField(controller: sellingPriceCont, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Selling Price *'))),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: TextField(controller: stockCont, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Initial Stock *'))),
                          const SizedBox(width: 12),
                          Expanded(child: TextField(controller: taxCont, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'GST Tax Rate (%) *'))),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: TextField(controller: thresholdCont, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Low Stock Limit *'))),
                          const SizedBox(width: 12),
                          Expanded(child: TextField(controller: unitCont, decoration: const InputDecoration(labelText: 'Unit *'))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
                ElevatedButton(
                  onPressed: () {
                    if (categoryId == null || nameCont.text.isEmpty || skuCont.text.isEmpty || purchasePriceCont.text.isEmpty || sellingPriceCont.text.isEmpty || stockCont.text.isEmpty || taxCont.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields')));
                      return;
                    }
                    final product = Product(
                      id: const Uuid().v4(),
                      tenantId: 'temp_tenant_id',
                      categoryId: categoryId!,
                      name: nameCont.text,
                      sku: skuCont.text,
                      barcode: barcodeCont.text.isEmpty ? null : barcodeCont.text,
                      description: descCont.text,
                      purchasePrice: double.parse(purchasePriceCont.text),
                      sellingPrice: double.parse(sellingPriceCont.text),
                      taxRate: double.parse(taxCont.text),
                      currentStock: double.parse(stockCont.text),
                      lowStockThreshold: double.parse(thresholdCont.text.isEmpty ? '0' : thresholdCont.text),
                      unit: unitCont.text,
                      createdAt: DateTime.now(),
                    );
                    context.read<ProductBloc>().add(AddProductEvent(product, null));
                    Navigator.pop(context);
                    context.read<ProductBloc>().add(const LoadProducts('temp_tenant_id'));
                  },
                  child: const Text('SAVE'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditProductDialog(BuildContext context, Product product) {
    final nameCont = TextEditingController(text: product.name);
    final skuCont = TextEditingController(text: product.sku);
    final barcodeCont = TextEditingController(text: product.barcode ?? '');
    final descCont = TextEditingController(text: product.description);
    final purchasePriceCont = TextEditingController(text: product.purchasePrice.toString());
    final sellingPriceCont = TextEditingController(text: product.sellingPrice.toString());
    final stockCont = TextEditingController(text: product.currentStock.toString());
    final taxCont = TextEditingController(text: product.taxRate.toString());
    final thresholdCont = TextEditingController(text: product.lowStockThreshold.toString());
    final unitCont = TextEditingController(text: product.unit);
    String? categoryId = product.categoryId;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Product', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 450,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BlocBuilder<CategoryBloc, cat_state.CategoryState>(
                        builder: (context, state) {
                          List<Category> categories = [];
                          if (state is cat_state.CategoriesLoaded) {
                            categories = state.categories;
                          }
                          return DropdownButtonFormField<String>(
                            decoration: const InputDecoration(labelText: 'Category *'),
                            value: categoryId,
                            items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                            onChanged: (val) {
                              setDialogState(() {
                                categoryId = val;
                              });
                            },
                          );
                        },
                      ),
                      TextField(controller: nameCont, decoration: const InputDecoration(labelText: 'Product Name *')),
                      TextField(controller: skuCont, decoration: const InputDecoration(labelText: 'SKU *')),
                      TextField(
                        controller: barcodeCont,
                        decoration: InputDecoration(
                          labelText: 'Barcode',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.qr_code_scanner, color: Color(0xFF10B981)),
                            onPressed: () => _scanBarcodeForField(context, barcodeCont, skuCont),
                          ),
                        ),
                      ),
                      TextField(controller: descCont, decoration: const InputDecoration(labelText: 'Description')),
                      Row(
                        children: [
                          Expanded(child: TextField(controller: purchasePriceCont, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Purchase Price *'))),
                          const SizedBox(width: 12),
                          Expanded(child: TextField(controller: sellingPriceCont, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Selling Price *'))),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: TextField(controller: stockCont, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Current Stock *'))),
                          const SizedBox(width: 12),
                          Expanded(child: TextField(controller: taxCont, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'GST Tax Rate (%) *'))),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: TextField(controller: thresholdCont, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Low Stock Limit *'))),
                          const SizedBox(width: 12),
                          Expanded(child: TextField(controller: unitCont, decoration: const InputDecoration(labelText: 'Unit *'))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
                ElevatedButton(
                  onPressed: () {
                    final updated = Product(
                      id: product.id,
                      tenantId: product.tenantId,
                      categoryId: categoryId!,
                      name: nameCont.text,
                      sku: skuCont.text,
                      barcode: barcodeCont.text.isEmpty ? null : barcodeCont.text,
                      description: descCont.text,
                      purchasePrice: double.parse(purchasePriceCont.text),
                      sellingPrice: double.parse(sellingPriceCont.text),
                      taxRate: double.parse(taxCont.text),
                      currentStock: double.parse(stockCont.text),
                      lowStockThreshold: double.parse(thresholdCont.text.isEmpty ? '0' : thresholdCont.text),
                      unit: unitCont.text,
                      createdAt: product.createdAt,
                    );
                    context.read<ProductBloc>().add(UpdateProductEvent(updated, null));
                    Navigator.pop(context);
                    context.read<ProductBloc>().add(const LoadProducts('temp_tenant_id'));
                  },
                  child: const Text('UPDATE'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete ${product.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              context.read<ProductBloc>().add(DeleteProductEvent(product.id));
              Navigator.pop(context);
              context.read<ProductBloc>().add(const LoadProducts('temp_tenant_id'));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('DELETE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final nameCont = TextEditingController();
    final descCont = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Category', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCont, decoration: const InputDecoration(labelText: 'Category Name *')),
            TextField(controller: descCont, decoration: const InputDecoration(labelText: 'Description')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              if (nameCont.text.isEmpty) return;
              final cat = Category(
                id: const Uuid().v4(),
                tenantId: 'temp_tenant_id',
                name: nameCont.text,
                description: descCont.text,
              );
              context.read<CategoryBloc>().add(AddCategoryEvent(cat));
              Navigator.pop(context);
              context.read<CategoryBloc>().add(const LoadCategories('temp_tenant_id'));
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  void _scanBarcodeForField(BuildContext context, TextEditingController barcodeController, TextEditingController skuController) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (dialogContext) => SizedBox(
        height: MediaQuery.of(dialogContext).size.height * 0.7,
        child: Column(
          children: [
            AppBar(
              title: const Text('Scan Barcode', style: TextStyle(fontWeight: FontWeight.bold)),
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
                      barcodeController.text = code;
                      if (skuController.text.isEmpty) {
                        skuController.text = code;
                      }
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
}
