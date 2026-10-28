import '../../domain/entities/carpool_ride.dart';
import 'passenger_booking_model.dart';

class DriverProfileModel extends DriverProfile {
  const DriverProfileModel({
    required super.id,
    required super.name,
    required super.avatarUrl,
    required super.rating,
    required super.totalReviews,
    required super.isVerified,
    required super.carModel,
    super.carColor,
    required super.plateNumber,
    required super.phone,
    super.bio,
  });

  factory DriverProfileModel.fromJson(Map<String, dynamic> json) {
    return DriverProfileModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Driver',
      avatarUrl: json['avatar_url']?.toString() ?? 'https://i.pravatar.cc/150?u=driver',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      totalReviews: (json['total_reviews'] as num?)?.toInt() ?? 12,
      isVerified: json['is_verified'] as bool? ?? true,
      carModel: json['car_model']?.toString() ?? 'Toyota Prius',
      carColor: json['car_color']?.toString() ?? 'Silver Metallic',
      plateNumber: json['plate_number']?.toString() ?? 'ABC 1234',
      phone: json['phone']?.toString() ?? '+1 555-0199',
      bio: json['bio']?.toString() ?? 'Daily commuter. Non-smoker and smooth driver.',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar_url': avatarUrl,
      'rating': rating,
      'total_reviews': totalReviews,
      'is_verified': isVerified,
      'car_model': carModel,
      'car_color': carColor,
      'plate_number': plateNumber,
      'phone': phone,
      'bio': bio,
    };
  }

  factory DriverProfileModel.fromEntity(DriverProfile entity) {
    return DriverProfileModel(
      id: entity.id,
      name: entity.name,
      avatarUrl: entity.avatarUrl,
      rating: entity.rating,
      totalReviews: entity.totalReviews,
      isVerified: entity.isVerified,
      carModel: entity.carModel,
      carColor: entity.carColor,
      plateNumber: entity.plateNumber,
      phone: entity.phone,
      bio: entity.bio,
    );
  }
}

class RideAmenitiesModel extends RideAmenities {
  const RideAmenitiesModel({
    super.instantBooking,
    super.smokingAllowed,
    super.petsAllowed,
    super.maxTwoInBack,
    super.acEnabled,
    super.luggageSize,
  });

  factory RideAmenitiesModel.fromJson(Map<String, dynamic> json) {
    return RideAmenitiesModel(
      instantBooking: json['instant_booking'] as bool? ?? true,
      smokingAllowed: json['smoking_allowed'] as bool? ?? false,
      petsAllowed: json['pets_allowed'] as bool? ?? false,
      maxTwoInBack: json['max_two_in_back'] as bool? ?? true,
      acEnabled: json['ac_enabled'] as bool? ?? true,
      luggageSize: json['luggage_size']?.toString() ?? 'Medium',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'instant_booking': instantBooking,
      'smoking_allowed': smokingAllowed,
      'pets_allowed': petsAllowed,
      'max_two_in_back': maxTwoInBack,
      'ac_enabled': acEnabled,
      'luggage_size': luggageSize,
    };
  }

  factory RideAmenitiesModel.fromEntity(RideAmenities entity) {
    return RideAmenitiesModel(
      instantBooking: entity.instantBooking,
      smokingAllowed: entity.smokingAllowed,
      petsAllowed: entity.petsAllowed,
      maxTwoInBack: entity.maxTwoInBack,
      acEnabled: entity.acEnabled,
      luggageSize: entity.luggageSize,
    );
  }
}

class CarpoolRideModel extends CarpoolRide {
  const CarpoolRideModel({
    required super.id,
    required super.origin,
    required super.originAddress,
    required super.destination,
    required super.destinationAddress,
    required super.departureTime,
    required super.arrivalTime,
    required super.durationMinutes,
    required super.distanceKm,
    required super.pricePerSeat,
    required super.totalSeats,
    required super.availableSeats,
    required super.driver,
    super.amenities,
    super.intermediateStops,
    super.status,
    super.bookings,
  });

  factory CarpoolRideModel.fromJson(Map<String, dynamic> json) {
    return CarpoolRideModel(
      id: json['id']?.toString() ?? '',
      origin: json['origin']?.toString() ?? '',
      originAddress: json['origin_address']?.toString() ?? '',
      destination: json['destination']?.toString() ?? '',
      destinationAddress: json['destination_address']?.toString() ?? '',
      departureTime: json['departure_time'] != null
          ? DateTime.tryParse(json['departure_time'].toString()) ?? DateTime.now()
          : DateTime.now(),
      arrivalTime: json['arrival_time'] != null
          ? DateTime.tryParse(json['arrival_time'].toString()) ?? DateTime.now().add(const Duration(hours: 2))
          : DateTime.now().add(const Duration(hours: 2)),
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 120,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 150.0,
      pricePerSeat: (json['price_per_seat'] as num?)?.toDouble() ?? 15.0,
      totalSeats: (json['total_seats'] as num?)?.toInt() ?? 4,
      availableSeats: (json['available_seats'] as num?)?.toInt() ?? 3,
      driver: json['driver'] != null
          ? DriverProfileModel.fromJson(json['driver'] as Map<String, dynamic>)
          : const DriverProfile(
              id: 'd1',
              name: 'Alex Martin',
              avatarUrl: 'https://i.pravatar.cc/150?u=alex',
              rating: 4.9,
              totalReviews: 34,
              isVerified: true,
              carModel: 'Volkswagen Golf',
              plateNumber: 'XY-829-AB',
              phone: '+1 555-1234',
            ),
      amenities: json['amenities'] != null
          ? RideAmenitiesModel.fromJson(json['amenities'] as Map<String, dynamic>)
          : const RideAmenities(),
      intermediateStops: (json['intermediate_stops'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      status: json['status']?.toString() ?? 'ACTIVE',
      bookings: (json['bookings'] as List<dynamic>?)
              ?.map((e) => PassengerBookingModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'origin': origin,
      'origin_address': originAddress,
      'destination': destination,
      'destination_address': destinationAddress,
      'departure_time': departureTime.toIso8601String(),
      'arrival_time': arrivalTime.toIso8601String(),
      'duration_minutes': durationMinutes,
      'distance_km': distanceKm,
      'price_per_seat': pricePerSeat,
      'total_seats': totalSeats,
      'available_seats': availableSeats,
      'driver': DriverProfileModel.fromEntity(driver).toJson(),
      'amenities': RideAmenitiesModel.fromEntity(amenities).toJson(),
      'intermediate_stops': intermediateStops,
      'status': status,
      'bookings': bookings.map((b) => PassengerBookingModel.fromEntity(b).toJson()).toList(),
    };
  }

  factory CarpoolRideModel.fromEntity(CarpoolRide entity) {
    return CarpoolRideModel(
      id: entity.id,
      origin: entity.origin,
      originAddress: entity.originAddress,
      destination: entity.destination,
      destinationAddress: entity.destinationAddress,
      departureTime: entity.departureTime,
      arrivalTime: entity.arrivalTime,
      durationMinutes: entity.durationMinutes,
      distanceKm: entity.distanceKm,
      pricePerSeat: entity.pricePerSeat,
      totalSeats: entity.totalSeats,
      availableSeats: entity.availableSeats,
      driver: entity.driver,
      amenities: entity.amenities,
      intermediateStops: entity.intermediateStops,
      status: entity.status,
      bookings: entity.bookings,
    );
  }
}
