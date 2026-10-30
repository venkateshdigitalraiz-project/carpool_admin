import 'package:equatable/equatable.dart';
import '../../../../../core/models/lat_lng.dart';

abstract class RouteSelectionEvent extends Equatable {
  const RouteSelectionEvent();

  @override
  List<Object?> get props => [];
}

class LoadRoutesEvent extends RouteSelectionEvent {
  final String origin;
  final String destination;
  final LatLng? originLatLng;
  final LatLng? destinationLatLng;

  const LoadRoutesEvent({
    required this.origin,
    required this.destination,
    this.originLatLng,
    this.destinationLatLng,
  });

  @override
  List<Object?> get props => [origin, destination, originLatLng, destinationLatLng];
}

class SelectRouteOptionEvent extends RouteSelectionEvent {
  final String routeId;

  const SelectRouteOptionEvent(this.routeId);

  @override
  List<Object?> get props => [routeId];
}

class ClearRouteSelectionEvent extends RouteSelectionEvent {
  const ClearRouteSelectionEvent();
}
