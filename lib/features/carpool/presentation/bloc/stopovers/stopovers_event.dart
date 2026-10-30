import 'package:equatable/equatable.dart';
import '../../../domain/entities/route_option.dart';

abstract class StopoversEvent extends Equatable {
  const StopoversEvent();

  @override
  List<Object?> get props => [];
}

class LoadStopoversEvent extends StopoversEvent {
  final String origin;
  final String destination;
  final RouteOption? selectedRoute;

  const LoadStopoversEvent({
    required this.origin,
    required this.destination,
    this.selectedRoute,
  });

  @override
  List<Object?> get props => [origin, destination, selectedRoute];
}

class ToggleStopoverEvent extends StopoversEvent {
  final String stopoverId;

  const ToggleStopoverEvent(this.stopoverId);

  @override
  List<Object?> get props => [stopoverId];
}

class AddCustomStopoverEvent extends StopoversEvent {
  final String cityName;

  const AddCustomStopoverEvent(this.cityName);

  @override
  List<Object?> get props => [cityName];
}

class RemoveStopoverEvent extends StopoversEvent {
  final String stopoverId;

  const RemoveStopoverEvent(this.stopoverId);

  @override
  List<Object?> get props => [stopoverId];
}
