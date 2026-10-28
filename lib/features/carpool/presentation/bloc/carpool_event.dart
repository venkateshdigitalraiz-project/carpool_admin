import 'package:equatable/equatable.dart';
import '../../domain/entities/carpool_ride.dart';

abstract class CarpoolEvent extends Equatable {
  const CarpoolEvent();

  @override
  List<Object?> get props => [];
}

class LoadCarpoolRidesEvent extends CarpoolEvent {
  final bool refresh;
  const LoadCarpoolRidesEvent({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}

class SearchRidesEvent extends CarpoolEvent {
  final String origin;
  final String destination;
  final DateTime date;
  final int passengers;
  final DateTime? returnDate;

  const SearchRidesEvent({
    required this.origin,
    required this.destination,
    required this.date,
    this.passengers = 1,
    this.returnDate,
  });

  @override
  List<Object?> get props => [origin, destination, date, passengers, returnDate];
}

class ClearSearchEvent extends CarpoolEvent {}

class SelectRideEvent extends CarpoolEvent {
  final CarpoolRide ride;
  const SelectRideEvent(this.ride);

  @override
  List<Object?> get props => [ride];
}

class PublishRideEvent extends CarpoolEvent {
  final CarpoolRide ride;
  const PublishRideEvent(this.ride);

  @override
  List<Object?> get props => [ride];
}

class BookSeatEvent extends CarpoolEvent {
  final String rideId;
  final String passengerName;
  final String passengerPhone;
  final int seatsCount;

  const BookSeatEvent({
    required this.rideId,
    required this.passengerName,
    required this.passengerPhone,
    required this.seatsCount,
  });

  @override
  List<Object?> get props => [rideId, passengerName, passengerPhone, seatsCount];
}

class CancelBookingEvent extends CarpoolEvent {
  final String bookingId;
  const CancelBookingEvent(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}

class UpdateRideStatusEvent extends CarpoolEvent {
  final String rideId;
  final String status;
  const UpdateRideStatusEvent({required this.rideId, required this.status});

  @override
  List<Object?> get props => [rideId, status];
}

class ToggleAdminModeEvent extends CarpoolEvent {
  final bool isAdmin;
  const ToggleAdminModeEvent(this.isAdmin);

  @override
  List<Object?> get props => [isAdmin];
}

class FilterRidesEvent extends CarpoolEvent {
  final double? maxPrice;
  final bool? instantBookingOnly;
  final bool? verifiedOnly;
  final String? sortBy; // 'earliest', 'cheapest', 'shortest'

  const FilterRidesEvent({
    this.maxPrice,
    this.instantBookingOnly,
    this.verifiedOnly,
    this.sortBy,
  });

  @override
  List<Object?> get props => [maxPrice, instantBookingOnly, verifiedOnly, sortBy];
}
