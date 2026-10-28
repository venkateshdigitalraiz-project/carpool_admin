import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/carpool_ride.dart';
import '../../domain/usecases/book_ride_usecase.dart';
import '../../domain/usecases/cancel_booking_usecase.dart';
import '../../domain/usecases/get_carpool_rides_usecase.dart';
import '../../domain/usecases/publish_ride_usecase.dart';
import '../../domain/usecases/search_rides_usecase.dart';
import '../../domain/usecases/update_ride_status_usecase.dart';
import '../../domain/repositories/carpool_repository.dart';
import 'carpool_event.dart';
import 'carpool_state.dart';

class CarpoolBloc extends Bloc<CarpoolEvent, CarpoolState> {
  final GetCarpoolRidesUseCase getCarpoolRidesUseCase;
  final SearchRidesUseCase searchRidesUseCase;
  final PublishRideUseCase publishRideUseCase;
  final BookRideUseCase bookRideUseCase;
  final CancelBookingUseCase cancelBookingUseCase;
  final UpdateRideStatusUseCase updateRideStatusUseCase;
  final CarpoolRepository repository;

  CarpoolBloc({
    required this.getCarpoolRidesUseCase,
    required this.searchRidesUseCase,
    required this.publishRideUseCase,
    required this.bookRideUseCase,
    required this.cancelBookingUseCase,
    required this.updateRideStatusUseCase,
    required this.repository,
  }) : super(const CarpoolState()) {
    on<LoadCarpoolRidesEvent>(_onLoadCarpoolRides);
    on<SearchRidesEvent>(_onSearchRides);
    on<ClearSearchEvent>(_onClearSearch);
    on<SelectRideEvent>(_onSelectRide);
    on<PublishRideEvent>(_onPublishRide);
    on<BookSeatEvent>(_onBookSeat);
    on<CancelBookingEvent>(_onCancelBooking);
    on<UpdateRideStatusEvent>(_onUpdateRideStatus);
    on<ToggleAdminModeEvent>(_onToggleAdminMode);
    on<FilterRidesEvent>(_onFilterRides);
  }

  Future<void> _onLoadCarpoolRides(
    LoadCarpoolRidesEvent event,
    Emitter<CarpoolState> emit,
  ) async {
    emit(state.copyWith(status: CarpoolStatus.loading));
    try {
      final rides = await getCarpoolRidesUseCase();
      final stats = await repository.getAdminStats();
      final filtered = _applyFilters(
        rides: rides,
        maxPrice: state.maxPriceFilter,
        instantOnly: state.instantBookingFilter,
        verifiedOnly: state.verifiedOnlyFilter,
        sortBy: state.sortBy,
      );
      emit(state.copyWith(
        status: CarpoolStatus.loaded,
        allRides: rides,
        filteredRides: filtered,
        adminStats: stats,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CarpoolStatus.failure,
        errorMessage: 'Failed to load rides: $e',
      ));
    }
  }

  Future<void> _onSearchRides(
    SearchRidesEvent event,
    Emitter<CarpoolState> emit,
  ) async {
    emit(state.copyWith(status: CarpoolStatus.loading));
    try {
      final rides = await searchRidesUseCase(
        origin: event.origin,
        destination: event.destination,
        date: event.date,
        passengers: event.passengers,
      );
      final filtered = _applyFilters(
        rides: rides,
        maxPrice: state.maxPriceFilter,
        instantOnly: state.instantBookingFilter,
        verifiedOnly: state.verifiedOnlyFilter,
        sortBy: state.sortBy,
      );
      emit(state.copyWith(
        status: CarpoolStatus.loaded,
        filteredRides: filtered,
        searchOrigin: event.origin,
        searchDestination: event.destination,
        searchDate: event.date,
        searchPassengers: event.passengers,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CarpoolStatus.failure,
        errorMessage: 'Search failed: $e',
      ));
    }
  }

  void _onClearSearch(
    ClearSearchEvent event,
    Emitter<CarpoolState> emit,
  ) {
    final filtered = _applyFilters(
      rides: state.allRides,
      maxPrice: null,
      instantOnly: false,
      verifiedOnly: false,
      sortBy: 'earliest',
    );
    emit(state.copyWith(
      filteredRides: filtered,
      searchOrigin: null,
      searchDestination: null,
      searchDate: null,
      searchPassengers: 1,
      maxPriceFilter: null,
      instantBookingFilter: false,
      verifiedOnlyFilter: false,
      sortBy: 'earliest',
    ));
  }

  void _onSelectRide(
    SelectRideEvent event,
    Emitter<CarpoolState> emit,
  ) {
    emit(state.copyWith(selectedRide: event.ride));
  }

  Future<void> _onPublishRide(
    PublishRideEvent event,
    Emitter<CarpoolState> emit,
  ) async {
    emit(state.copyWith(status: CarpoolStatus.loading));
    try {
      final published = await publishRideUseCase(event.ride);
      final updatedAll = List<CarpoolRide>.from(state.allRides)..insert(0, published);
      final stats = await repository.getAdminStats();
      final filtered = _applyFilters(
        rides: updatedAll,
        maxPrice: state.maxPriceFilter,
        instantOnly: state.instantBookingFilter,
        verifiedOnly: state.verifiedOnlyFilter,
        sortBy: state.sortBy,
      );
      emit(state.copyWith(
        status: CarpoolStatus.success,
        allRides: updatedAll,
        filteredRides: filtered,
        adminStats: stats,
        successMessage: 'Your ride from ${published.origin} has been published successfully!',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CarpoolStatus.failure,
        errorMessage: 'Could not publish ride: $e',
      ));
    }
  }

