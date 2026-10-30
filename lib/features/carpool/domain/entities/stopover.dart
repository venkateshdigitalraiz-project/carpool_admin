import 'package:equatable/equatable.dart';

/// Represents an intermediate stopover / halt along the carpool travel route.
class Stopover extends Equatable {
  final String id;
  final String name;
  final bool isSelected;
  final double? distanceFromOriginKm;

  const Stopover({
    required this.id,
    required this.name,
    this.isSelected = false,
    this.distanceFromOriginKm,
  });

  Stopover copyWith({
    String? id,
    String? name,
    bool? isSelected,
    double? distanceFromOriginKm,
  }) {
    return Stopover(
      id: id ?? this.id,
      name: name ?? this.name,
      isSelected: isSelected ?? this.isSelected,
      distanceFromOriginKm: distanceFromOriginKm ?? this.distanceFromOriginKm,
    );
  }

  @override
  List<Object?> get props => [id, name, isSelected, distanceFromOriginKm];
}
