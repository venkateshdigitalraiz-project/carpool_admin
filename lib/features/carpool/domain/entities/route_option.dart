import 'package:equatable/equatable.dart';
import '../../../../core/models/lat_lng.dart';

/// Represents a selectable travel route option with distance, duration, tolls, and map waypoints.
class RouteOption extends Equatable {
  final String id;
  final String durationText; // e.g. "7 hr 40 min"
  final int durationMinutes; // e.g. 460
  final double distanceKm; // e.g. 415.0
  final bool hasTolls; // true -> "Tolls", false -> "No tolls"
  final String highwayName; // e.g. "Greenfield Hwy/Khammam - Devarapalli Expy"
  final List<LatLng> polylinePoints;
  final bool isRecommended;

  const RouteOption({
    required this.id,
    required this.durationText,
    required this.durationMinutes,
    required this.distanceKm,
    required this.hasTolls,
    required this.highwayName,
    required this.polylinePoints,
    this.isRecommended = false,
  });

  /// Displays "Tolls" or "No tolls"
  String get tollsLabel => hasTolls ? 'Tolls' : 'No tolls';

  /// Primary line in UI: "7 hr 40 min - Tolls"
  String get title => '$durationText - $tollsLabel';

  /// Secondary line in UI: "415 km - Greenfield Hwy/Khammam - Devarapalli Expy"
  String get subtitle => '${distanceKm.round()} km - $highwayName';

  RouteOption copyWith({
    String? id,
    String? durationText,
    int? durationMinutes,
    double? distanceKm,
    bool? hasTolls,
    String? highwayName,
    List<LatLng>? polylinePoints,
    bool? isRecommended,
  }) {
    return RouteOption(
      id: id ?? this.id,
      durationText: durationText ?? this.durationText,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      distanceKm: distanceKm ?? this.distanceKm,
      hasTolls: hasTolls ?? this.hasTolls,
      highwayName: highwayName ?? this.highwayName,
      polylinePoints: polylinePoints ?? this.polylinePoints,
      isRecommended: isRecommended ?? this.isRecommended,
    );
  }

  @override
  List<Object?> get props => [
        id,
        durationText,
        durationMinutes,
        distanceKm,
        hasTolls,
        highwayName,
        polylinePoints,
        isRecommended,
      ];
}
