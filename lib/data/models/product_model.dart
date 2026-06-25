import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.tenantId,
    required super.categoryId,
    required super.name,
    required super.sku,
    super.barcode,
    super.qrCode,
    required super.description,
    required super.purchasePrice,
    required super.sellingPrice,
    required super.taxRate,
    required super.currentStock,
    required super.lowStockThreshold,
    required super.unit,
    super.imageUrl,
    required super.createdAt,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductModel(
      id: id,
      tenantId: map['tenantId'] ?? '',
      categoryId: map['categoryId'] ?? '',
      name: map['name'] ?? '',
      sku: map['sku'] ?? '',
      barcode: map['barcode'],
      qrCode: map['qrCode'],
      description: map['description'] ?? '',
      purchasePrice: (map['purchasePrice'] ?? 0.0).toDouble(),
      sellingPrice: (map['sellingPrice'] ?? 0.0).toDouble(),
      taxRate: (map['taxRate'] ?? 0.0).toDouble(),
      currentStock: (map['currentStock'] ?? 0.0).toDouble(),
      lowStockThreshold: (map['lowStockThreshold'] ?? 0.0).toDouble(),
      unit: map['unit'] ?? '',
      imageUrl: map['imageUrl'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tenantId': tenantId,
      'categoryId': categoryId,
      'name': name,
      'sku': sku,
      'barcode': barcode,
      'qrCode': qrCode,
      'description': description,
      'purchasePrice': purchasePrice,
      'sellingPrice': sellingPrice,
      'taxRate': taxRate,
      'currentStock': currentStock,
      'lowStockThreshold': lowStockThreshold,
      'unit': unit,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.tenantId,
    required super.name,
    super.description,
    super.parentId,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map, String id) {
    return CategoryModel(
      id: id,
      tenantId: map['tenantId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      parentId: map['parentId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tenantId': tenantId,
      'name': name,
      'description': description,
      'parentId': parentId,
    };
  }
}
