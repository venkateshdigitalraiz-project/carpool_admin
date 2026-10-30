import '../../domain/entities/route_option.dart';
import '../../domain/entities/stopover.dart';
import '../../domain/repositories/stopovers_repository.dart';
import '../datasources/stopovers_remote_datasource.dart';

class StopoversRepositoryImpl implements StopoversRepository {
  final StopoversRemoteDataSource remoteDataSource;

  StopoversRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Stopover>> getSuggestedStopovers({
    required String origin,
    required String destination,
    RouteOption? selectedRoute,
  }) {
    return remoteDataSource.fetchSuggestedStopovers(
      origin: origin,
      destination: destination,
      selectedRoute: selectedRoute,
    );
  }
}
