import '../repositories/carpool_repository.dart';

class CancelBookingUseCase {
  final CarpoolRepository repository;

  CancelBookingUseCase(this.repository);

  Future<void> call(String bookingId) async {
    return await repository.cancelBooking(bookingId);
  }
}
