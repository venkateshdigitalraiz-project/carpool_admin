import '../entities/route_option.dart';
import '../entities/stopover.dart';

abstract class StopoversRepository {
  /// Fetches recommended stopover halts along the route between origin and destination.
  Future<List<Stopover>> getSuggestedStopovers({
    required String origin,
    required String destination,
    RouteOption? selectedRoute,
  });
}
