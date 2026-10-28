import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_place_predictions_usecase.dart';
import 'places_event.dart';
import 'places_state.dart';

class PlacesBloc extends Bloc<PlacesEvent, PlacesState> {
  final GetPlacePredictionsUseCase getPlacePredictionsUseCase;

  PlacesBloc({required this.getPlacePredictionsUseCase})
      : super(const PlacesState()) {
    on<SearchPlacesQueryEvent>(_onSearchPlacesQuery);
    on<SelectPlacePredictionEvent>(_onSelectPlacePrediction);
    on<ClearPlacesEvent>(_onClearPlaces);
  }

  Future<void> _onSearchPlacesQuery(
    SearchPlacesQueryEvent event,
    Emitter<PlacesState> emit,
  ) async {
    final trimmed = event.query.trim();

    if (trimmed.length < 2) {
      if (event.target == PlaceSearchTarget.origin) {
        emit(state.copyWith(
          originPredictions: const [],
          isOriginLoading: false,
          activeTarget: null,
        ));
      } else {
        emit(state.copyWith(
          destPredictions: const [],
          isDestLoading: false,
          activeTarget: null,
        ));
      }
      return;
    }

    // Set loading and active target
    if (event.target == PlaceSearchTarget.origin) {
      emit(state.copyWith(
        isOriginLoading: true,
        activeTarget: PlaceSearchTarget.origin,
        clearErrorMessage: true,
      ));

      try {
        final results = await getPlacePredictionsUseCase(trimmed);
        emit(state.copyWith(
          originPredictions: results,
          isOriginLoading: false,
        ));
      } catch (e) {
        emit(state.copyWith(
          isOriginLoading: false,
          errorMessage: e.toString(),
        ));
      }
    } else {
      emit(state.copyWith(
        isDestLoading: true,
        activeTarget: PlaceSearchTarget.destination,
        clearErrorMessage: true,
      ));

      try {
        final results = await getPlacePredictionsUseCase(trimmed);
        emit(state.copyWith(
          destPredictions: results,
          isDestLoading: false,
        ));
      } catch (e) {
        emit(state.copyWith(
          isDestLoading: false,
          errorMessage: e.toString(),
        ));
      }
    }
  }

  void _onSelectPlacePrediction(
    SelectPlacePredictionEvent event,
    Emitter<PlacesState> emit,
  ) {
    if (event.target == PlaceSearchTarget.origin) {
      emit(state.copyWith(
        originPredictions: const [],
        isOriginLoading: false,
        clearActiveTarget: true,
        lastSelectedOrigin: event.prediction,
      ));
    } else {
      emit(state.copyWith(
        destPredictions: const [],
        isDestLoading: false,
        clearActiveTarget: true,
        lastSelectedDestination: event.prediction,
      ));
    }
  }

  void _onClearPlaces(
    ClearPlacesEvent event,
    Emitter<PlacesState> emit,
  ) {
    if (event.target == PlaceSearchTarget.origin) {
      emit(state.copyWith(
        originPredictions: const [],
        isOriginLoading: false,
        clearActiveTarget: state.activeTarget == PlaceSearchTarget.origin,
      ));
    } else if (event.target == PlaceSearchTarget.destination) {
      emit(state.copyWith(
        destPredictions: const [],
        isDestLoading: false,
        clearActiveTarget: state.activeTarget == PlaceSearchTarget.destination,
      ));
    } else {
      emit(state.copyWith(
        originPredictions: const [],
        destPredictions: const [],
        isOriginLoading: false,
        isDestLoading: false,
        clearActiveTarget: true,
      ));
    }
  }
}
