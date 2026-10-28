import 'package:equatable/equatable.dart';

class PassengerBooking extends Equatable {
  final String id;
  final String rideId;
  final String passengerName;
  final String passengerPhone;
  final int seatsBooked;
  final double totalPrice;
  final DateTime bookedAt;
  final String status; // 'CONFIRMED', 'PENDING', 'CANCELLED'

  const PassengerBooking({
    required this.id,
    required this.rideId,
    required this.passengerName,
    required this.passengerPhone,
    required this.seatsBooked,
    required this.totalPrice,
    required this.bookedAt,
    this.status = 'CONFIRMED',
  });

  PassengerBooking copyWith({
    String? id,
    String? rideId,
    String? passengerName,
    String? passengerPhone,
    int? seatsBooked,
    double? totalPrice,
    DateTime? bookedAt,
    String? status,
  }) {
    return PassengerBooking(
      id: id ?? this.id,
      rideId: rideId ?? this.rideId,
      passengerName: passengerName ?? this.passengerName,
      passengerPhone: passengerPhone ?? this.passengerPhone,
      seatsBooked: seatsBooked ?? this.seatsBooked,
      totalPrice: totalPrice ?? this.totalPrice,
      bookedAt: bookedAt ?? this.bookedAt,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        id,
        rideId,
        passengerName,
        passengerPhone,
        seatsBooked,
        totalPrice,
        bookedAt,
        status,
      ];
}
