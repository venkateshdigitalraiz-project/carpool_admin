import '../entities/carpool_ride.dart';
import '../repositories/carpool_repository.dart';

class PublishRideUseCase {
  final CarpoolRepository repository;

  PublishRideUseCase(this.repository);

  Future<CarpoolRide> call(CarpoolRide ride) async {
    return await repository.publishRide(ride);
  }
}
