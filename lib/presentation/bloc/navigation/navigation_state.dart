import 'package:equatable/equatable.dart';
import 'navigation_event.dart';

class NavigationState extends Equatable {
  final AdminSection currentSection;

  const NavigationState(this.currentSection);

  @override
  List<Object?> get props => [currentSection];
}
