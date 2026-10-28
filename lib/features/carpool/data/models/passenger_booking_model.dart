import '../../domain/entities/passenger_booking.dart';

class PassengerBookingModel extends PassengerBooking {
  const PassengerBookingModel({
    required super.id,
    required super.rideId,
    required super.passengerName,
    required super.passengerPhone,
    required super.seatsBooked,
    required super.totalPrice,
    required super.bookedAt,
    super.status,
  });

  factory PassengerBookingModel.fromJson(Map<String, dynamic> json) {
    return PassengerBookingModel(
      id: json['id']?.toString() ?? '',
      rideId: json['ride_id']?.toString() ?? '',
      passengerName: json['passenger_name']?.toString() ?? 'Passenger',
      passengerPhone: json['passenger_phone']?.toString() ?? '',
      seatsBooked: (json['seats_booked'] as num?)?.toInt() ?? 1,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      bookedAt: json['booked_at'] != null
          ? DateTime.tryParse(json['booked_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      status: json['status']?.toString() ?? 'CONFIRMED',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ride_id': rideId,
      'passenger_name': passengerName,
      'passenger_phone': passengerPhone,
      'seats_booked': seatsBooked,
      'total_price': totalPrice,
      'booked_at': bookedAt.toIso8601String(),
      'status': status,
    };
  }

  factory PassengerBookingModel.fromEntity(PassengerBooking entity) {
    return PassengerBookingModel(
      id: entity.id,
      rideId: entity.rideId,
      passengerName: entity.passengerName,
      passengerPhone: entity.passengerPhone,
      seatsBooked: entity.seatsBooked,
      totalPrice: entity.totalPrice,
      bookedAt: entity.bookedAt,
      status: entity.status,
    );
  }
}
