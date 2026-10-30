import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/utils/distance_calculator.dart';
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
      final response = await client.get(uri).timeout(const Duration(milliseconds: 500));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List list = decoded is List ? decoded : (decoded['data'] ?? []);
        if (list.isNotEmpty) {
          return list.map((e) => CarpoolRideModel.fromJson(e)).toList();
        }
      }
    } catch (_) {
      // Fallback search algorithm with local persistent store
    }

    final queryOrigin = origin.trim().toLowerCase();
    final queryDest = destination.trim().toLowerCase();

    bool matchLocation(String query, String city, String address, List<String> stops) {
      if (query.isEmpty) return true;
      final q = query.toLowerCase().trim();
      final c = city.toLowerCase().trim();
      final a = address.toLowerCase().trim();

      // Direct or substring match in either direction
      if (c.isNotEmpty && (c.contains(q) || q.contains(c))) return true;
      if (a.isNotEmpty && (a.contains(q) || q.contains(a))) return true;

      // Token match (e.g., "Vijayawada" from "Vijayawada, Krishna, Andhra Pradesh")
      final tokens = q.split(RegExp(r'[, -]+')).map((t) => t.trim()).where((t) => t.length >= 3);
      for (final t in tokens) {
        if (c.contains(t) || t.contains(c)) return true;
        if (a.contains(t) || t.contains(a)) return true;
      }

      // Check stopovers / intermediate stops
      for (final stop in stops) {
        final s = stop.toLowerCase().trim();
        if (s.isNotEmpty) {
          if (s.contains(q) || q.contains(s)) return true;
          for (final t in tokens) {
            if (s.contains(t) || t.contains(s)) return true;
          }
        }
      }

      return false;
    }

    // Filter rides matching route, seat capacity, and active status
    final routeMatches = _mockRides.where((ride) {
      final matchOrigin = matchLocation(queryOrigin, ride.origin, ride.originAddress, ride.intermediateStops);
      final matchDest = matchLocation(queryDest, ride.destination, ride.destinationAddress, ride.intermediateStops);
      final hasEnoughSeats = ride.availableSeats >= passengers;
      final isActive = ride.status == 'ACTIVE';

      return matchOrigin && matchDest && hasEnoughSeats && isActive;
    }).toList();

    // Check if any matching rides depart on the requested calendar date
    final exactDateMatches = routeMatches.where((ride) {
      return ride.departureTime.year == date.year &&
          ride.departureTime.month == date.month &&
          ride.departureTime.day == date.day;
    }).toList();

    // If both origin and destination are specified by the user, dynamically generate
    // the current booking ride so it is added to available rides and ALWAYS displayed on top!
    if (origin.trim().isNotEmpty && destination.trim().isNotEmpty) {
      final rawOrigin = origin.trim();
      final rawDest = destination.trim();
      final originMain =
          rawOrigin.contains(',') ? rawOrigin.split(',').first.trim() : rawOrigin;
      final destMain =
          rawDest.contains(',') ? rawDest.split(',').first.trim() : rawDest;

      double distanceKm = 275.0;
      double pricePerSeat = 550.0;
      try {
        final estimate = await DistanceCalculator.calculateRouteEstimate(
          originText: originMain,
          destinationText: destMain,
          ratePerKm: 2.2,
        );
        distanceKm = estimate.distanceKm;
        final calculated =
            (estimate.estimatedPrice / 4.0).clamp(250.0, 1600.0).roundToDouble();
        pricePerSeat = calculated > 0 ? calculated : 550.0;
      } catch (_) {}

      var departureTime = DateTime(
        date.year,
        date.month,
        date.day,
        date.year == DateTime.now().year &&
                date.month == DateTime.now().month &&
                date.day == DateTime.now().day
            ? math.min(21, math.max(DateTime.now().hour + 2, 8))
            : 9,
        0,
      );
      if (departureTime.isBefore(DateTime.now())) {
        departureTime = DateTime.now().add(const Duration(hours: 3));
      }
      final durationMinutes = ((distanceKm / 65.0) * 60).round();
      final arrivalTime = departureTime.add(Duration(minutes: durationMinutes));

      final currentBookingRide = CarpoolRideModel(
        id: 'ride-current-booking-${DateTime.now().millisecondsSinceEpoch}',
        origin: originMain,
        originAddress: rawOrigin,
        destination: destMain,
        destinationAddress: rawDest,
        departureTime: departureTime,
        arrivalTime: arrivalTime,
        durationMinutes: durationMinutes,
        distanceKm: distanceKm,
        pricePerSeat: pricePerSeat,
        totalSeats: math.max(passengers + 3, 4),
        availableSeats: math.max(passengers + 2, 3),
        driver: const DriverProfileModel(
          id: 'drv-current-booking',
          name: 'Rajesh Kumar',
          avatarUrl:
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
          rating: 4.9,
          totalReviews: 38,
          isVerified: true,
          carModel: 'Hyundai Creta (AC)',
          plateNumber: 'AP-16-CD-9988',
          phone: '+91 98765 43210',
          bio: 'Careful highway driver with verified ID and top passenger reviews.',
        ),
        amenities: const RideAmenitiesModel(
          instantBooking: true,
          smokingAllowed: false,
          petsAllowed: false,
          maxTwoInBack: true,
          acEnabled: true,
          luggageSize: 'Medium',
        ),
        intermediateStops: const [],
        status: 'ACTIVE',
        bookings: const [],
      );

      _mockRides.insert(0, currentBookingRide);

      final otherMatches = (exactDateMatches.isNotEmpty ? exactDateMatches : routeMatches)
          .where((r) => r.id != currentBookingRide.id)
          .toList();

      return [currentBookingRide, ...otherMatches];
    }

    if (exactDateMatches.isNotEmpty) {
      return exactDateMatches;
    }

    // If no exact day matches, return all available route rides
    return routeMatches;
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
      // --- Real Indian Regional Carpool Seed Routes ---
      // Route 1: Vijayawada -> Hyderabad (Today Afternoon)
      CarpoolRideModel(
        id: 'ride-vja-hyd-today',
        origin: 'Vijayawada',
        originAddress: 'Benz Circle, Vijayawada, Andhra Pradesh',
        destination: 'Hyderabad',
        destinationAddress: 'Hitech City, Hyderabad, Telangana',
        departureTime: now.add(const Duration(hours: 4)),
        arrivalTime: now.add(const Duration(hours: 8, minutes: 30)),
        durationMinutes: 270,
        distanceKm: 275.0,
        pricePerSeat: 450.0,
        totalSeats: 4,
        availableSeats: 3,
        driver: const DriverProfileModel(
          id: 'drv-current-user',
          name: 'Venkatesh Rao',
          avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
          rating: 4.95,
          totalReviews: 86,
          isVerified: true,
          carModel: 'Toyota Camry Hybrid',
          carColor: 'Silver Metallic',
          plateNumber: 'AP 16 AB 1234',
          phone: '+91 9876543210',
          bio: 'Frequent traveler between Vijayawada and Hyderabad. Calm driving and smooth music.',
        ),
        amenities: const RideAmenitiesModel(
          instantBooking: true,
          smokingAllowed: false,
          petsAllowed: false,
          maxTwoInBack: true,
          acEnabled: true,
          luggageSize: 'Medium',
        ),
        intermediateStops: const ['Suryapet', 'Kodad', 'Choutuppal', 'LB Nagar'],
        status: 'ACTIVE',
        bookings: const [],
      ),
      // Route 2: Vijayawada -> Hyderabad (Tomorrow Morning)
      CarpoolRideModel(
        id: 'ride-vja-hyd-tmrw',
        origin: 'Vijayawada',
        originAddress: 'PNBS Bus Station, Vijayawada, Andhra Pradesh',
        destination: 'Hyderabad',
        destinationAddress: 'Gachibowli, Hyderabad, Telangana',
        departureTime: DateTime(now.year, now.month, now.day + 1, 7, 30),
        arrivalTime: DateTime(now.year, now.month, now.day + 1, 12, 15),
        durationMinutes: 285,
        distanceKm: 280.0,
        pricePerSeat: 480.0,
        totalSeats: 4,
        availableSeats: 4,
        driver: const DriverProfileModel(
          id: 'drv-in-02',
          name: 'Ramesh Kumar',
          avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
          rating: 4.85,
          totalReviews: 54,
          isVerified: true,
          carModel: 'Maruti Suzuki Ertiga',
          carColor: 'Magma Grey',
          plateNumber: 'AP 16 ER 5678',
          phone: '+91 9848012345',
          bio: 'Morning traveler. Punctual, safe, and spacious 7-seater car with AC.',
        ),
        amenities: const RideAmenitiesModel(
          instantBooking: true,
          smokingAllowed: false,
          petsAllowed: false,
          maxTwoInBack: true,
          acEnabled: true,
          luggageSize: 'Large',
        ),
        intermediateStops: const ['Nandigama', 'Suryapet', 'Ramoji Film City'],
        status: 'ACTIVE',
        bookings: const [],
      ),
      // Route 3: Vijayawada -> Hyderabad (Day After Tomorrow)
      CarpoolRideModel(
        id: 'ride-vja-hyd-day2',
        origin: 'Vijayawada',
        originAddress: 'MG Road, Vijayawada, Andhra Pradesh',
        destination: 'Hyderabad',
        destinationAddress: 'Secunderabad Railway Station, Hyderabad, Telangana',
        departureTime: DateTime(now.year, now.month, now.day + 2, 15, 0),
        arrivalTime: DateTime(now.year, now.month, now.day + 2, 19, 45),
        durationMinutes: 285,
        distanceKm: 275.0,
        pricePerSeat: 420.0,
        totalSeats: 3,
        availableSeats: 2,
        driver: const DriverProfileModel(
          id: 'drv-in-03',
          name: 'Priya Sharma',
          avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
          rating: 4.9,
          totalReviews: 38,
          isVerified: true,
          carModel: 'Hyundai Verna',
          carColor: 'Polar White',
          plateNumber: 'TS 09 EQ 4321',
          phone: '+91 9700112233',
          bio: 'Weekend commute. Quiet, clean car, professional IT engineer.',
        ),
        amenities: const RideAmenitiesModel(
          instantBooking: true,
          smokingAllowed: false,
          petsAllowed: false,
          maxTwoInBack: true,
          acEnabled: true,
          luggageSize: 'Medium',
        ),
        intermediateStops: const ['Suryapet', 'Choutuppal', 'Dilsukhnagar'],
        status: 'ACTIVE',
        bookings: const [],
      ),
      // Route 4: Hyderabad -> Vijayawada (Tomorrow Morning)
      CarpoolRideModel(
        id: 'ride-hyd-vja-tmrw',
        origin: 'Hyderabad',
        originAddress: 'Miyapur Metro Station, Hyderabad, Telangana',
        destination: 'Vijayawada',
        destinationAddress: 'Benz Circle, Vijayawada, Andhra Pradesh',
        departureTime: DateTime(now.year, now.month, now.day + 1, 8, 0),
        arrivalTime: DateTime(now.year, now.month, now.day + 1, 12, 45),
        durationMinutes: 285,
        distanceKm: 275.0,
        pricePerSeat: 450.0,
        totalSeats: 4,
        availableSeats: 3,
        driver: const DriverProfileModel(
          id: 'drv-in-04',
          name: 'Anil Chowdary',
          avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
          rating: 4.88,
          totalReviews: 73,
          isVerified: true,
          carModel: 'Kia Seltos',
          carColor: 'Gravity Grey',
          plateNumber: 'TS 08 AB 9988',
          phone: '+91 9988776655',
          bio: 'Daily carpooler. Comfortable seats, sanitized car, verified driver.',
        ),
        amenities: const RideAmenitiesModel(
          instantBooking: true,
          smokingAllowed: false,
          petsAllowed: false,
          maxTwoInBack: true,
          acEnabled: true,
          luggageSize: 'Medium',
        ),
        intermediateStops: const ['LB Nagar', 'Choutuppal', 'Suryapet', 'Kodad'],
        status: 'ACTIVE',
        bookings: const [],
      ),
      // Route 5: Kaikaluru -> Vijayawada (Tomorrow Morning)
      CarpoolRideModel(
        id: 'ride-kai-vja-tmrw',
        origin: 'Kaikaluru',
        originAddress: 'Main Road, Kaikaluru, Andhra Pradesh',
        destination: 'Vijayawada',
        destinationAddress: 'Railway Station, Vijayawada, Andhra Pradesh',
        departureTime: DateTime(now.year, now.month, now.day + 1, 8, 30),
        arrivalTime: DateTime(now.year, now.month, now.day + 1, 10, 45),
        durationMinutes: 135,
        distanceKm: 85.0,
        pricePerSeat: 180.0,
        totalSeats: 3,
        availableSeats: 3,
        driver: const DriverProfileModel(
          id: 'drv-in-05',
          name: 'Sumanth Krishna',
          avatarUrl: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150',
          rating: 5.0,
          totalReviews: 24,
          isVerified: true,
          carModel: 'Maruti Suzuki Dzire',
          carColor: 'Pearl Arctic White',
          plateNumber: 'AP 16 DZ 3456',
          phone: '+91 9440123456',
          bio: 'Local daily commute from Kaikaluru to Vijayawada via Gudivada.',
        ),
        amenities: const RideAmenitiesModel(
          instantBooking: true,
          smokingAllowed: false,
          petsAllowed: false,
          maxTwoInBack: true,
          acEnabled: true,
          luggageSize: 'Medium',
        ),
        intermediateStops: const ['Gudivada', 'Pamarru', 'Kankipadu'],
        status: 'ACTIVE',
        bookings: const [],
      ),
      // Route 6: Vijayawada -> Kaikaluru (Tomorrow Evening)
      CarpoolRideModel(
        id: 'ride-vja-kai-tmrw',
        origin: 'Vijayawada',
        originAddress: 'Bus Station, Vijayawada, Andhra Pradesh',
        destination: 'Kaikaluru',
        destinationAddress: 'RTC Bus Stand, Kaikaluru, Andhra Pradesh',
        departureTime: DateTime(now.year, now.month, now.day + 1, 17, 30),
        arrivalTime: DateTime(now.year, now.month, now.day + 1, 19, 45),
        durationMinutes: 135,
        distanceKm: 85.0,
        pricePerSeat: 180.0,
        totalSeats: 3,
        availableSeats: 3,
        driver: const DriverProfileModel(
          id: 'drv-in-05',
          name: 'Sumanth Krishna',
          avatarUrl: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150',
          rating: 5.0,
          totalReviews: 24,
          isVerified: true,
          carModel: 'Maruti Suzuki Dzire',
          carColor: 'Pearl Arctic White',
          plateNumber: 'AP 16 DZ 3456',
          phone: '+91 9440123456',
          bio: 'Return commute from Vijayawada back to Kaikaluru.',
        ),
        amenities: const RideAmenitiesModel(
          instantBooking: true,
          smokingAllowed: false,
          petsAllowed: false,
          maxTwoInBack: true,
          acEnabled: true,
          luggageSize: 'Medium',
        ),
        intermediateStops: const ['Kankipadu', 'Pamarru', 'Gudivada'],
        status: 'ACTIVE',
        bookings: const [],
      ),
      // Route 7: Guntur -> Hyderabad (Tomorrow Morning)
      CarpoolRideModel(
        id: 'ride-gun-hyd-tmrw',
        origin: 'Guntur',
        originAddress: 'Lodge Center, Guntur, Andhra Pradesh',
        destination: 'Hyderabad',
        destinationAddress: 'Ameerpet, Hyderabad, Telangana',
        departureTime: DateTime(now.year, now.month, now.day + 1, 6, 0),
        arrivalTime: DateTime(now.year, now.month, now.day + 1, 11, 0),
        durationMinutes: 300,
        distanceKm: 290.0,
        pricePerSeat: 420.0,
        totalSeats: 3,
        availableSeats: 3,
        driver: const DriverProfileModel(
          id: 'drv-in-06',
          name: 'Rajesh Varma',
          avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
          rating: 4.8,
          totalReviews: 45,
          isVerified: true,
          carModel: 'Honda City',
          carColor: 'Golden Brown',
          plateNumber: 'AP 07 HC 7788',
          phone: '+91 9393012345',
          bio: 'Direct trip from Guntur to Hyderabad. Fast tags, AC, relaxing travel.',
        ),
        amenities: const RideAmenitiesModel(
          instantBooking: true,
          smokingAllowed: false,
          petsAllowed: false,
          maxTwoInBack: true,
          acEnabled: true,
          luggageSize: 'Medium',
        ),
        intermediateStops: const ['Piduguralla', 'Miryalaguda', 'Nalgonda'],
        status: 'ACTIVE',
        bookings: const [],
      ),
      // Route 8: Vijayawada -> Visakhapatnam (Tomorrow Morning)
      CarpoolRideModel(
        id: 'ride-vja-viz-tmrw',
        origin: 'Vijayawada',
        originAddress: 'Benz Circle, Vijayawada, Andhra Pradesh',
        destination: 'Visakhapatnam',
        destinationAddress: 'RK Beach, Visakhapatnam, Andhra Pradesh',
        departureTime: DateTime(now.year, now.month, now.day + 1, 6, 30),
        arrivalTime: DateTime(now.year, now.month, now.day + 1, 13, 0),
        durationMinutes: 390,
        distanceKm: 350.0,
        pricePerSeat: 650.0,
        totalSeats: 4,
        availableSeats: 4,
        driver: const DriverProfileModel(
          id: 'drv-in-07',
          name: 'Ravi Teja',
          avatarUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150',
          rating: 4.95,
          totalReviews: 92,
          isVerified: true,
          carModel: 'Mahindra XUV700',
          carColor: 'Midnight Black',
          plateNumber: 'AP 16 XT 9001',
          phone: '+91 9123456789',
          bio: 'Long distance scenic drive along NH16 from Vijayawada to Vizag.',
        ),
        amenities: const RideAmenitiesModel(
          instantBooking: true,
          smokingAllowed: false,
          petsAllowed: false,
          maxTwoInBack: true,
          acEnabled: true,
          luggageSize: 'Large',
        ),
        intermediateStops: const ['Eluru', 'Tadepalligudem', 'Rajahmundry', 'Anakapalle'],
        status: 'ACTIVE',
        bookings: const [],
      ),
      // Route 9: Hyderabad -> Bengaluru (Tomorrow Night)
      CarpoolRideModel(
        id: 'ride-hyd-blr-tmrw',
        origin: 'Hyderabad',
        originAddress: 'ORR Gachibowli, Hyderabad, Telangana',
        destination: 'Bengaluru',
        destinationAddress: 'Hebbal, Bengaluru, Karnataka',
        departureTime: DateTime(now.year, now.month, now.day + 1, 21, 0),
        arrivalTime: DateTime(now.year, now.month, now.day + 2, 6, 0),
        durationMinutes: 540,
        distanceKm: 570.0,
        pricePerSeat: 950.0,
        totalSeats: 3,
        availableSeats: 3,
        driver: const DriverProfileModel(
          id: 'drv-in-08',
          name: 'Karthik Rao',
          avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150',
          rating: 4.9,
          totalReviews: 110,
          isVerified: true,
          carModel: 'Skoda Slavia',
          carColor: 'Crystal Blue',
          plateNumber: 'TS 09 SK 4567',
          phone: '+91 9888123456',
          bio: 'Night drive on NH44 expressway. Cruise control, peaceful ride.',
        ),
        amenities: const RideAmenitiesModel(
          instantBooking: true,
          smokingAllowed: false,
          petsAllowed: false,
          maxTwoInBack: true,
          acEnabled: true,
          luggageSize: 'Large',
        ),
        intermediateStops: const ['Mahabubnagar', 'Kurnool', 'Anantapur'],
        status: 'ACTIVE',
        bookings: const [],
      ),
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
