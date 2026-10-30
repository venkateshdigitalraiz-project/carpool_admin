import '../entities/route_option.dart';
import '../entities/stopover.dart';
import '../repositories/stopovers_repository.dart';

class GetStopoversUseCase {
  final StopoversRepository repository;

  const GetStopoversUseCase(this.repository);

  Future<List<Stopover>> call({
    required String origin,
    required String destination,
    RouteOption? selectedRoute,
  }) {
    return repository.getSuggestedStopovers(
      origin: origin,
      destination: destination,
      selectedRoute: selectedRoute,
    );
  }
}
