import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/product_repository.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final ProductRepository productRepository;

  CategoryBloc({required this.productRepository}) : super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<LoadSubCategories>(_onLoadSubCategories);
    on<AddCategoryEvent>(_onAddCategory);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
  }

  Future<void> _onLoadCategories(LoadCategories event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());
    final result = await productRepository.getCategories(event.tenantId);
    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (categories) => emit(CategoriesLoaded(categories)),
    );
  }

  Future<void> _onLoadSubCategories(LoadSubCategories event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());
    final result = await productRepository.getSubCategories(event.parentId);
    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (categories) => emit(CategoriesLoaded(categories)),
    );
  }

  Future<void> _onAddCategory(AddCategoryEvent event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());
    final result = await productRepository.addCategory(event.category);
    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (_) => emit(CategoryOperationSuccess()),
    );
  }

  Future<void> _onUpdateCategory(UpdateCategoryEvent event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());
    final result = await productRepository.updateCategory(event.category);
    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (_) => emit(CategoryOperationSuccess()),
    );
  }

  Future<void> _onDeleteCategory(DeleteCategoryEvent event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());
    final result = await productRepository.deleteCategory(event.categoryId);
    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (_) => emit(CategoryOperationSuccess()),
    );
  }
}
