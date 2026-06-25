import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/product_repository.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository productRepository;

  ProductBloc({required this.productRepository}) : super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<SearchProducts>(_onSearchProducts);
    on<AddProductEvent>(_onAddProduct);
    on<UpdateProductEvent>(_onUpdateProduct);
    on<DeleteProductEvent>(_onDeleteProduct);
    on<LoadCategories>(_onLoadCategories);
  }

  Future<void> _onLoadProducts(LoadProducts event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    final result = await productRepository.getProducts(event.tenantId);
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (products) => emit(ProductsLoaded(products)),
    );
  }

  Future<void> _onSearchProducts(SearchProducts event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    final result = await productRepository.searchProducts(event.tenantId, event.query);
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (products) => emit(ProductsLoaded(products)),
    );
  }

  Future<void> _onAddProduct(AddProductEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    final result = await productRepository.addProduct(event.product, event.imageFile);
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (_) => emit(ProductOperationSuccess()),
    );
  }

  Future<void> _onUpdateProduct(UpdateProductEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    final result = await productRepository.updateProduct(event.product, event.imageFile);
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (_) => emit(ProductOperationSuccess()),
    );
  }

  Future<void> _onDeleteProduct(DeleteProductEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    final result = await productRepository.deleteProduct(event.productId);
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (_) => emit(ProductOperationSuccess()),
    );
  }

  Future<void> _onLoadCategories(LoadCategories event, Emitter<ProductState> emit) async {
    final result = await productRepository.getCategories(event.tenantId);
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (categories) => emit(CategoriesLoaded(categories)),
    );
  }
}
