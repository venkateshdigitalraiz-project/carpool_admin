import '../entities/carpool_ride.dart';
import '../repositories/carpool_repository.dart';

class SearchRidesUseCase {
  final CarpoolRepository repository;

  SearchRidesUseCase(this.repository);

  Future<List<CarpoolRide>> call({
    required String origin,
    required String destination,
    required DateTime date,
    int passengers = 1,
  }) async {
    return await repository.searchRides(
      origin: origin,
      destination: destination,
      date: date,
      passengers: passengers,
    );
  }
}
