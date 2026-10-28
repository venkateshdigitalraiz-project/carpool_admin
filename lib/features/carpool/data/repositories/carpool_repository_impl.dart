import '../../domain/entities/carpool_ride.dart';
import '../../domain/entities/passenger_booking.dart';
import '../../domain/repositories/carpool_repository.dart';
import '../datasources/carpool_remote_datasource.dart';
import '../models/carpool_ride_model.dart';

class CarpoolRepositoryImpl implements CarpoolRepository {
  final CarpoolRemoteDataSource remoteDataSource;

  CarpoolRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<CarpoolRide>> getCarpoolRides() async {
    final models = await remoteDataSource.getCarpoolRides();
    return List<CarpoolRide>.from(models);
  }

  @override
  Future<List<CarpoolRide>> searchRides({
    required String origin,
    required String destination,
    required DateTime date,
    int passengers = 1,
  }) async {
    final models = await remoteDataSource.searchRides(
      origin: origin,
      destination: destination,
      date: date,
      passengers: passengers,
    );
    return List<CarpoolRide>.from(models);
  }

  @override
  Future<CarpoolRide> getRideById(String rideId) async {
    return await remoteDataSource.getRideById(rideId);
  }

  @override
  Future<CarpoolRide> publishRide(CarpoolRide ride) async {
    final model = CarpoolRideModel.fromEntity(ride);
    return await remoteDataSource.publishRide(model);
  }

  @override
  Future<PassengerBooking> bookRide({
    required String rideId,
    required String passengerName,
    required String passengerPhone,
    required int seatsCount,
  }) async {
    return await remoteDataSource.bookRide(
      rideId: rideId,
      passengerName: passengerName,
      passengerPhone: passengerPhone,
      seatsCount: seatsCount,
    );
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    return await remoteDataSource.cancelBooking(bookingId);
  }

  @override
  Future<CarpoolRide> updateRideStatus(String rideId, String status) async {
    return await remoteDataSource.updateRideStatus(rideId, status);
  }

  @override
  Future<Map<String, dynamic>> getAdminStats() async {
    return await remoteDataSource.getAdminStats();
  }
}
