import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../models/product_model.dart';
import '../../../domain/entities/product.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts(String tenantId);
  Future<List<ProductModel>> searchProducts(String tenantId, String query);
  Future<ProductModel?> getProductByCode(String tenantId, String code);
  Future<void> addProduct(ProductModel product, File? imageFile);
  Future<void> updateProduct(ProductModel product, File? imageFile);
  Future<void> deleteProduct(String productId);
  
  Future<List<CategoryModel>> getCategories(String tenantId);
  Future<List<CategoryModel>> getSubCategories(String parentId);
  Future<void> addCategory(CategoryModel category);
  Future<void> updateCategory(CategoryModel category);
  Future<void> deleteCategory(String categoryId);
  Future<void> updateStock(String productId, double quantityChange);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  ProductRemoteDataSourceImpl(this._firestore, this._storage);

  @override
  Future<List<ProductModel>> getProducts(String tenantId) async {
    final snapshot = await _firestore
        .collection('products')
        .where('tenantId', isEqualTo: tenantId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => ProductModel.fromMap(doc.data(), doc.id)).toList();
  }

  @override
  Future<List<ProductModel>> searchProducts(String tenantId, String query) async {
    // Basic search - for production consider Algolia or custom implementation
    final snapshot = await _firestore
        .collection('products')
        .where('tenantId', isEqualTo: tenantId)
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .get();
    return snapshot.docs.map((doc) => ProductModel.fromMap(doc.data(), doc.id)).toList();
  }

  @override
  Future<ProductModel?> getProductByCode(String tenantId, String code) async {
    // Check Barcode
    final barcodeQuery = await _firestore
        .collection('products')
        .where('tenantId', isEqualTo: tenantId)
        .where('barcode', isEqualTo: code)
        .limit(1)
        .get();
    if (barcodeQuery.docs.isNotEmpty) {
      return ProductModel.fromMap(barcodeQuery.docs.first.data(), barcodeQuery.docs.first.id);
    }

    // Check QR Code
    final qrQuery = await _firestore
        .collection('products')
        .where('tenantId', isEqualTo: tenantId)
        .where('qrCode', isEqualTo: code)
        .limit(1)
        .get();
    if (qrQuery.docs.isNotEmpty) {
      return ProductModel.fromMap(qrQuery.docs.first.data(), qrQuery.docs.first.id);
    }

    // Check SKU
    final skuQuery = await _firestore
        .collection('products')
        .where('tenantId', isEqualTo: tenantId)
        .where('sku', isEqualTo: code)
        .limit(1)
        .get();
    if (skuQuery.docs.isNotEmpty) {
      return ProductModel.fromMap(skuQuery.docs.first.data(), skuQuery.docs.first.id);
    }

    return null;
  }

  @override
  Future<void> addProduct(ProductModel product, File? imageFile) async {
    String? imageUrl;
    if (imageFile != null) {
      imageUrl = await _uploadImage(product.id, imageFile);
    }
    
    final productData = product.toMap();
    if (imageUrl != null) productData['imageUrl'] = imageUrl;
    
    await _firestore.collection('products').doc(product.id).set(productData);
  }

  @override
  Future<void> updateProduct(ProductModel product, File? imageFile) async {
    String? imageUrl;
    if (imageFile != null) {
      imageUrl = await _uploadImage(product.id, imageFile);
    }

    final productData = product.toMap();
    if (imageUrl != null) productData['imageUrl'] = imageUrl;

    await _firestore.collection('products').doc(product.id).update(productData);
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await _firestore.collection('products').doc(productId).delete();
  }

  @override
  Future<List<CategoryModel>> getCategories(String tenantId) async {
    final snapshot = await _firestore
        .collection('categories')
        .where('tenantId', isEqualTo: tenantId)
        .where('parentId', isNull: true) // Only top-level categories
        .get();
    return snapshot.docs.map((doc) => CategoryModel.fromMap(doc.data(), doc.id)).toList();
  }

  @override
  Future<List<CategoryModel>> getSubCategories(String parentId) async {
    final snapshot = await _firestore
        .collection('categories')
        .where('parentId', isEqualTo: parentId)
        .get();
    return snapshot.docs.map((doc) => CategoryModel.fromMap(doc.data(), doc.id)).toList();
  }

  @override
  Future<void> addCategory(CategoryModel category) async {
    await _firestore.collection('categories').doc(category.id).set(category.toMap());
  }

  @override
  Future<void> updateCategory(CategoryModel category) async {
    await _firestore.collection('categories').doc(category.id).update(category.toMap());
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    // Note: In a real app, you might want to handle subcategories/products linked to this
    await _firestore.collection('categories').doc(categoryId).delete();
  }

  @override
  Future<void> updateStock(String productId, double quantityChange) async {
    await _firestore.collection('products').doc(productId).update({
      'currentStock': FieldValue.increment(quantityChange),
    });
  }

  Future<String> _uploadImage(String productId, File file) async {
    final ref = _storage.ref().child('product_images').child('$productId.jpg');
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }
}
