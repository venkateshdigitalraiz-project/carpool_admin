import '../entities/place_prediction.dart';

abstract class PlacesRepository {
  Future<List<PlacePrediction>> getPlacePredictions(String query);
}
