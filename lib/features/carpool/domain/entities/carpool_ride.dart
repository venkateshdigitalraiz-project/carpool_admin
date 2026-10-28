import 'package:equatable/equatable.dart';
import 'passenger_booking.dart';

class DriverProfile extends Equatable {
  final String id;
  final String name;
  final String avatarUrl;
  final double rating;
  final int totalReviews;
  final bool isVerified;
  final String carModel;
  final String carColor;
  final String plateNumber;
  final String phone;
  final String bio;

  const DriverProfile({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.rating,
    required this.totalReviews,
    required this.isVerified,
    required this.carModel,
    this.carColor = 'Silver',
    required this.plateNumber,
    required this.phone,
    this.bio = 'Friendly and careful driver. Regular commuter.',
  });

  @override
  List<Object?> get props => [
        id,
        name,
        avatarUrl,
        rating,
        totalReviews,
        isVerified,
        carModel,
        carColor,
        plateNumber,
        phone,
        bio,
      ];
}

class RideAmenities extends Equatable {
  final bool instantBooking;
  final bool smokingAllowed;
  final bool petsAllowed;
  final bool maxTwoInBack;
  final bool acEnabled;
  final String luggageSize; // 'Small', 'Medium', 'Large'

  const RideAmenities({
    this.instantBooking = true,
    this.smokingAllowed = false,
    this.petsAllowed = false,
    this.maxTwoInBack = true,
    this.acEnabled = true,
    this.luggageSize = 'Medium',
  });

  @override
  List<Object?> get props => [
        instantBooking,
        smokingAllowed,
        petsAllowed,
        maxTwoInBack,
        acEnabled,
        luggageSize,
      ];
}

class CarpoolRide extends Equatable {
  final String id;
  final String origin;
  final String originAddress;
  final String destination;
  final String destinationAddress;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final int durationMinutes;
  final double distanceKm;
  final double pricePerSeat;
  final int totalSeats;
  final int availableSeats;
  final DriverProfile driver;
  final RideAmenities amenities;
  final List<String> intermediateStops;
  final String status; // 'ACTIVE', 'FULL', 'COMPLETED', 'CANCELLED'
  final List<PassengerBooking> bookings;

  const CarpoolRide({
    required this.id,
    required this.origin,
    required this.originAddress,
    required this.destination,
    required this.destinationAddress,
    required this.departureTime,
    required this.arrivalTime,
    required this.durationMinutes,
    required this.distanceKm,
    required this.pricePerSeat,
    required this.totalSeats,
    required this.availableSeats,
    required this.driver,
    this.amenities = const RideAmenities(),
    this.intermediateStops = const [],
    this.status = 'ACTIVE',
    this.bookings = const [],
  });

  CarpoolRide copyWith({
    String? id,
    String? origin,
    String? originAddress,
    String? destination,
    String? destinationAddress,
    DateTime? departureTime,
    DateTime? arrivalTime,
    int? durationMinutes,
    double? distanceKm,
    double? pricePerSeat,
    int? totalSeats,
    int? availableSeats,
    DriverProfile? driver,
    RideAmenities? amenities,
    List<String>? intermediateStops,
    String? status,
    List<PassengerBooking>? bookings,
  }) {
    return CarpoolRide(
      id: id ?? this.id,
      origin: origin ?? this.origin,
      originAddress: originAddress ?? this.originAddress,
      destination: destination ?? this.destination,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      distanceKm: distanceKm ?? this.distanceKm,
      pricePerSeat: pricePerSeat ?? this.pricePerSeat,
      totalSeats: totalSeats ?? this.totalSeats,
      availableSeats: availableSeats ?? this.availableSeats,
      driver: driver ?? this.driver,
      amenities: amenities ?? this.amenities,
      intermediateStops: intermediateStops ?? this.intermediateStops,
      status: status ?? this.status,
      bookings: bookings ?? this.bookings,
    );
  }

  @override
  List<Object?> get props => [
        id,
        origin,
        originAddress,
        destination,
        destinationAddress,
        departureTime,
        arrivalTime,
        durationMinutes,
        distanceKm,
        pricePerSeat,
        totalSeats,
        availableSeats,
        driver,
        amenities,
        intermediateStops,
        status,
        bookings,
      ];
}
