import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../domain/entities/carpool_ride.dart';
import '../../domain/entities/passenger_booking.dart';
import '../bloc/carpool_bloc.dart';
import '../bloc/carpool_event.dart';
import '../bloc/carpool_state.dart';

class YourRidesPage extends StatefulWidget {
  final VoidCallback onExploreTapped;

  const YourRidesPage({super.key, required this.onExploreTapped});

  @override
  State<YourRidesPage> createState() => _YourRidesPageState();
}

class _YourRidesPageState extends State<YourRidesPage> {
  // Tabs matching BlaBlaCar Screenshot 3 & 4: Upcoming, Past, Cancelled
  String _selectedTab = 'Upcoming';

  final List<String> _tabs = ['Upcoming', 'Past', 'Cancelled'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title matching BlaBlaCar Screenshot 3
                  Text(
                    'Your rides',
                    style: AppTypography.displayLarge.copyWith(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Tab Pills: Upcoming | Past | Cancelled
                  Row(
                    children: _tabs.map((tab) {
                      final isSelected = _selectedTab == tab;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedTab = tab;
                            });
                          },
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF054752)
                                  : const Color(0xFFF0F3F6),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Text(
                              tab,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.primaryNavy,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // List / Content based on tab
            Expanded(
              child: BlocBuilder<CarpoolBloc, CarpoolState>(
                builder: (context, state) {
                  final now = DateTime.now();

                  // All rides that belong to the current user (either as driver or as booked passenger)
                  final List<Map<String, dynamic>> items = [];
                  for (final ride in state.allRides) {
                    final bool isDriver =
                        ride.driver.id == 'drv-current-user' ||
                        ride.driver.name.toLowerCase() == 'vankatesh' ||
                        ride.driver.name.toLowerCase() == 'venkatesh';
                    final bool isExplicitCancelled = ride.status == 'CANCELLED';
                    final bool isCompleted = ride.status == 'COMPLETED';

                    // Check each item's date & time against current date & time:
                    // If date & time is less than current date & time, it is not visible in Upcoming,
                    // and instead displays in the Cancelled tab.
                    final bool isTimePassed = ride.departureTime.isBefore(now);
                    final bool isCancelledTab =
                        isExplicitCancelled || isTimePassed;

                    // Upcoming: Date and time must NOT be less than current date & time, and not cancelled or completed
                    final bool isUpcoming =
                        !isCancelledTab && !isCompleted && !isTimePassed;
                    final bool isPast = isCompleted;

                    // 1. Published Ride as Driver
                    if (isDriver) {
                      if (_selectedTab == 'Upcoming' && isUpcoming) {
                        items.add({'ride': ride, 'isDriver': true});
                      } else if (_selectedTab == 'Past' && isPast) {
                        items.add({'ride': ride, 'isDriver': true});
                      } else if (_selectedTab == 'Cancelled' &&
                          isCancelledTab) {
                        items.add({'ride': ride, 'isDriver': true});
                      }
                    }

                    // 2. Booked rides as Passenger
                    for (final booking in ride.bookings) {
                      final bool bookingExplicitCancelled =
                          booking.status == 'CANCELLED';
                      final bool isBookingCancelledTab =
                          bookingExplicitCancelled || isCancelledTab;
                      final bool bookingCompleted =
                          booking.status == 'COMPLETED' || isCompleted;
                      final bool bookingUpcoming =
                          !isBookingCancelledTab &&
                          !bookingCompleted &&
                          !isTimePassed;
                      final bool bookingPast = bookingCompleted;

                      if (_selectedTab == 'Upcoming' && bookingUpcoming) {
                        items.add({
                          'ride': ride,
                          'booking': booking,
                          'isDriver': false,
                        });
                      } else if (_selectedTab == 'Past' && bookingPast) {
                        items.add({
                          'ride': ride,
                          'booking': booking,
                          'isDriver': false,
                        });
                      } else if (_selectedTab == 'Cancelled' &&
                          isBookingCancelledTab) {
                        items.add({
                          'ride': ride,
                          'booking': booking,
                          'isDriver': false,
                        });
                      }
                    }
                  }

                  if (items.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final CarpoolRide ride = item['ride'] as CarpoolRide;
                      final PassengerBooking? booking =
                          item['booking'] as PassengerBooking?;
                      final bool isDriver = item['isDriver'] as bool? ?? false;

                      return _buildRideCard(
                        context,
                        ride: ride,
                        booking: booking,
                        isDriver: isDriver,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Circular graphical illustration matching Screenshot 3
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF5F8),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF00AFF5), width: 6),
              ),
              child: const Center(
                child: Icon(
                  Icons.directions_car_outlined,
                  size: 48,
                  color: AppColors.primaryNavy,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No $_selectedTab rides',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.primaryNavy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'When you book or publish a carpool ride, your reservations and itineraries will appear here.',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Find a Ride',
              width: 200,
              onPressed: widget.onExploreTapped,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRideCard(
    BuildContext context, {
    required CarpoolRide ride,
    PassengerBooking? booking,
    required bool isDriver,
  }) {
    final priceText = isDriver
        ? '${DateFormatter.formatCurrency(ride.pricePerSeat)} / seat'
        : DateFormatter.formatCurrency(
            booking?.totalPrice ?? ride.pricePerSeat,
          );

    final seatsSubtext = isDriver
        ? 'Departure: ${DateFormatter.formatTime(ride.departureTime)} · ${ride.availableSeats} of ${ride.totalSeats} seats available'
        : 'Departure: ${DateFormatter.formatTime(ride.departureTime)} · ${booking?.seatsBooked ?? 1} seat reserved';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDriver ? AppColors.primary.withAlpha(90) : AppColors.border,
          width: isDriver ? 1.5 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Date & Role Badge & Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      DateFormatter.formatDate(ride.departureTime),
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (isDriver)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFF2E7D32).withAlpha(80),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.directions_car,
                              size: 11,
                              color: Color(0xFF2E7D32),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'DRIVER',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF2E7D32),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                priceText,
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.primaryNavy,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Origin -> Destination
          Row(
            children: [
              Expanded(
                child: Text(
                  '${ride.origin} → ${ride.destination}',
                  style: AppTypography.titleMedium.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryNavy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Departure time and seats
          Text(
            seatsSubtext,
            style: AppTypography.bodySmall.copyWith(
              color: const Color(0xFF5E7A8A),
              fontWeight: FontWeight.w500,
            ),
          ),

          // Optional Stopovers info
          if (ride.intermediateStops.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.alt_route_rounded,
                  size: 14,
                  color: Color(0xFF0070E0),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Stopovers: ${ride.intermediateStops.join(' • ')}',
                    style: AppTypography.bodySmall.copyWith(
                      color: const Color(0xFF0070E0),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 12),

          // Driver & Actions
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(ride.driver.avatarUrl),
                onBackgroundImageError: (_, _) {},
                child: Text(ride.driver.name[0]),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDriver ? 'You (Driver)' : 'Driver: ${ride.driver.name}',
                      style: AppTypography.titleMedium.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (isDriver && ride.driver.carModel.isNotEmpty)
                      Text(
                        '${ride.driver.carModel} · ${ride.driver.plateNumber}',
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: 11,
                          color: const Color(0xFF708C91),
                        ),
                      ),
                  ],
                ),
              ),
              if (_selectedTab == 'Upcoming')
                TextButton(
                  onPressed: () {
                    if (isDriver) {
                      context.read<CarpoolBloc>().add(
                        UpdateRideStatusEvent(
                          rideId: ride.id,
                          status: 'CANCELLED',
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Your published ride has been cancelled.',
                          ),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    } else if (booking != null) {
                      context.read<CarpoolBloc>().add(
                        CancelBookingEvent(booking.id),
                      );
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                  ),
                  child: Text(isDriver ? 'Cancel Ride' : 'Cancel Booking'),
                ),
              TextButton(
                onPressed: () {
                  context.push(AppRoutes.rideDetails, extra: ride);
                },
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                ),
                child: const Text('Details'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
