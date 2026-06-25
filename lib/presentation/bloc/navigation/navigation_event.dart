import 'package:equatable/equatable.dart';

enum AdminSection { dashboard, users, inventory, customers, reports, settings }

abstract class NavigationEvent extends Equatable {
  const NavigationEvent();
  @override
  List<Object?> get props => [];
}

class NavigateToSection extends NavigationEvent {
  final AdminSection section;
  const NavigateToSection(this.section);
  @override
  List<Object?> get props => [section];
}
