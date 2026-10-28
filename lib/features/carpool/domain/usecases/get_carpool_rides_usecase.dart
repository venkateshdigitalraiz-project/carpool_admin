import '../entities/carpool_ride.dart';
import '../repositories/carpool_repository.dart';

class GetCarpoolRidesUseCase {
  final CarpoolRepository repository;

  GetCarpoolRidesUseCase(this.repository);

  Future<List<CarpoolRide>> call() async {
    return await repository.getCarpoolRides();
  }
}
