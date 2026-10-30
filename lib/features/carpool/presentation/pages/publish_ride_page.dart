import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/distance_calculator.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../places/domain/entities/place_prediction.dart';
import '../../../places/presentation/bloc/places_bloc.dart';
import '../../../places/presentation/bloc/places_event.dart';
import '../../domain/entities/carpool_ride.dart';
import '../bloc/carpool_bloc.dart';
import '../bloc/carpool_event.dart';
import '../bloc/route_selection/route_selection_bloc.dart';
import '../bloc/route_selection/route_selection_event.dart';
import '../widgets/publish_location_step_view.dart';
import '../widgets/seat_counter.dart';

import 'dart:math' as math;
import '../../domain/entities/route_option.dart';
// ignore: unused_import
import 'route_selection_page.dart';
import 'stopovers_selection_page.dart';

enum PublishFlowStep {
  pickupLocation, // Step 1: Pick-up
  dropoffLocation, // Step 2: Drop-off
  // routeSelection, // Step 3: Route Selection ("What is your return route?") - preserved for future use
  stopovers, // Step 4: Stopovers ("Add stopovers to get more passengers")
  rideDetails, // Step 5: Date, Time, Price & Vehicle info
}

class PublishRidePage extends StatefulWidget {
  final VoidCallback? onPublished;
  final VoidCallback? onExitFlow;

  const PublishRidePage({super.key, this.onPublished, this.onExitFlow});

  @override
  State<PublishRidePage> createState() => PublishRidePageState();
}

class PublishRidePageState extends State<PublishRidePage> {
  PublishFlowStep _currentStep = PublishFlowStep.pickupLocation;
  int _flowSessionKey = 0;

  PlacePrediction? _pickupLocation;
  PlacePrediction? _dropoffLocation;
  RouteOption? _selectedRoute;
  RoutePriceEstimate? _priceEstimate;

  final _formKey = GlobalKey<FormState>();
  final _priceCtrl = TextEditingController(text: '1500');
  final _carModelCtrl = TextEditingController(text: 'Toyota Camry');
  final _carPlateCtrl = TextEditingController(text: 'AP-16-AB-1234');
  final _stopCtrl = TextEditingController();

  DateTime _departureDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _departureTime = const TimeOfDay(hour: 9, minute: 0);

  int _seatsAvailable = 3;
  bool _instantBooking = true;
  final bool _smokingAllowed = false;
  final bool _petsAllowed = false;
  final bool _maxTwoInBack = true;
  bool _acEnabled = true;
  final List<String> _intermediateStops = [];

  @override
  void initState() {
    super.initState();
    _calculateRouteAndPrice();
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    _carModelCtrl.dispose();
    _carPlateCtrl.dispose();
    _stopCtrl.dispose();
    super.dispose();
  }

  Future<void> _calculateRouteAndPrice() async {
    final origin = _pickupLocation?.mainText.isNotEmpty == true
        ? _pickupLocation!.mainText
        : (_pickupLocation?.displayAddress ?? '');
    final dest = _dropoffLocation?.mainText.isNotEmpty == true
        ? _dropoffLocation!.mainText
        : (_dropoffLocation?.displayAddress ?? '');

    if (origin.isEmpty || dest.isEmpty) return;

    if (_selectedRoute != null) {
      final distanceKm = _selectedRoute!.distanceKm;
      final estimatedPrice = (distanceKm * 5.0).roundToDouble();
      final marginMin = math.max(0.0, estimatedPrice - 50.0);
      final marginMax = estimatedPrice >= 1000 ? estimatedPrice + 100.0 : estimatedPrice + 50.0;
      if (mounted) {
        setState(() {
          _priceEstimate = RoutePriceEstimate(
            distanceKm: distanceKm,
            ratePerKm: 5.0,
            estimatedPrice: estimatedPrice,
            marginMinPrice: marginMin,
            marginMaxPrice: marginMax,
          );
          _priceCtrl.text = estimatedPrice.round().toString();
        });
      }
      return;
    }

    final estimate = await DistanceCalculator.calculateRouteEstimate(
      originText: origin,
      destinationText: dest,
      ratePerKm: 5.0,
    );

    if (mounted) {
      setState(() {
        _priceEstimate = estimate;
        _priceCtrl.text = estimate.estimatedPrice.round().toString();
      });
    }
  }

