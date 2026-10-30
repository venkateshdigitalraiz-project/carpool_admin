import 'package:equatable/equatable.dart';

/// Lightweight geographic coordinate representation for map projection and route polylines.
class LatLng extends Equatable {
  final double latitude;
  final double longitude;

  const LatLng(this.latitude, this.longitude);

  @override
  List<Object?> get props => [latitude, longitude];

  @override
  String toString() => 'LatLng($latitude, $longitude)';
}
