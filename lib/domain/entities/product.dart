import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String tenantId;
  final String categoryId;
  final String name;
  final String sku;
  final String? barcode;
  final String? qrCode;
  final String description;
  final double purchasePrice;
  final double sellingPrice;
  final double taxRate; // GST percentage
  final double currentStock;
  final double lowStockThreshold;
  final String unit;
  final String? imageUrl;
  final DateTime createdAt;

  const Product({
    required this.id,
    required this.tenantId,
    required this.categoryId,
    required this.name,
    required this.sku,
    this.barcode,
    this.qrCode,
    required this.description,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.taxRate,
    required this.currentStock,
    required this.lowStockThreshold,
    required this.unit,
    this.imageUrl,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        tenantId,
        categoryId,
        name,
        sku,
        barcode,
        qrCode,
        description,
        purchasePrice,
        sellingPrice,
        taxRate,
        currentStock,
        lowStockThreshold,
        unit,
        imageUrl,
        createdAt,
      ];
}

class Category extends Equatable {
  final String id;
  final String tenantId;
  final String name;
  final String? description;
  final String? parentId; // For subcategories

  const Category({
    required this.id,
    required this.tenantId,
    required this.name,
    this.description,
    this.parentId,
  });

  @override
  List<Object?> get props => [id, tenantId, name, description, parentId];
}
