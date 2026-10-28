import 'package:equatable/equatable.dart';
import '../../domain/entities/place_prediction.dart';
import 'places_event.dart';

class PlacesState extends Equatable {
  final List<PlacePrediction> originPredictions;
  final List<PlacePrediction> destPredictions;
  final bool isOriginLoading;
  final bool isDestLoading;
  final String? errorMessage;
  final PlaceSearchTarget? activeTarget;
  final PlacePrediction? lastSelectedOrigin;
  final PlacePrediction? lastSelectedDestination;

  const PlacesState({
    this.originPredictions = const [],
    this.destPredictions = const [],
    this.isOriginLoading = false,
    this.isDestLoading = false,
    this.errorMessage,
    this.activeTarget,
    this.lastSelectedOrigin,
    this.lastSelectedDestination,
  });

  PlacesState copyWith({
    List<PlacePrediction>? originPredictions,
    List<PlacePrediction>? destPredictions,
    bool? isOriginLoading,
    bool? isDestLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
    PlaceSearchTarget? activeTarget,
    bool clearActiveTarget = false,
    PlacePrediction? lastSelectedOrigin,
    PlacePrediction? lastSelectedDestination,
  }) {
    return PlacesState(
      originPredictions: originPredictions ?? this.originPredictions,
      destPredictions: destPredictions ?? this.destPredictions,
      isOriginLoading: isOriginLoading ?? this.isOriginLoading,
      isDestLoading: isDestLoading ?? this.isDestLoading,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      activeTarget:
          clearActiveTarget ? null : (activeTarget ?? this.activeTarget),
      lastSelectedOrigin: lastSelectedOrigin ?? this.lastSelectedOrigin,
      lastSelectedDestination:
          lastSelectedDestination ?? this.lastSelectedDestination,
    );
  }

  @override
  List<Object?> get props => [
        originPredictions,
        destPredictions,
        isOriginLoading,
        isDestLoading,
        errorMessage,
        activeTarget,
        lastSelectedOrigin,
        lastSelectedDestination,
      ];
}
