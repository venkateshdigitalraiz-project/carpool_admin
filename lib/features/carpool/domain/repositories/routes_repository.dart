import '../../../../core/models/lat_lng.dart';
import '../entities/route_option.dart';

abstract class RoutesRepository {
  /// Fetches available travel routes with distance, duration, tolls, and polyline points.
  Future<List<RouteOption>> getAvailableRoutes({
    required String originText,
    required String destinationText,
    LatLng? originLatLng,
    LatLng? destinationLatLng,
  });
}
