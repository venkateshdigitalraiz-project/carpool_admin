import '../entities/place_prediction.dart';
import '../repositories/places_repository.dart';

class GetPlacePredictionsUseCase {
  final PlacesRepository repository;

  GetPlacePredictionsUseCase(this.repository);

  Future<List<PlacePrediction>> call(String query) async {
    return await repository.getPlacePredictions(query);
  }
}
