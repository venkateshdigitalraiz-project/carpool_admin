import 'package:equatable/equatable.dart';
import '../../domain/entities/place_prediction.dart';

enum PlaceSearchTarget { origin, destination }

abstract class PlacesEvent extends Equatable {
  const PlacesEvent();

  @override
  List<Object?> get props => [];
}

class SearchPlacesQueryEvent extends PlacesEvent {
  final String query;
  final PlaceSearchTarget target;

  const SearchPlacesQueryEvent({
    required this.query,
    required this.target,
  });

  @override
  List<Object?> get props => [query, target];
}

class SelectPlacePredictionEvent extends PlacesEvent {
  final PlacePrediction prediction;
  final PlaceSearchTarget target;

  const SelectPlacePredictionEvent({
    required this.prediction,
    required this.target,
  });

  @override
  List<Object?> get props => [prediction, target];
}

class ClearPlacesEvent extends PlacesEvent {
  final PlaceSearchTarget? target;

  const ClearPlacesEvent({this.target});

  @override
  List<Object?> get props => [target];
}
