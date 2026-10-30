import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/stopover.dart';
import '../../../domain/usecases/get_stopovers_usecase.dart';
import 'stopovers_event.dart';
import 'stopovers_state.dart';

class StopoversBloc extends Bloc<StopoversEvent, StopoversState> {
  final GetStopoversUseCase getStopoversUseCase;

  StopoversBloc({required this.getStopoversUseCase})
      : super(const StopoversState()) {
    on<LoadStopoversEvent>(_onLoadStopovers);
    on<ToggleStopoverEvent>(_onToggleStopover);
    on<AddCustomStopoverEvent>(_onAddCustomStopover);
    on<RemoveStopoverEvent>(_onRemoveStopover);
  }

  Future<void> _onLoadStopovers(
    LoadStopoversEvent event,
    Emitter<StopoversState> emit,
  ) async {
    emit(state.copyWith(
      status: StopoversStatus.loading,
      origin: event.origin,
      destination: event.destination,
    ));

    try {
      final stopovers = await getStopoversUseCase(
        origin: event.origin,
        destination: event.destination,
        selectedRoute: event.selectedRoute,
      );

      emit(state.copyWith(
        status: StopoversStatus.loaded,
        stopovers: stopovers,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StopoversStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onToggleStopover(
    ToggleStopoverEvent event,
    Emitter<StopoversState> emit,
  ) {
    final updated = state.stopovers.map((s) {
      if (s.id == event.stopoverId) {
        return s.copyWith(isSelected: !s.isSelected);
      }
      return s;
    }).toList();

    emit(state.copyWith(stopovers: updated));
  }

  void _onAddCustomStopover(
    AddCustomStopoverEvent event,
    Emitter<StopoversState> emit,
  ) {
    final clean = event.cityName.trim();
    if (clean.isEmpty) return;

    // Check if already in list
    final exists = state.stopovers.any(
      (s) => s.name.toLowerCase() == clean.toLowerCase(),
    );
    if (exists) {
      // Just select it
      final updated = state.stopovers.map((s) {
        if (s.name.toLowerCase() == clean.toLowerCase()) {
          return s.copyWith(isSelected: true);
        }
        return s;
      }).toList();
      emit(state.copyWith(stopovers: updated));
      return;
    }

    final newStopover = Stopover(
      id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
      name: clean,
      isSelected: true,
    );

    final updated = List<Stopover>.from(state.stopovers)..add(newStopover);
    emit(state.copyWith(stopovers: updated));
  }

  void _onRemoveStopover(
    RemoveStopoverEvent event,
    Emitter<StopoversState> emit,
  ) {
    final updated =
        state.stopovers.where((s) => s.id != event.stopoverId).toList();
    emit(state.copyWith(stopovers: updated));
  }
}
