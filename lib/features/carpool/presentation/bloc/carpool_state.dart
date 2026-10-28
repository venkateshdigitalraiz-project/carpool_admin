import 'package:equatable/equatable.dart';
import '../../domain/entities/carpool_ride.dart';
import '../../domain/entities/passenger_booking.dart';

enum CarpoolStatus { initial, loading, loaded, success, failure }

class CarpoolState extends Equatable {
  final CarpoolStatus status;
  final List<CarpoolRide> allRides;
  final List<CarpoolRide> filteredRides;
  final CarpoolRide? selectedRide;
  final PassengerBooking? latestBooking;
  final Map<String, dynamic> adminStats;
  final bool isAdminMode;
  final String? errorMessage;
  final String? successMessage;
  final String? searchOrigin;
  final String? searchDestination;
  final DateTime? searchDate;
  final int searchPassengers;
  final double? maxPriceFilter;
  final bool instantBookingFilter;
  final bool verifiedOnlyFilter;
  final String sortBy; // 'earliest', 'cheapest', 'shortest'

  const CarpoolState({
    this.status = CarpoolStatus.initial,
    this.allRides = const [],
    this.filteredRides = const [],
    this.selectedRide,
    this.latestBooking,
    this.adminStats = const {},
    this.isAdminMode = false,
    this.errorMessage,
    this.successMessage,
    this.searchOrigin,
    this.searchDestination,
    this.searchDate,
    this.searchPassengers = 1,
    this.maxPriceFilter,
    this.instantBookingFilter = false,
    this.verifiedOnlyFilter = false,
    this.sortBy = 'earliest',
  });

  CarpoolState copyWith({
    CarpoolStatus? status,
    List<CarpoolRide>? allRides,
    List<CarpoolRide>? filteredRides,
    CarpoolRide? selectedRide,
    PassengerBooking? latestBooking,
    Map<String, dynamic>? adminStats,
    bool? isAdminMode,
    String? errorMessage,
    String? successMessage,
    String? searchOrigin,
    String? searchDestination,
    DateTime? searchDate,
    int? searchPassengers,
    double? maxPriceFilter,
    bool? instantBookingFilter,
    bool? verifiedOnlyFilter,
    String? sortBy,
  }) {
    return CarpoolState(
      status: status ?? this.status,
      allRides: allRides ?? this.allRides,
      filteredRides: filteredRides ?? this.filteredRides,
      selectedRide: selectedRide ?? this.selectedRide,
      latestBooking: latestBooking ?? this.latestBooking,
      adminStats: adminStats ?? this.adminStats,
      isAdminMode: isAdminMode ?? this.isAdminMode,
      errorMessage: errorMessage,
      successMessage: successMessage,
      searchOrigin: searchOrigin ?? this.searchOrigin,
      searchDestination: searchDestination ?? this.searchDestination,
      searchDate: searchDate ?? this.searchDate,
      searchPassengers: searchPassengers ?? this.searchPassengers,
      maxPriceFilter: maxPriceFilter ?? this.maxPriceFilter,
      instantBookingFilter: instantBookingFilter ?? this.instantBookingFilter,
      verifiedOnlyFilter: verifiedOnlyFilter ?? this.verifiedOnlyFilter,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  @override
  List<Object?> get props => [
        status,
        allRides,
        filteredRides,
        selectedRide,
        latestBooking,
        adminStats,
        isAdminMode,
        errorMessage,
        successMessage,
        searchOrigin,
        searchDestination,
        searchDate,
        searchPassengers,
        maxPriceFilter,
        instantBookingFilter,
        verifiedOnlyFilter,
        sortBy,
      ];
}
