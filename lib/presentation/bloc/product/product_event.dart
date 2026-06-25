import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/product.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();
  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductEvent {
  final String tenantId;
  const LoadProducts(this.tenantId);
  @override
  List<Object?> get props => [tenantId];
}

class SearchProducts extends ProductEvent {
  final String tenantId;
  final String query;
  const SearchProducts(this.tenantId, this.query);
}

class AddProductEvent extends ProductEvent {
  final Product product;
  final File? imageFile;
  const AddProductEvent(this.product, this.imageFile);
}

class UpdateProductEvent extends ProductEvent {
  final Product product;
  final File? imageFile;
  const UpdateProductEvent(this.product, this.imageFile);
}

class DeleteProductEvent extends ProductEvent {
  final String productId;
  const DeleteProductEvent(this.productId);
}

class LoadCategories extends ProductEvent {
  final String tenantId;
  const LoadCategories(this.tenantId);
}
