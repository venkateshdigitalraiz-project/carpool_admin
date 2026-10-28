import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/carpool_ride.dart';

class RouteTimeline extends StatelessWidget {
  final CarpoolRide ride;
  final bool compact;

  const RouteTimeline({
    super.key,
    required this.ride,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompactView();
    }
    return _buildExpandedView();
  }

  Widget _buildCompactView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Times
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormatter.formatTime(ride.departureTime),
              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 18),
            Text(
              DateFormatter.formatDuration(ride.durationMinutes),
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),
            Text(
              DateFormatter.formatTime(ride.arrivalTime),
              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(width: 14),
        // Dots and connecting line
        Column(
          children: [
            const SizedBox(height: 6),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 3),
                color: AppColors.surface,
              ),
            ),
            Container(
              width: 2,
              height: 48,
              color: AppColors.primary.withAlpha(100),
            ),
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryNavy,
              ),
            ),
          ],
        ),
        const SizedBox(width: 14),
        // Locations
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ride.origin,
                style: AppTypography.titleMedium.copyWith(fontSize: 15),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                ride.originAddress,
                style: AppTypography.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 22),
              Text(
                ride.destination,
                style: AppTypography.titleMedium.copyWith(fontSize: 15),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                ride.destinationAddress,
                style: AppTypography.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedView() {
    return Column(
      children: [
        // Departure point
        _buildTimelineStep(
          time: DateFormatter.formatTime(ride.departureTime),
          city: ride.origin,
          address: ride.originAddress,
          isStart: true,
          isEnd: false,
        ),
        // Intermediate stops (if any)
        if (ride.intermediateStops.isNotEmpty)
          ...ride.intermediateStops.map(
            (stop) => _buildIntermediateStep(stop),
          ),
        // Arrival point
        _buildTimelineStep(
          time: DateFormatter.formatTime(ride.arrivalTime),
          city: ride.destination,
          address: ride.destinationAddress,
          isStart: false,
          isEnd: true,
        ),
      ],
    );
  }

  Widget _buildTimelineStep({
    required String time,
    required String city,
    required String address,
    required bool isStart,
    required bool isEnd,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            time,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isStart ? AppColors.primary : AppColors.primaryNavy,
                  width: 3.5,
                ),
                color: isStart ? AppColors.surface : AppColors.primaryNavy,
              ),
            ),
            if (!isEnd)
              Container(
                width: 2.5,
                height: 52,
                color: AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                city,
                style: AppTypography.titleMedium.copyWith(fontSize: 16),
              ),
              Text(
                address,
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIntermediateStep(String stop) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 70),
        Column(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.textTertiary,
              ),
            ),
            Container(
              width: 2.5,
              height: 40,
              color: AppColors.border,
            ),
          ],
        ),
        const SizedBox(width: 17),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Via $stop',
                style: AppTypography.bodySmall.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}
