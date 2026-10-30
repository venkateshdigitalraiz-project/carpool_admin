import '../../../../core/models/lat_lng.dart';
import '../../domain/entities/route_option.dart';
import '../../domain/repositories/routes_repository.dart';
import '../datasources/routes_remote_datasource.dart';

class RoutesRepositoryImpl implements RoutesRepository {
  final RoutesRemoteDataSource remoteDataSource;

  RoutesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<RouteOption>> getAvailableRoutes({
    required String originText,
    required String destinationText,
    LatLng? originLatLng,
    LatLng? destinationLatLng,
  }) {
    return remoteDataSource.fetchRoutes(
      originText: originText,
      destinationText: destinationText,
      originLatLng: originLatLng,
      destinationLatLng: destinationLatLng,
    );
  }
}