  Future<void> _onBookSeat(
    BookSeatEvent event,
    Emitter<CarpoolState> emit,
  ) async {
    emit(state.copyWith(status: CarpoolStatus.loading));
    try {
      final booking = await bookRideUseCase(
        rideId: event.rideId,
        passengerName: event.passengerName,
        passengerPhone: event.passengerPhone,
        seatsCount: event.seatsCount,
      );
      final refreshedRides = await getCarpoolRidesUseCase();
      final stats = await repository.getAdminStats();
      final selected = refreshedRides.firstWhere(
        (r) => r.id == event.rideId,
        orElse: () => refreshedRides.first,
      );
      final filtered = _applyFilters(
        rides: refreshedRides,
        maxPrice: state.maxPriceFilter,
        instantOnly: state.instantBookingFilter,
        verifiedOnly: state.verifiedOnlyFilter,
        sortBy: state.sortBy,
      );

      emit(state.copyWith(
        status: CarpoolStatus.success,
        allRides: refreshedRides,
        filteredRides: filtered,
        selectedRide: selected,
        latestBooking: booking,
        adminStats: stats,
        successMessage: 'Seat booked successfully! Boarding pass confirmed.',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CarpoolStatus.failure,
        errorMessage: 'Booking failed: $e',
      ));
    }
  }

  Future<void> _onCancelBooking(
    CancelBookingEvent event,
    Emitter<CarpoolState> emit,
  ) async {
    emit(state.copyWith(status: CarpoolStatus.loading));
    try {
      await cancelBookingUseCase(event.bookingId);
      final refreshedRides = await getCarpoolRidesUseCase();
      final stats = await repository.getAdminStats();
      final filtered = _applyFilters(
        rides: refreshedRides,
        maxPrice: state.maxPriceFilter,
        instantOnly: state.instantBookingFilter,
        verifiedOnly: state.verifiedOnlyFilter,
        sortBy: state.sortBy,
      );
      emit(state.copyWith(
        status: CarpoolStatus.success,
        allRides: refreshedRides,
        filteredRides: filtered,
        adminStats: stats,
        successMessage: 'Booking canceled successfully. Refund processed.',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CarpoolStatus.failure,
        errorMessage: 'Failed to cancel booking: $e',
      ));
    }
  }

  Future<void> _onUpdateRideStatus(
    UpdateRideStatusEvent event,
    Emitter<CarpoolState> emit,
  ) async {
    try {
      await updateRideStatusUseCase(event.rideId, event.status);
      final refreshed = await getCarpoolRidesUseCase();
      final stats = await repository.getAdminStats();
      final filtered = _applyFilters(
        rides: refreshed,
        maxPrice: state.maxPriceFilter,
        instantOnly: state.instantBookingFilter,
        verifiedOnly: state.verifiedOnlyFilter,
        sortBy: state.sortBy,
      );
      emit(state.copyWith(
        status: CarpoolStatus.loaded,
        allRides: refreshed,
        filteredRides: filtered,
        adminStats: stats,
        successMessage: 'Ride status changed to ${event.status}.',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CarpoolStatus.failure,
        errorMessage: 'Could not update status: $e',
      ));
    }
  }

  void _onToggleAdminMode(
    ToggleAdminModeEvent event,
    Emitter<CarpoolState> emit,
  ) {
    emit(state.copyWith(isAdminMode: event.isAdmin));
  }

  void _onFilterRides(
    FilterRidesEvent event,
    Emitter<CarpoolState> emit,
  ) {
    final maxPrice = event.maxPrice ?? state.maxPriceFilter;
    final instant = event.instantBookingOnly ?? state.instantBookingFilter;
    final verified = event.verifiedOnly ?? state.verifiedOnlyFilter;
    final sortBy = event.sortBy ?? state.sortBy;

    final filtered = _applyFilters(
      rides: state.allRides,
      maxPrice: maxPrice,
      instantOnly: instant,
      verifiedOnly: verified,
      sortBy: sortBy,
    );

    emit(state.copyWith(
      filteredRides: filtered,
      maxPriceFilter: maxPrice,
      instantBookingFilter: instant,
      verifiedOnlyFilter: verified,
      sortBy: sortBy,
    ));
  }

  List<CarpoolRide> _applyFilters({
    required List<CarpoolRide> rides,
    double? maxPrice,
    bool instantOnly = false,
    bool verifiedOnly = false,
    String sortBy = 'earliest',
  }) {
    var result = rides.where((r) {
      if (maxPrice != null && r.pricePerSeat > maxPrice) return false;
      if (instantOnly && !r.amenities.instantBooking) return false;
      if (verifiedOnly && !r.driver.isVerified) return false;
      return true;
    }).toList();

    if (sortBy == 'cheapest') {
      result.sort((a, b) => a.pricePerSeat.compareTo(b.pricePerSeat));
    } else if (sortBy == 'shortest') {
      result.sort((a, b) => a.durationMinutes.compareTo(b.durationMinutes));
    } else {
      // earliest
      result.sort((a, b) => a.departureTime.compareTo(b.departureTime));
    }
    return result;
  }
}
