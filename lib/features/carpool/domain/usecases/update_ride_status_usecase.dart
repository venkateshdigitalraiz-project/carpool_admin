import '../entities/carpool_ride.dart';
import '../repositories/carpool_repository.dart';

class UpdateRideStatusUseCase {
  final CarpoolRepository repository;

  UpdateRideStatusUseCase(this.repository);

  Future<CarpoolRide> call(String rideId, String status) async {
    return await repository.updateRideStatus(rideId, status);
  }
}
