import 'package:equatable/equatable.dart';
import '../../../domain/entities/product.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();
  @override
  List<Object?> get props => [];
}

class LoadCategories extends CategoryEvent {
  final String tenantId;
  const LoadCategories(this.tenantId);
}

class LoadSubCategories extends CategoryEvent {
  final String parentId;
  const LoadSubCategories(this.parentId);
}

class AddCategoryEvent extends CategoryEvent {
  final Category category;
  const AddCategoryEvent(this.category);
}

class UpdateCategoryEvent extends CategoryEvent {
  final Category category;
  const UpdateCategoryEvent(this.category);
}

class DeleteCategoryEvent extends CategoryEvent {
  final String categoryId;
  const DeleteCategoryEvent(this.categoryId);
}