  void _onPickupConfirmed(PlacePrediction location) {
    setState(() {
      _pickupLocation = location;
      _currentStep = PublishFlowStep.dropoffLocation;
    });
  }

  void _onDropoffConfirmed(PlacePrediction location) {
    setState(() {
      _dropoffLocation = location;
      // Step 3 (routeSelection) is temporarily commented out for future use; advance directly to stopovers:
      _currentStep = PublishFlowStep.stopovers;
      // _currentStep = PublishFlowStep.routeSelection;
    });
    _calculateRouteAndPrice();
  }

  // Preserved for future use when routeSelection step is re-enabled
  // ignore: unused_element
  void _onRouteConfirmed(RouteOption route) {
    setState(() {
      _selectedRoute = route;
      _currentStep = PublishFlowStep.stopovers;
    });
    _calculateRouteAndPrice();
  }

  void _onStopoversConfirmed(List<String> stopovers) {
    setState(() {
      _intermediateStops
        ..clear()
        ..addAll(stopovers);
      _currentStep = PublishFlowStep.rideDetails;
    });
  }

  void _onBackFromDropoff() {
    setState(() {
      _currentStep = PublishFlowStep.pickupLocation;
      _dropoffLocation = null;
      _selectedRoute = null;
    });
  }

  // Preserved for future use when routeSelection step is re-enabled
  // ignore: unused_element
  void _onBackFromRouteSelection() {
    setState(() {
      _currentStep = PublishFlowStep.dropoffLocation;
      _selectedRoute = null;
    });
  }

  void _onBackFromStopovers() {
    setState(() {
      // Step 3 (routeSelection) is temporarily commented out for future use; go back to dropoffLocation:
      _currentStep = PublishFlowStep.dropoffLocation;
      // _currentStep = PublishFlowStep.routeSelection;
    });
  }

  void _onBackFromDetails() {
    setState(() {
      _currentStep = PublishFlowStep.stopovers;
      _priceEstimate = null;
      _priceCtrl.clear();
      _stopCtrl.clear();
    });
  }

  void _submitRide() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final double price = double.tryParse(_priceCtrl.text) ??
        (_priceEstimate?.estimatedPrice ?? 1500.0);
    final distanceKm = _priceEstimate?.distanceKm ?? 300.0;
    var scheduledDateTime = DateTime(
      _departureDate.year,
      _departureDate.month,
      _departureDate.day,
      _departureTime.hour,
      _departureTime.minute,
    );
    // Ensure newly published ride departure is in the future
    if (scheduledDateTime.isBefore(DateTime.now())) {
      scheduledDateTime = DateTime.now().add(const Duration(hours: 4));
    }
    final estimatedArrival = scheduledDateTime.add(
      Duration(minutes: ((distanceKm / 65.0) * 60).round()),
    );

    final originMain = _pickupLocation?.mainText.isNotEmpty == true
        ? _pickupLocation!.mainText
        : (_pickupLocation?.displayAddress ?? '');
    final originAddress = _pickupLocation?.displayAddress.isNotEmpty == true
        ? _pickupLocation!.displayAddress
        : originMain;
    final destMain = _dropoffLocation?.mainText.isNotEmpty == true
        ? _dropoffLocation!.mainText
        : (_dropoffLocation?.displayAddress ?? '');
    final destAddress = _dropoffLocation?.displayAddress.isNotEmpty == true
        ? _dropoffLocation!.displayAddress
        : destMain;

    final newRide = CarpoolRide(
      id: 'ride-${DateTime.now().millisecondsSinceEpoch}',
      origin: originMain,
      originAddress: originAddress,
      destination: destMain,
      destinationAddress: destAddress,
      departureTime: scheduledDateTime,
      arrivalTime: estimatedArrival,
      durationMinutes: ((distanceKm / 65.0) * 60).round(),
      distanceKm: distanceKm,
      pricePerSeat: price,
      totalSeats: _seatsAvailable,
      availableSeats: _seatsAvailable,
      driver: DriverProfile(
        id: 'drv-current-user',
        name: 'Vankatesh',
        avatarUrl:
            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
        rating: 5.0,
        totalReviews: 1,
        isVerified: true,
        carModel: _carModelCtrl.text.trim(),
        plateNumber: _carPlateCtrl.text.trim(),
        phone: '+91 9876543210',
        bio: 'Careful driver, comfortable ride.',
      ),
      amenities: RideAmenities(
        instantBooking: _instantBooking,
        smokingAllowed: _smokingAllowed,
        petsAllowed: _petsAllowed,
        maxTwoInBack: _maxTwoInBack,
        acEnabled: _acEnabled,
        luggageSize: 'Medium',
      ),
      intermediateStops: List.from(_intermediateStops),
      status: 'ACTIVE',
      bookings: const [],
    );

