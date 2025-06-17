import 'package:equatable/equatable.dart';
import '../../models/pantry_item.dart';

enum PantryStatus { initial, loading, loaded, error }

class PantryState extends Equatable {
  final List<PantryItem> items;
  final Map<String, List<PantryItem>> categorizedItems;
  final PantryStatus status;
  final String? errorMessage;

  const PantryState({
    this.items = const [],
    this.categorizedItems = const {},
    this.status = PantryStatus.initial,
    this.errorMessage,
  });

  PantryState copyWith({
    List<PantryItem>? items,
    Map<String, List<PantryItem>>? categorizedItems,
    PantryStatus? status,
    String? errorMessage,
  }) {
    return PantryState(
      items: items ?? this.items,
      categorizedItems: categorizedItems ?? this.categorizedItems,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [items, categorizedItems, status, errorMessage];
}
