import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../auth/presentation/widgets/survey_holiday_dialog.dart';
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
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF054752) : const Color(0xFFF0F3F6),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Text(
                              tab,
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppColors.primaryNavy,
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
            const Divider(height: 1, color: AppColors.borderLight),
            // Survey Banner prompt (matching screenshot 3 modal)
            InkWell(
              onTap: () => SurveyHolidayDialog.show(context),
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.chipBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withAlpha(50)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.beach_access, color: AppColors.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Take BlaBlaCar Holiday Survey: Who do you travel with?',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primaryNavy,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.primary),
                  ],
                ),
              ),
            ),
            // List / Content based on tab
            Expanded(
              child: BlocBuilder<CarpoolBloc, CarpoolState>(
                builder: (context, state) {
                  final now = DateTime.now();

                  // Booked rides by status
                  final List<Map<String, dynamic>> items = [];
                  for (final ride in state.allRides) {
                    for (final booking in ride.bookings) {
                      if (_selectedTab == 'Upcoming' &&
                          booking.status == 'CONFIRMED' &&
                          ride.departureTime.isAfter(now.subtract(const Duration(hours: 1)))) {
                        items.add({'ride': ride, 'booking': booking});
                      } else if (_selectedTab == 'Past' &&
                          (ride.departureTime.isBefore(now.subtract(const Duration(hours: 1))) ||
                              booking.status == 'COMPLETED')) {
                        items.add({'ride': ride, 'booking': booking});
                      } else if (_selectedTab == 'Cancelled' && booking.status == 'CANCELLED') {
                        items.add({'ride': ride, 'booking': booking});
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
                      final PassengerBooking booking = item['booking'] as PassengerBooking;

                      return _buildRideBookingCard(context, ride, booking);
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

  Widget _buildRideBookingCard(BuildContext context, CarpoolRide ride, PassengerBooking booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormatter.formatDate(ride.departureTime),
                style: AppTypography.titleMedium.copyWith(color: AppColors.primary),
              ),
              Text(
                DateFormatter.formatCurrency(booking.totalPrice),
                style: AppTypography.titleLarge.copyWith(color: AppColors.primaryNavy),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${ride.origin} → ${ride.destination}',
            style: AppTypography.titleMedium.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            'Departure: ${DateFormatter.formatTime(ride.departureTime)} · ${booking.seatsBooked} seat reserved',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(ride.driver.avatarUrl),
                onBackgroundImageError: (error, stack) {},
                child: Text(ride.driver.name[0]),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Driver: ${ride.driver.name}',
                  style: AppTypography.titleMedium.copyWith(fontSize: 13),
                ),
              ),
              if (_selectedTab == 'Upcoming')
                TextButton(
                  onPressed: () {
                    context.read<CarpoolBloc>().add(CancelBookingEvent(booking.id));
                  },
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                  child: const Text('Cancel Booking'),
                ),
              TextButton(
                onPressed: () {
                  context.push(AppRoutes.rideDetails, extra: ride);
                },
                child: const Text('Details'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
