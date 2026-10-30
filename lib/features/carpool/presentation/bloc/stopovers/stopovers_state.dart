import 'package:equatable/equatable.dart';
import '../../../domain/entities/stopover.dart';

enum StopoversStatus { initial, loading, loaded, error }

class StopoversState extends Equatable {
  final StopoversStatus status;
  final List<Stopover> stopovers;
  final String origin;
  final String destination;
  final String? errorMessage;

  const StopoversState({
    this.status = StopoversStatus.initial,
    this.stopovers = const [],
    this.origin = '',
    this.destination = '',
    this.errorMessage,
  });

  bool get isLoading => status == StopoversStatus.loading;
  bool get isLoaded => status == StopoversStatus.loaded;

  List<Stopover> get selectedStopovers =>
      stopovers.where((s) => s.isSelected).toList();

  List<String> get selectedStopoverNames =>
      selectedStopovers.map((s) => s.name).toList();

  StopoversState copyWith({
    StopoversStatus? status,
    List<Stopover>? stopovers,
    String? origin,
    String? destination,
    String? errorMessage,
  }) {
    return StopoversState(
      status: status ?? this.status,
      stopovers: stopovers ?? this.stopovers,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        stopovers,
        origin,
        destination,
        errorMessage,
      ];
}
