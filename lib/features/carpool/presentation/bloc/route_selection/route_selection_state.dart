import 'package:equatable/equatable.dart';
import '../../../../../core/models/lat_lng.dart';
import '../../../domain/entities/route_option.dart';

enum RouteSelectionStatus { initial, loading, loaded, error }

class RouteSelectionState extends Equatable {
  final RouteSelectionStatus status;
  final List<RouteOption> routes;
  final RouteOption? selectedRoute;
  final String origin;
  final String destination;
  final LatLng? originLatLng;
  final LatLng? destinationLatLng;
  final String? errorMessage;

  const RouteSelectionState({
    this.status = RouteSelectionStatus.initial,
    this.routes = const [],
    this.selectedRoute,
    this.origin = '',
    this.destination = '',
    this.originLatLng,
    this.destinationLatLng,
    this.errorMessage,
  });

  bool get isLoading => status == RouteSelectionStatus.loading;
  bool get isLoaded => status == RouteSelectionStatus.loaded;

  RouteSelectionState copyWith({
    RouteSelectionStatus? status,
    List<RouteOption>? routes,
    RouteOption? selectedRoute,
    String? origin,
    String? destination,
    LatLng? originLatLng,
    LatLng? destinationLatLng,
    String? errorMessage,
  }) {
    return RouteSelectionState(
      status: status ?? this.status,
      routes: routes ?? this.routes,
      selectedRoute: selectedRoute ?? this.selectedRoute,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      originLatLng: originLatLng ?? this.originLatLng,
      destinationLatLng: destinationLatLng ?? this.destinationLatLng,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        routes,
        selectedRoute,
        origin,
        destination,
        originLatLng,
        destinationLatLng,
        errorMessage,
      ];
}
