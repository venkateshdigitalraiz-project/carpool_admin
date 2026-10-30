import '../../../../core/models/lat_lng.dart';
import '../entities/route_option.dart';
import '../repositories/routes_repository.dart';

class GetRoutesUseCase {
  final RoutesRepository repository;

  const GetRoutesUseCase(this.repository);

  Future<List<RouteOption>> call({
    required String originText,
    required String destinationText,
    LatLng? originLatLng,
    LatLng? destinationLatLng,
  }) {
    return repository.getAvailableRoutes(
      originText: originText,
      destinationText: destinationText,
      originLatLng: originLatLng,
      destinationLatLng: destinationLatLng,
    );
  }
}
