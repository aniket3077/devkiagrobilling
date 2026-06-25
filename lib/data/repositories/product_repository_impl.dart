import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/remote/product_remote_data_source.dart';
import '../models/product_model.dart';

import '../../core/network/network_info.dart';
import '../datasources/local/product_local_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Product>>> getProducts(String tenantId) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteProducts = await remoteDataSource.getProducts(tenantId);
        await localDataSource.cacheProducts(remoteProducts);
        return Right(remoteProducts);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      try {
        final localProducts = await localDataSource.getProducts();
        return Right(localProducts);
      } catch (e) {
        return Left(CacheFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, List<Product>>> searchProducts(String tenantId, String query) async {
    try {
      final products = await remoteDataSource.searchProducts(tenantId, query);
      return Right(products);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Product?>> getProductByCode(String tenantId, String code) async {
    try {
      final product = await remoteDataSource.getProductByCode(tenantId, code);
      return Right(product);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> addProduct(Product product, File? imageFile) async {
    try {
      await remoteDataSource.addProduct(_toModel(product), imageFile);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateProduct(Product product, File? imageFile) async {
    try {
      await remoteDataSource.updateProduct(_toModel(product), imageFile);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteProduct(String productId) async {
    try {
      await remoteDataSource.deleteProduct(productId);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Category>>> getCategories(String tenantId) async {
    try {
      final categories = await remoteDataSource.getCategories(tenantId);
      return Right(categories);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Category>>> getSubCategories(String parentId) async {
    try {
      final categories = await remoteDataSource.getSubCategories(parentId);
      return Right(categories);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> addCategory(Category category) async {
    try {
      await remoteDataSource.addCategory(CategoryModel(
        id: category.id,
        tenantId: category.tenantId,
        name: category.name,
        description: category.description,
        parentId: category.parentId,
      ));
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateCategory(Category category) async {
    try {
      await remoteDataSource.updateCategory(CategoryModel(
        id: category.id,
        tenantId: category.tenantId,
        name: category.name,
        description: category.description,
        parentId: category.parentId,
      ));
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteCategory(String categoryId) async {
    try {
      await remoteDataSource.deleteCategory(categoryId);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateStock(String productId, double quantityChange) async {
    try {
      await remoteDataSource.updateStock(productId, quantityChange);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  ProductModel _toModel(Product product) {
    return ProductModel(
      id: product.id,
      tenantId: product.tenantId,
      categoryId: product.categoryId,
      name: product.name,
      sku: product.sku,
      barcode: product.barcode,
      description: product.description,
      purchasePrice: product.purchasePrice,
      sellingPrice: product.sellingPrice,
      taxRate: product.taxRate,
      currentStock: product.currentStock,
      lowStockThreshold: product.lowStockThreshold,
      unit: product.unit,
      imageUrl: product.imageUrl,
      createdAt: product.createdAt,
    );
  }
}
