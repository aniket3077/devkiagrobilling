import 'package:equatable/equatable.dart';
import '../../../domain/entities/product.dart';

abstract class ProductState extends Equatable {
  const ProductState();
  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductsLoaded extends ProductState {
  final List<Product> products;
  const ProductsLoaded(this.products);
  @override
  List<Object?> get props => [products];
}

class CategoriesLoaded extends ProductState {
  final List<Category> categories;
  const CategoriesLoaded(this.categories);
}

class ProductError extends ProductState {
  final String message;
  const ProductError(this.message);
}

class ProductOperationSuccess extends ProductState {}
