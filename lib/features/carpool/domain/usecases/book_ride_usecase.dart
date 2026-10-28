import '../entities/passenger_booking.dart';
import '../repositories/carpool_repository.dart';

class BookRideUseCase {
  final CarpoolRepository repository;

  BookRideUseCase(this.repository);

  Future<PassengerBooking> call({
    required String rideId,
    required String passengerName,
    required String passengerPhone,
    required int seatsCount,
  }) async {
    return await repository.bookRide(
      rideId: rideId,
      passengerName: passengerName,
      passengerPhone: passengerPhone,
      seatsCount: seatsCount,
    );
  }
}
