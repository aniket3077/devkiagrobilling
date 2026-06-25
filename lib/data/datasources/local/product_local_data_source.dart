import 'package:hive_flutter/hive_flutter.dart';
import '../../models/product_model.dart';

abstract class ProductLocalDataSource {
  Future<List<ProductModel>> getProducts();
  Future<void> cacheProducts(List<ProductModel> products);
  Future<void> addProduct(ProductModel product);
  Future<void> clearCache();
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  final Box<Map> _productBox;
  static const String boxName = 'products_box';

  ProductLocalDataSourceImpl(this._productBox);

  @override
  Future<List<ProductModel>> getProducts() async {
    return _productBox.values
        .map((map) => ProductModel.fromMap(Map<String, dynamic>.from(map), map['id'] ?? ''))
        .toList();
  }

  @override
  Future<void> cacheProducts(List<ProductModel> products) async {
    final Map<String, Map> productMap = {
      for (var p in products) p.id: p.toMap()..['id'] = p.id
    };
    await _productBox.putAll(productMap);
  }

  @override
  Future<void> addProduct(ProductModel product) async {
    await _productBox.put(product.id, product.toMap()..['id'] = product.id);
  }

  @override
  Future<void> clearCache() async {
    await _productBox.clear();
  }
}
