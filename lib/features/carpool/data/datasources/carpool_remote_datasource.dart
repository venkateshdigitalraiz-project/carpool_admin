import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_endpoints.dart';
import '../models/carpool_ride_model.dart';
import '../models/passenger_booking_model.dart';

abstract class CarpoolRemoteDataSource {
  Future<List<CarpoolRideModel>> getCarpoolRides();
  Future<List<CarpoolRideModel>> searchRides({
    required String origin,
    required String destination,
    required DateTime date,
    int passengers = 1,
  });
  Future<CarpoolRideModel> getRideById(String rideId);
  Future<CarpoolRideModel> publishRide(CarpoolRideModel ride);
  Future<PassengerBookingModel> bookRide({
    required String rideId,
    required String passengerName,
    required String passengerPhone,
    required int seatsCount,
  });
  Future<void> cancelBooking(String bookingId);
  Future<CarpoolRideModel> updateRideStatus(String rideId, String status);
  Future<Map<String, dynamic>> getAdminStats();
}

class CarpoolRemoteDataSourceImpl implements CarpoolRemoteDataSource {
  final http.Client client;

  // In-memory persistent state so the app works seamlessly even offline
  static final List<CarpoolRideModel> _mockRides = _initMockRides();

  CarpoolRemoteDataSourceImpl({http.Client? client})
      : client = client ?? http.Client();

