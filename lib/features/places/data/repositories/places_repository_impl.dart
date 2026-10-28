import '../../domain/entities/place_prediction.dart';
import '../../domain/repositories/places_repository.dart';
import '../datasources/places_remote_datasource.dart';

class PlacesRepositoryImpl implements PlacesRepository {
  final PlacesRemoteDataSource remoteDataSource;

  PlacesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<PlacePrediction>> getPlacePredictions(String query) async {
    return await remoteDataSource.getPlacePredictions(query);
  }
}
