import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_routes_usecase.dart';
import 'route_selection_event.dart';
import 'route_selection_state.dart';

class RouteSelectionBloc extends Bloc<RouteSelectionEvent, RouteSelectionState> {
  final GetRoutesUseCase getRoutesUseCase;

  RouteSelectionBloc({required this.getRoutesUseCase})
      : super(const RouteSelectionState()) {
    on<LoadRoutesEvent>(_onLoadRoutes);
    on<SelectRouteOptionEvent>(_onSelectRouteOption);
    on<ClearRouteSelectionEvent>(_onClearRouteSelection);
  }

  Future<void> _onLoadRoutes(
    LoadRoutesEvent event,
    Emitter<RouteSelectionState> emit,
  ) async {
    emit(state.copyWith(
      status: RouteSelectionStatus.loading,
      origin: event.origin,
      destination: event.destination,
      originLatLng: event.originLatLng,
      destinationLatLng: event.destinationLatLng,
    ));

    try {
      final routes = await getRoutesUseCase(
        originText: event.origin,
        destinationText: event.destination,
        originLatLng: event.originLatLng,
        destinationLatLng: event.destinationLatLng,
      );

      final initialSelected = routes.firstWhere(
        (r) => r.isRecommended,
        orElse: () => routes.first,
      );

      emit(state.copyWith(
        status: RouteSelectionStatus.loaded,
        routes: routes,
        selectedRoute: initialSelected,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: RouteSelectionStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onSelectRouteOption(
    SelectRouteOptionEvent event,
    Emitter<RouteSelectionState> emit,
  ) {
    if (state.routes.isEmpty) return;
    final match = state.routes.firstWhere(
      (r) => r.id == event.routeId,
      orElse: () => state.routes.first,
    );
    emit(state.copyWith(selectedRoute: match));
  }

  void _onClearRouteSelection(
    ClearRouteSelectionEvent event,
    Emitter<RouteSelectionState> emit,
  ) {
    emit(const RouteSelectionState());
  }
}
