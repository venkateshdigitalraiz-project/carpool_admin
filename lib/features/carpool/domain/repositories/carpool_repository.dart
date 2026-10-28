import '../entities/carpool_ride.dart';
import '../entities/passenger_booking.dart';

abstract class CarpoolRepository {
  Future<List<CarpoolRide>> getCarpoolRides();

  Future<List<CarpoolRide>> searchRides({
    required String origin,
    required String destination,
    required DateTime date,
    int passengers = 1,
  });

  Future<CarpoolRide> getRideById(String rideId);

  Future<CarpoolRide> publishRide(CarpoolRide ride);

  Future<PassengerBooking> bookRide({
    required String rideId,
    required String passengerName,
    required String passengerPhone,
    required int seatsCount,
  });

  Future<void> cancelBooking(String bookingId);

  Future<CarpoolRide> updateRideStatus(String rideId, String status);

  Future<Map<String, dynamic>> getAdminStats();
}