  @override
  Future<List<CarpoolRideModel>> getCarpoolRides() async {
    try {
      final response = await client
          .get(Uri.parse(ApiEndpoints.carpoolRides))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List list = decoded is List ? decoded : (decoded['data'] ?? []);
        if (list.isNotEmpty) {
          return list.map((e) => CarpoolRideModel.fromJson(e)).toList();
        }
      }
    } catch (_) {
      // Fallback to local high-fidelity BlaBlaCar mock store
    }
    return List.from(_mockRides);
  }

  @override
  Future<List<CarpoolRideModel>> searchRides({
    required String origin,
    required String destination,
    required DateTime date,
    int passengers = 1,
  }) async {
    try {
      final uri = Uri.parse(ApiEndpoints.carpoolSearch).replace(queryParameters: {
        'origin': origin,
        'destination': destination,
        'date': date.toIso8601String(),
        'passengers': passengers.toString(),
      });
      final response = await client.get(uri).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List list = decoded is List ? decoded : (decoded['data'] ?? []);
        if (list.isNotEmpty) {
          return list.map((e) => CarpoolRideModel.fromJson(e)).toList();
        }
      }
    } catch (_) {
      // Fallback search algorithm
    }

    final queryOrigin = origin.trim().toLowerCase();
    final queryDest = destination.trim().toLowerCase();

    return _mockRides.where((ride) {
      final matchOrigin = queryOrigin.isEmpty ||
          ride.origin.toLowerCase().contains(queryOrigin) ||
          ride.originAddress.toLowerCase().contains(queryOrigin);
      final matchDest = queryDest.isEmpty ||
          ride.destination.toLowerCase().contains(queryDest) ||
          ride.destinationAddress.toLowerCase().contains(queryDest);
      final hasEnoughSeats = ride.availableSeats >= passengers;
      final isActive = ride.status == 'ACTIVE';

      return matchOrigin && matchDest && hasEnoughSeats && isActive;
    }).toList();
  }

  @override
  Future<CarpoolRideModel> getRideById(String rideId) async {
    try {
      final response = await client
          .get(Uri.parse(ApiEndpoints.carpoolRideDetail(rideId)))
          .timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return CarpoolRideModel.fromJson(decoded['data'] ?? decoded);
      }
    } catch (_) {}

    return _mockRides.firstWhere(
      (r) => r.id == rideId,
      orElse: () => _mockRides.first,
    );
  }

  @override
  Future<CarpoolRideModel> publishRide(CarpoolRideModel ride) async {
    try {
      final response = await client
          .post(
            Uri.parse(ApiEndpoints.carpoolPublish),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(ride.toJson()),
          )
          .timeout(const Duration(seconds: 4));
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        final created = CarpoolRideModel.fromJson(decoded['data'] ?? decoded);
        _mockRides.insert(0, created);
        return created;
      }
    } catch (_) {}

    _mockRides.insert(0, ride);
    return ride;
  }

  @override
  Future<PassengerBookingModel> bookRide({
    required String rideId,
    required String passengerName,
    required String passengerPhone,
    required int seatsCount,
  }) async {
    final rideIndex = _mockRides.indexWhere((r) => r.id == rideId);
    if (rideIndex == -1) {
      throw Exception('Ride not found');
    }

    final currentRide = _mockRides[rideIndex];
    if (currentRide.availableSeats < seatsCount) {
      throw Exception('Not enough seats available');
    }

    final booking = PassengerBookingModel(
      id: 'bk-${DateTime.now().millisecondsSinceEpoch}',
      rideId: rideId,
      passengerName: passengerName,
      passengerPhone: passengerPhone,
      seatsBooked: seatsCount,
      totalPrice: currentRide.pricePerSeat * seatsCount,
      bookedAt: DateTime.now(),
      status: 'CONFIRMED',
    );

    final updatedBookings = List<PassengerBookingModel>.from(
      currentRide.bookings.map((b) => PassengerBookingModel.fromEntity(b)),
    )..add(booking);

    final newAvailableSeats = currentRide.availableSeats - seatsCount;
    final updatedRide = CarpoolRideModel(
      id: currentRide.id,
      origin: currentRide.origin,
      originAddress: currentRide.originAddress,
      destination: currentRide.destination,
      destinationAddress: currentRide.destinationAddress,
      departureTime: currentRide.departureTime,
      arrivalTime: currentRide.arrivalTime,
      durationMinutes: currentRide.durationMinutes,
      distanceKm: currentRide.distanceKm,
      pricePerSeat: currentRide.pricePerSeat,
      totalSeats: currentRide.totalSeats,
      availableSeats: newAvailableSeats,
      driver: currentRide.driver,
      amenities: currentRide.amenities,
      intermediateStops: currentRide.intermediateStops,
      status: newAvailableSeats == 0 ? 'FULL' : currentRide.status,
      bookings: updatedBookings,
    );

    _mockRides[rideIndex] = updatedRide;
    return booking;
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    for (int i = 0; i < _mockRides.length; i++) {
      final ride = _mockRides[i];
      final bIndex = ride.bookings.indexWhere((b) => b.id == bookingId);
      if (bIndex != -1) {
        final canceledSeats = ride.bookings[bIndex].seatsBooked;
        final updatedBookings = List<PassengerBookingModel>.from(
          ride.bookings.map((b) => PassengerBookingModel.fromEntity(b)),
        )..removeAt(bIndex);

        _mockRides[i] = CarpoolRideModel(
          id: ride.id,
          origin: ride.origin,
          originAddress: ride.originAddress,
          destination: ride.destination,
          destinationAddress: ride.destinationAddress,
          departureTime: ride.departureTime,
          arrivalTime: ride.arrivalTime,
          durationMinutes: ride.durationMinutes,
          distanceKm: ride.distanceKm,
          pricePerSeat: ride.pricePerSeat,
          totalSeats: ride.totalSeats,
          availableSeats: (ride.availableSeats + canceledSeats).clamp(0, ride.totalSeats),
          driver: ride.driver,
          amenities: ride.amenities,
          intermediateStops: ride.intermediateStops,
          status: 'ACTIVE',
          bookings: updatedBookings,
        );
        break;
      }
    }
  }

  @override
  Future<CarpoolRideModel> updateRideStatus(String rideId, String status) async {
    final index = _mockRides.indexWhere((r) => r.id == rideId);
    if (index != -1) {
      final current = _mockRides[index];
      final updated = CarpoolRideModel(
        id: current.id,
        origin: current.origin,
        originAddress: current.originAddress,
        destination: current.destination,
        destinationAddress: current.destinationAddress,
        departureTime: current.departureTime,
        arrivalTime: current.arrivalTime,
        durationMinutes: current.durationMinutes,
        distanceKm: current.distanceKm,
        pricePerSeat: current.pricePerSeat,
        totalSeats: current.totalSeats,
        availableSeats: current.availableSeats,
        driver: current.driver,
        amenities: current.amenities,
        intermediateStops: current.intermediateStops,
        status: status,
        bookings: current.bookings,
      );
      _mockRides[index] = updated;
      return updated;
    }
    throw Exception('Ride not found');
  }

  @override
  Future<Map<String, dynamic>> getAdminStats() async {
    int totalRides = _mockRides.length;
    int activeRides = _mockRides.where((r) => r.status == 'ACTIVE').length;
    int totalSeats = _mockRides.fold(0, (sum, r) => sum + r.totalSeats);
    int bookedSeats = _mockRides.fold(
      0,
      (sum, r) => sum + (r.totalSeats - r.availableSeats),
    );
    double totalRevenue = _mockRides.fold(
      0.0,
      (sum, r) =>
          sum +
          r.bookings.fold(0.0, (bSum, b) => bSum + b.totalPrice),
    );

    return {
      'totalRides': totalRides,
      'activeRides': activeRides,
      'totalSeats': totalSeats,
      'bookedSeats': bookedSeats,
      'totalRevenue': totalRevenue,
      'occupancyRate': totalSeats > 0 ? (bookedSeats / totalSeats * 100).round() : 0,
    };
  }

  // Realistic BlaBlaCar Seed Data
  static List<CarpoolRideModel> _initMockRides() {
    final now = DateTime.now();
    return [
      CarpoolRideModel(
        id: 'ride-101',
        origin: 'Downtown Terminal',
        originAddress: '742 Evergreen St, Central Metro',
        destination: 'Grand Central Station',
        destinationAddress: '89 Lexington Ave, Midtown Hub',
        departureTime: DateTime(now.year, now.month, now.day, 8, 30),
        arrivalTime: DateTime(now.year, now.month, now.day, 10, 45),
        durationMinutes: 135,
        distanceKm: 160.0,
        pricePerSeat: 18.0,
        totalSeats: 3,
        availableSeats: 2,
        driver: const DriverProfileModel(
          id: 'drv-01',
          name: 'Sarah Jenkins',
          avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
          rating: 4.9,
          totalReviews: 87,
          isVerified: true,
          carModel: 'Tesla Model 3',
          carColor: 'Pearl White',
          plateNumber: 'EV-992-BL',
          phone: '+1 555-0143',
          bio: 'Passionate carpooler! I commute every weekday morning. Smooth and eco-friendly ride.',
        ),
        amenities: const RideAmenitiesModel(
          instantBooking: true,
          smokingAllowed: false,
          petsAllowed: false,
          maxTwoInBack: true,
          acEnabled: true,
          luggageSize: 'Medium',
        ),
        intermediateStops: const ['Valley View Interchange', 'Airport Toll Plaza'],
        status: 'ACTIVE',
        bookings: [
          PassengerBookingModel(
            id: 'bk-1',
            rideId: 'ride-101',
            passengerName: 'David Miller',
            passengerPhone: '+1 555-4921',
            seatsBooked: 1,
            totalPrice: 18.0,
            bookedAt: now.subtract(const Duration(hours: 3)),
            status: 'CONFIRMED',
          ),
        ],
      ),
      CarpoolRideModel(
        id: 'ride-102',
        origin: 'Westwood Boulevard',
        originAddress: '10900 Wilshire Blvd',
        destination: 'San Diego Harbor',
        destinationAddress: '1000 N Harbor Dr, Marina District',
        departureTime: DateTime(now.year, now.month, now.day, 11, 15),
        arrivalTime: DateTime(now.year, now.month, now.day, 13, 30),
        durationMinutes: 135,
        distanceKm: 195.0,
        pricePerSeat: 22.0,
        totalSeats: 4,
        availableSeats: 1,
        driver: const DriverProfileModel(
          id: 'drv-02',
          name: 'Marc Lefebvre',
          avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
          rating: 4.8,
          totalReviews: 124,
          isVerified: true,
          carModel: 'Audi A4 Avant',
          carColor: 'Mythos Black',
          plateNumber: 'CA-481-QK',
          phone: '+1 555-7832',
          bio: 'Frequent traveler. Good music, quiet and comfortable long distance trips.',
        ),
        amenities: const RideAmenitiesModel(
          instantBooking: true,
          smokingAllowed: false,
          petsAllowed: true,
          maxTwoInBack: true,
          acEnabled: true,
          luggageSize: 'Large',
        ),
        intermediateStops: const ['Irvine Spectrum Center', 'Oceanside Pier'],
        status: 'ACTIVE',
        bookings: [
          PassengerBookingModel(
            id: 'bk-2',
            rideId: 'ride-102',
            passengerName: 'Elena Rostova',
            passengerPhone: '+1 555-9012',
            seatsBooked: 2,
            totalPrice: 44.0,
            bookedAt: now.subtract(const Duration(hours: 8)),
            status: 'CONFIRMED',
          ),
          PassengerBookingModel(
            id: 'bk-3',
            rideId: 'ride-102',
            passengerName: 'Carlos Gomez',
            passengerPhone: '+1 555-3341',
            seatsBooked: 1,
            totalPrice: 22.0,
            bookedAt: now.subtract(const Duration(hours: 5)),
            status: 'CONFIRMED',
          ),
        ],
      ),
      CarpoolRideModel(
        id: 'ride-103',
        origin: 'North Point Mall',
        originAddress: '1000 North Point Circle, Alpharetta',
        destination: 'Downtown Financial Center',
        destinationAddress: '250 Peachtree St NW, Atlanta',
        departureTime: DateTime(now.year, now.month, now.day, 14, 00),
        arrivalTime: DateTime(now.year, now.month, now.day, 14, 45),
        durationMinutes: 45,
        distanceKm: 38.0,
        pricePerSeat: 7.0,
        totalSeats: 3,
        availableSeats: 3,
        driver: const DriverProfileModel(
          id: 'drv-03',
          name: 'Chloe Dupont',
          avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
          rating: 5.0,
          totalReviews: 42,
          isVerified: true,
          carModel: 'Hyundai Ioniq 5',
          carColor: 'Cyber Gray',
          plateNumber: 'GA-773-ZZ',
          phone: '+1 555-8821',
          bio: 'Engineer heading to tech campus daily. Super quiet and clean electric vehicle.',
        ),
        amenities: const RideAmenitiesModel(
          instantBooking: true,
          smokingAllowed: false,
          petsAllowed: false,
          maxTwoInBack: true,
          acEnabled: true,
          luggageSize: 'Small',
        ),
        intermediateStops: const ['Dunwoody Station'],
        status: 'ACTIVE',
        bookings: const [],
      ),
      CarpoolRideModel(
        id: 'ride-104',
        origin: 'Tech Hub Park',
        originAddress: '500 Innovation Way',
        destination: 'South Bay Marina',
        destinationAddress: '120 Ocean View Road',
        departureTime: DateTime(now.year, now.month, now.day, 17, 30),
        arrivalTime: DateTime(now.year, now.month, now.day, 18, 50),
        durationMinutes: 80,
        distanceKm: 85.0,
        pricePerSeat: 14.0,
        totalSeats: 4,
        availableSeats: 4,
        driver: const DriverProfileModel(
          id: 'drv-04',
          name: 'Robert Vance',
          avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
          rating: 4.7,
          totalReviews: 65,
          isVerified: true,
          carModel: 'Honda Civic Touring',
          carColor: 'Rallye Red',
          plateNumber: 'TX-529-LK',
          phone: '+1 555-6677',
          bio: 'Carpooling helps our environment and cuts traffic. Let us share the journey!',
        ),
        amenities: const RideAmenitiesModel(
          instantBooking: false,
          smokingAllowed: false,
          petsAllowed: true,
          maxTwoInBack: false,
          acEnabled: true,
          luggageSize: 'Medium',
        ),
        intermediateStops: const ['Highway 10 Exit 4'],
        status: 'ACTIVE',
        bookings: const [],
      ),
      CarpoolRideModel(
        id: 'ride-105',
        origin: 'University District',
        originAddress: 'Campus South Gate, College Ave',
        destination: 'Mountain Ridge Ski Resort',
        destinationAddress: '200 Alpine Valley Way',
        departureTime: DateTime(now.year, now.month, now.day, 6, 00),
        arrivalTime: DateTime(now.year, now.month, now.day, 8, 45),
        durationMinutes: 165,
        distanceKm: 210.0,
        pricePerSeat: 28.0,
        totalSeats: 3,
        availableSeats: 0,
        driver: const DriverProfileModel(
          id: 'drv-05',
          name: 'Lucas Morel',
          avatarUrl: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150',
          rating: 4.95,
          totalReviews: 156,
          isVerified: true,
          carModel: 'Subaru Outback AWD',
          carColor: 'Autumn Green',
          plateNumber: 'CO-910-MT',
          phone: '+1 555-9988',
          bio: 'Snow sports enthusiast with winter tires and ski racks. Always fully booked!',
        ),
        amenities: const RideAmenitiesModel(
          instantBooking: true,
          smokingAllowed: false,
          petsAllowed: false,
          maxTwoInBack: true,
          acEnabled: true,
          luggageSize: 'Large',
        ),
        intermediateStops: const ['Silverthorne Outlets'],
        status: 'FULL',
        bookings: [
          PassengerBookingModel(
            id: 'bk-5',
            rideId: 'ride-105',
            passengerName: 'Sophie Bennett',
            passengerPhone: '+1 555-1212',
            seatsBooked: 2,
            totalPrice: 56.0,
            bookedAt: now.subtract(const Duration(days: 1)),
            status: 'CONFIRMED',
          ),
          PassengerBookingModel(
            id: 'bk-6',
            rideId: 'ride-105',
            passengerName: 'Mark Chen',
            passengerPhone: '+1 555-3434',
            seatsBooked: 1,
            totalPrice: 28.0,
            bookedAt: now.subtract(const Duration(days: 1, hours: 2)),
            status: 'CONFIRMED',
          ),
        ],
      ),
    ];
  }
}