    context.read<CarpoolBloc>().add(PublishRideEvent(newRide));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Ride from $originMain to $destMain published successfully!',
        ),
        backgroundColor: AppColors.success,
      ),
    );

    // Reset flow and completely clear all page details
    _resetPublishFlow();
    widget.onPublished?.call();
  }

  void _resetPublishFlow() {
    setState(() {
      _flowSessionKey++;
      _currentStep = PublishFlowStep.pickupLocation;
      _pickupLocation = null;
      _dropoffLocation = null;
      _selectedRoute = null;
      _priceEstimate = null;
      _intermediateStops.clear();
      _priceCtrl.clear();
      _stopCtrl.clear();
      _seatsAvailable = 3;
      _instantBooking = true;
      _acEnabled = true;
      _departureDate = DateTime.now().add(const Duration(days: 1));
      _departureTime = const TimeOfDay(hour: 9, minute: 0);
    });
    _formKey.currentState?.reset();
    try {
      context.read<PlacesBloc>().add(const ClearPlacesEvent());
    } catch (_) {}
    try {
      context.read<RouteSelectionBloc>().add(const ClearRouteSelectionEvent());
    } catch (_) {}
  }

  void resetFlow() {
    _resetPublishFlow();
  }

  bool handleBack() {
    _onStepBack();
    return true;
  }

  void _onStepBack() {
    switch (_currentStep) {
      case PublishFlowStep.pickupLocation:
        _resetPublishFlow();
        widget.onExitFlow?.call();
        break;
      case PublishFlowStep.dropoffLocation:
        _onBackFromDropoff();
        break;
      // case PublishFlowStep.routeSelection:
      //   _onBackFromRouteSelection();
      //   break;
      case PublishFlowStep.stopovers:
        _onBackFromStopovers();
        break;
      case PublishFlowStep.rideDetails:
        _onBackFromDetails();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        _onStepBack();
      },
      child: switch (_currentStep) {
        // STEP 1: Reused Pick-up Location screen with Map
        PublishFlowStep.pickupLocation => PublishLocationStepView(
          key: ValueKey('pickup_step_$_flowSessionKey'),
          isPickup: true,
          initialLocation: _pickupLocation,
          onBack: _onStepBack,
          onLocationConfirmed: _onPickupConfirmed,
        ),

        // STEP 2: Reused Drop-off Location screen with Map
        PublishFlowStep.dropoffLocation => PublishLocationStepView(
          key: ValueKey('dropoff_step_$_flowSessionKey'),
          isPickup: false,
          pickupLocation: _pickupLocation,
          initialLocation: _dropoffLocation,
          onBack: _onBackFromDropoff,
          onLocationConfirmed: _onDropoffConfirmed,
        ),

        // STEP 3: Route Selection matching Screenshot ("What is your return route?")
        // Commented out for future use. Re-enable by uncommenting here and in PublishFlowStep enum.
        // PublishFlowStep.routeSelection => RouteSelectionPage(
        //   key: ValueKey('route_selection_step_$_flowSessionKey'),
        //   origin: _pickupLocation,
        //   destination: _dropoffLocation,
        //   title: 'What is your return route?',
        //   onBack: _onBackFromRouteSelection,
        //   onRouteConfirmed: _onRouteConfirmed,
        // ),

        // STEP 4: Stopovers matching Screenshot ("Add stopovers to get more passengers")
        PublishFlowStep.stopovers => StopoversSelectionPage(
          key: ValueKey('stopovers_step_$_flowSessionKey'),
          origin: _pickupLocation?.mainText.isNotEmpty == true
              ? _pickupLocation!.mainText
              : (_pickupLocation?.displayAddress ?? ''),
          destination: _dropoffLocation?.mainText.isNotEmpty == true
              ? _dropoffLocation!.mainText
              : (_dropoffLocation?.displayAddress ?? ''),
          selectedRoute: _selectedRoute,
          onBack: _onBackFromStopovers,
          onStopoversConfirmed: _onStopoversConfirmed,
        ),

        // STEP 5: Final Ride Details & Pricing
        PublishFlowStep.rideDetails => _buildRideDetailsView(),
      },
    );
  }

  Widget _buildRideDetailsView() {
    final originText = _pickupLocation?.mainText.isNotEmpty == true
        ? _pickupLocation!.mainText
        : (_pickupLocation?.displayAddress ?? '');
    final destText = _dropoffLocation?.mainText.isNotEmpty == true
        ? _dropoffLocation!.mainText
        : (_dropoffLocation?.displayAddress ?? '');

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          'Ride Details & Schedule',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.primaryNavy,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryNavy),
          onPressed: _onBackFromDetails,
        ),
        actions: [
          TextButton(
            onPressed: () {
              _resetPublishFlow();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All ride and map details cleared'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: Text(
              'Clear',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // Selected Route Summary Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F7FB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withAlpha(50)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Column(
                        children: [
                          const Icon(
                            Icons.trip_origin,
                            size: 20,
                            color: AppColors.primary,
                          ),
                          Container(
                            width: 2,
                            height: 32,
                            color: AppColors.primary.withAlpha(80),
                          ),
                          const Icon(
                            Icons.location_on,
                            size: 22,
                            color: AppColors.error,
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              originText,
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: AppColors.primaryNavy,
                              ),
                            ),
                            Text(
                              _pickupLocation?.displayAddress ?? '',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              destText,
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: AppColors.primaryNavy,
                              ),
                            ),
                            Text(
                              _dropoffLocation?.displayAddress ?? '',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Change button
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _currentStep = PublishFlowStep.pickupLocation;
                          });
                        },
                        child: const Text('Edit'),
                      ),
                    ],
                  ),
                  if (_selectedRoute != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFD6E4EC)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.alt_route, size: 18, color: Color(0xFF0070E0)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedRoute!.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: Color(0xFF0A1E34),
                                  ),
                                ),
                                Text(
                                  _selectedRoute!.highwayName,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: Color(0xFF5E7A8A),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: () {
                              // Route selection is temporarily commented out for future use:
                              // setState(() {
                              //   _currentStep = PublishFlowStep.routeSelection;
                              // });
                            },
                            child: const Text('Change', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (_intermediateStops.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFD6E4EC)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.pin_drop_outlined, size: 18, color: Color(0xFF10B981)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Stopovers (${_intermediateStops.length})',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: Color(0xFF0A1E34),
                                  ),
                                ),
                                Text(
                                  _intermediateStops.join(' • '),
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: Color(0xFF5E7A8A),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: () {
                              setState(() {
                                _currentStep = PublishFlowStep.stopovers;
                              });
                            },
                            child: const Text('Edit', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const Divider(height: 24, color: Color(0xFFD6E4EC)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Distance Column
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estimated Distance',
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.route_rounded,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_priceEstimate?.distanceKm.round() ?? 300} km',
                                style: AppTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: AppColors.primaryNavy,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Rate & Estimate Column
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cost @ ₹5/km',
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '₹${_priceEstimate?.estimatedPrice.round() ?? 1500}',
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: AppColors.primaryNavy,
                            ),
                          ),
                        ],
                      ),

                      // Margin Range Column
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Margin Range (±50)',
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _priceEstimate?.priceRangeFormatted ??
                                  '1500 to 1600',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: Color(0xFF15803D),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Date & Time
            Text(
              'Date & Time',
              style: AppTypography.titleLarge.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryNavy,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _departureDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 90)),
                      );
                      if (picked != null) {
                        setState(() => _departureDate = picked);
                      }
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF2F6),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date',
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormatter.formatDate(_departureDate),
                            style: AppTypography.titleMedium.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _departureTime,
                      );
                      if (picked != null) {
                        setState(() => _departureTime = picked);
                      }
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF2F6),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Time',
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _departureTime.format(context),
                            style: AppTypography.titleMedium.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Seats & Price
            Text(
              'Seats & Pricing',
              style: AppTypography.titleLarge.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryNavy,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF2F6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Seats',
                        style: AppTypography.titleMedium.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Passenger capacity',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                  SeatCounter(
                    count: _seatsAvailable,
                    min: 1,
                    max: 3,
                    onChanged: (val) => setState(() => _seatsAvailable = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            CustomTextField(
              controller: _priceCtrl,
              labelText: 'Price per Seat (₹ INR)',
              hintText: 'e.g. 1500',
              prefixIcon: Icons.currency_rupee,
              keyboardType: TextInputType.number,
              validator: (v) => v == null || double.tryParse(v) == null
                  ? 'Enter valid price'
                  : null,
            ),
            const SizedBox(height: 8),

            // Margin & Automatic Price Display Card matching user prompt
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF86EFAC)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: Color(0xFF16A34A),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estimated Price: ₹${_priceEstimate?.estimatedPrice.round() ?? 1500} (${_priceEstimate?.distanceKm.round() ?? 300} km @ ₹5/km)',
                          style: AppTypography.bodySmall.copyWith(
                            color: const Color(0xFF166534),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Recommended Price Range: ${_priceEstimate?.priceRangeFormatted ?? "1500 to 1600"} (with margin)',
                          style: AppTypography.bodySmall.copyWith(
                            color: const Color(0xFF15803D),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Vehicle & Preferences
            // Text(
            //   'Vehicle & Comfort',
            //   style: AppTypography.titleLarge.copyWith(
            //     fontSize: 18,
            //     fontWeight: FontWeight.w800,
            //     color: AppColors.primaryNavy,
            //   ),
            // ),
            // const SizedBox(height: 12),
            // Row(
            //   children: [
            //     Expanded(
            //       child: CustomTextField(
            //         controller: _carModelCtrl,
            //         labelText: 'Car Model',
            //         hintText: 'e.g. Toyota Camry',
            //         prefixIcon: Icons.directions_car,
            //         validator: (v) =>
            //             v == null || v.isEmpty ? 'Required' : null,
            //       ),
            //     ),
            //     const SizedBox(width: 12),
            //     Expanded(
            //       child: CustomTextField(
            //         controller: _carPlateCtrl,
            //         labelText: 'License Plate',
            //         hintText: 'e.g. AP-16-AB-1234',
            //         prefixIcon: Icons.pin,
            //         validator: (v) =>
            //             v == null || v.isEmpty ? 'Required' : null,
            //       ),
            //     ),
            //   ],
            // ),
            // const SizedBox(height: 12),
            //
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Instant Booking',
                style: AppTypography.titleMedium.copyWith(fontSize: 14),
              ),
              subtitle: Text(
                'Riders book automatically',
                style: AppTypography.bodySmall,
              ),
              value: _instantBooking,
              activeThumbColor: AppColors.primary,
              onChanged: (val) => setState(() => _instantBooking = val),
            ),

            // SwitchListTile(
            //   contentPadding: EdgeInsets.zero,
            //   title: Text(
            //     'Max 2 in the back',
            //     style: AppTypography.titleMedium.copyWith(fontSize: 14),
            //   ),
            //   subtitle: Text(
            //     'Guarantee comfort',
            //     style: AppTypography.bodySmall,
            //   ),
            //   value: _maxTwoInBack,
            //   activeThumbColor: AppColors.primary,
            //   onChanged: (val) => setState(() => _maxTwoInBack = val),
            // ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Air Conditioning',
                style: AppTypography.titleMedium.copyWith(fontSize: 14),
              ),
              value: _acEnabled,
              activeThumbColor: AppColors.primary,
              onChanged: (val) => setState(() => _acEnabled = val),
            ),
            // SwitchListTile(
            //   contentPadding: EdgeInsets.zero,
            //   title: Text(
            //     'Pets Allowed',
            //     style: AppTypography.titleMedium.copyWith(fontSize: 14),
            //   ),
            //   value: _petsAllowed,
            //   activeThumbColor: AppColors.primary,
            //   onChanged: (val) => setState(() => _petsAllowed = val),
            // ),
            // SwitchListTile(
            //   contentPadding: EdgeInsets.zero,
            //   title: Text(
            //     'Smoking Allowed',
            //     style: AppTypography.titleMedium.copyWith(fontSize: 14),
            //   ),
            //   value: _smokingAllowed,
            //   activeThumbColor: AppColors.primary,
            //   onChanged: (val) => setState(() => _smokingAllowed = val),
            // ),
            const SizedBox(height: 28),
            CustomButton(
              text: 'Publish Carpool Ride',
              icon: Icons.publish_rounded,
              backgroundColor: AppColors.primary,
              onPressed: _submitRide,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
