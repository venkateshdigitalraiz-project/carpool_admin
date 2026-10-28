import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../domain/entities/carpool_ride.dart';
import '../bloc/carpool_bloc.dart';
import '../bloc/carpool_event.dart';
import '../bloc/carpool_state.dart';
import '../widgets/driver_profile_card.dart';
import '../widgets/route_timeline.dart';
import '../widgets/seat_counter.dart';

class RideDetailsPage extends StatefulWidget {
  final CarpoolRide ride;

  const RideDetailsPage({super.key, required this.ride});

  @override
  State<RideDetailsPage> createState() => _RideDetailsPageState();
}

class _RideDetailsPageState extends State<RideDetailsPage> {
  int _selectedSeats = 1;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CarpoolBloc, CarpoolState>(
      builder: (context, state) {
        // Resolve updated ride from state if available
        final matches = state.allRides.where((r) => r.id == widget.ride.id);
        final currentRide = matches.isNotEmpty ? matches.first : widget.ride;

        final totalPrice = currentRide.pricePerSeat * _selectedSeats;
        final bool isFull = currentRide.availableSeats == 0;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            title: Text(
              DateFormatter.formatDate(currentRide.departureTime),
              style: AppTypography.titleMedium,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined, color: AppColors.textPrimary),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ride link copied to clipboard!')),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Route itinerary container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Trip Itinerary', style: AppTypography.titleLarge),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.chipBackground,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              DateFormatter.formatDuration(currentRide.durationMinutes),
                              style: AppTypography.labelMedium.copyWith(color: AppColors.primaryDark),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      RouteTimeline(ride: currentRide, compact: false),
                      const Divider(height: 1, color: AppColors.borderLight),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Distance', style: AppTypography.bodyMedium),
                          Text('${currentRide.distanceKm.toInt()} km', style: AppTypography.titleMedium.copyWith(fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Driver card
                DriverProfileCard(
                  driver: currentRide.driver,
                  amenities: currentRide.amenities,
                ),
                const SizedBox(height: 16),
                // Co-passengers section
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Passengers on this ride', style: AppTypography.titleMedium),
                          Text(
                            '${currentRide.totalSeats - currentRide.availableSeats} / ${currentRide.totalSeats} booked',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (currentRide.bookings.isEmpty)
                        Text(
                          'No passengers yet. Be the first to book a seat!',
                          style: AppTypography.bodySmall.copyWith(fontStyle: FontStyle.italic),
                        )
                      else
                        ...currentRide.bookings.map(
                          (booking) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppColors.inputFill,
                                  child: const Icon(Icons.person, size: 18, color: AppColors.primaryNavy),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(booking.passengerName, style: AppTypography.titleMedium.copyWith(fontSize: 14)),
                                      Text('${booking.seatsBooked} seat booked', style: AppTypography.bodySmall),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withAlpha(25),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    booking.status,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomSheet: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x0C000000),
                  blurRadius: 10,
                  offset: Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormatter.formatCurrency(totalPrice),
                        style: AppTypography.priceLarge.copyWith(color: AppColors.primaryNavy),
                      ),
                      Text(
                        'for $_selectedSeats ${_selectedSeats == 1 ? 'seat' : 'seats'}',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: CustomButton(
                      text: isFull ? 'Ride Full' : 'Book $_selectedSeats Seat',
                      backgroundColor: isFull ? AppColors.textDisabled : AppColors.primary,
                      onPressed: isFull
                          ? null
                          : () => _showBookingModal(context, currentRide),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showBookingModal(BuildContext context, CarpoolRide ride) {
    final nameCtrl = TextEditingController(text: 'John Doe');
    final phoneCtrl = TextEditingController(text: '+1 (555) 392-8812');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final double fare = ride.pricePerSeat * _selectedSeats;
            return Container(
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Confirm BlaBlaCar Booking', style: AppTypography.titleLarge),
                    const SizedBox(height: 4),
                    Text('From ${ride.origin} to ${ride.destination}', style: AppTypography.bodySmall),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Number of Seats', style: AppTypography.titleMedium.copyWith(fontSize: 14)),
                        SeatCounter(
                          count: _selectedSeats,
                          min: 1,
                          max: ride.availableSeats,
                          onChanged: (newCount) {
                            setModalState(() {
                              _selectedSeats = newCount;
                            });
                            setState(() {
                              _selectedSeats = newCount;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: nameCtrl,
                      labelText: 'Passenger Full Name',
                      hintText: 'Enter your name',
                      prefixIcon: Icons.person_outline,
                      validator: (v) => v == null || v.isEmpty ? 'Please enter name' : null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: phoneCtrl,
                      labelText: 'Contact Phone Number',
                      hintText: 'Enter your phone number',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) => v == null || v.isEmpty ? 'Please enter phone' : null,
                    ),
                    const SizedBox(height: 16),
                    // Fare breakdown card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${DateFormatter.formatCurrency(ride.pricePerSeat)} x $_selectedSeats seat(s)', style: AppTypography.bodyMedium),
                              Text(DateFormatter.formatCurrency(fare), style: AppTypography.bodyMedium),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Booking & Service Fee', style: AppTypography.bodySmall),
                              Text('FREE', style: AppTypography.bodySmall.copyWith(color: AppColors.success, fontWeight: FontWeight.w700)),
                            ],
                          ),
                          const Divider(height: 16, color: AppColors.border),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total to pay in car', style: AppTypography.titleMedium),
                              Text(
                                DateFormatter.formatCurrency(fare),
                                style: AppTypography.titleLarge.copyWith(color: AppColors.primaryNavy),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      text: ride.amenities.instantBooking
                          ? 'Instant Book · Pay in Car'
                          : 'Send Booking Request',
                      icon: Icons.check_circle_outline,
                      onPressed: () {
                        if (formKey.currentState?.validate() ?? false) {
                          context.read<CarpoolBloc>().add(
                                BookSeatEvent(
                                  rideId: ride.id,
                                  passengerName: nameCtrl.text.trim(),
                                  passengerPhone: phoneCtrl.text.trim(),
                                  seatsCount: _selectedSeats,
                                ),
                              );
                          modalCtx.pop();
                          _showSuccessDialog(context, ride);
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context, CarpoolRide ride) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.check_circle, size: 56, color: AppColors.success),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Booking Confirmed!', style: AppTypography.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'You have reserved $_selectedSeats seat(s) for the trip to ${ride.destination}. The driver has been notified.',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          CustomButton(
            text: 'View Your Rides',
            onPressed: () {
              ctx.pop();
              context.pop();
            },
          ),
        ],
      ),
    );
  }
}
