import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../bloc/carpool_bloc.dart';
import '../bloc/carpool_event.dart';
import '../bloc/carpool_state.dart';
import '../widgets/carpool_table.dart';

class CarpoolAdminDashboardPage extends StatelessWidget {
  final VoidCallback? onSwitchToPassengerMode;

  const CarpoolAdminDashboardPage({
    super.key,
    this.onSwitchToPassengerMode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryNavy,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Carpool Operations Hub',
                  style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w800),
                ),
                Text(
                  'Live Fleet & Passenger Administration',
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            tooltip: 'Refresh data',
            onPressed: () {
              context.read<CarpoolBloc>().add(const LoadCarpoolRidesEvent(refresh: true));
            },
          ),
          if (onSwitchToPassengerMode != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TextButton.icon(
                onPressed: onSwitchToPassengerMode,
                icon: const Icon(Icons.swap_horiz, size: 18),
                label: const Text('Rider Mode'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  backgroundColor: AppColors.chipBackground,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
        ],
      ),
      body: BlocConsumer<CarpoolBloc, CarpoolState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.successMessage!), backgroundColor: AppColors.success),
            );
          }
        },
        builder: (context, state) {
          final stats = state.adminStats;
          final totalRides = stats['totalRides'] ?? state.allRides.length;
          final activeRides = stats['activeRides'] ?? state.allRides.where((r) => r.status == 'ACTIVE').length;
          final bookedSeats = stats['bookedSeats'] ?? 0;
          final totalRevenue = (stats['totalRevenue'] as num?)?.toDouble() ?? 0.0;
          final occupancyRate = stats['occupancyRate'] ?? 65;

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              context.read<CarpoolBloc>().add(const LoadCarpoolRidesEvent(refresh: true));
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // KPI Stats Grid
                _buildMetricsGrid(
                  totalRides: totalRides,
                  activeRides: activeRides,
                  bookedSeats: bookedSeats,
                  totalRevenue: totalRevenue,
                  occupancyRate: occupancyRate,
                ),
                const SizedBox(height: 20),
                // Carpool Management Table
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Carpool Rides Registry', style: AppTypography.titleLarge),
                        Text(
                          'Monitor routes, verify driver status and manage passenger reservations',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                CarpoolTable(
                  rides: state.allRides,
                  onRideSelected: (ride) {
                    context.push(AppRoutes.rideDetails, extra: ride);
                  },
                  onStatusChanged: (rideId, status) {
                    context.read<CarpoolBloc>().add(
                          UpdateRideStatusEvent(rideId: rideId, status: status),
                        );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricsGrid({
    required int totalRides,
    required int activeRides,
    required int bookedSeats,
    required double totalRevenue,
    required int occupancyRate,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;
        final cardWidth = isNarrow ? (constraints.maxWidth - 12) / 2 : (constraints.maxWidth - 36) / 4;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildStatCard(
              title: 'Total Rides',
              value: '$totalRides',
              subtitle: 'Fleet journeys',
              icon: Icons.directions_car,
              color: AppColors.primary,
              width: cardWidth,
            ),
            _buildStatCard(
              title: 'Active Rides',
              value: '$activeRides',
              subtitle: 'On the road now',
              icon: Icons.route,
              color: AppColors.success,
              width: cardWidth,
            ),
            _buildStatCard(
              title: 'Seats Booked',
              value: '$bookedSeats',
              subtitle: '$occupancyRate% occupancy rate',
              icon: Icons.airline_seat_recline_normal,
              color: AppColors.accentOrange,
              width: cardWidth,
            ),
            _buildStatCard(
              title: 'Platform Volume',
              value: DateFormatter.formatCurrency(totalRevenue),
              subtitle: 'Gross travel spend',
              icon: Icons.payments_outlined,
              color: AppColors.primaryNavy,
              width: cardWidth,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: color),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: AppTypography.titleLarge.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
