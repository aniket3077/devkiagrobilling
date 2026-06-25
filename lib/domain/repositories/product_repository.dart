import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../entities/product.dart';
import '../../core/error/failures.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getProducts(String tenantId);
  Future<Either<Failure, List<Product>>> searchProducts(String tenantId, String query);
  Future<Either<Failure, Product?>> getProductByCode(String tenantId, String code);
  Future<Either<Failure, Unit>> addProduct(Product product, File? imageFile);
  Future<Either<Failure, Unit>> updateProduct(Product product, File? imageFile);
  Future<Either<Failure, Unit>> deleteProduct(String productId);
  
  Future<Either<Failure, List<Category>>> getCategories(String tenantId);
  Future<Either<Failure, List<Category>>> getSubCategories(String parentId);
  Future<Either<Failure, Unit>> addCategory(Category category);
  Future<Either<Failure, Unit>> updateCategory(Category category);
  Future<Either<Failure, Unit>> deleteCategory(String categoryId);
  
  Future<Either<Failure, Unit>> updateStock(String productId, double quantityChange);
}
