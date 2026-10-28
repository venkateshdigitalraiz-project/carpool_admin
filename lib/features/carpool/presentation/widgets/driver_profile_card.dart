import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/carpool_ride.dart';

class DriverProfileCard extends StatelessWidget {
  final DriverProfile driver;
  final RideAmenities amenities;

  const DriverProfileCard({
    super.key,
    required this.driver,
    required this.amenities,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(driver.avatarUrl),
                    onBackgroundImageError: (error, stack) {},
                    child: Text(
                      driver.name.isNotEmpty ? driver.name[0] : 'D',
                      style: AppTypography.titleLarge,
                    ),
                  ),
                  if (driver.isVerified)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, size: 12, color: Colors.white),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(driver.name, style: AppTypography.titleMedium.copyWith(fontSize: 18)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
                        const SizedBox(width: 3),
                        Text(
                          driver.rating.toStringAsFixed(1),
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text('· ${driver.totalReviews} ratings', style: AppTypography.bodySmall),
                      ],
                    ),
                    if (driver.isVerified) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.verified_user, size: 14, color: AppColors.success),
                          const SizedBox(width: 4),
                          Text(
                            'Government ID & Phone Verified',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            driver.bio,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 14),
          // Vehicle Details
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.directions_car, color: AppColors.primaryNavy, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver.carModel,
                      style: AppTypography.titleMedium.copyWith(fontSize: 15),
                    ),
                    Text(
                      '${driver.carColor} · ${driver.plateNumber}',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Amenities and Rules
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildAmenityBadge(
                Icons.bolt,
                amenities.instantBooking ? 'Instant Booking' : 'Request to Book',
                amenities.instantBooking ? AppColors.primary : AppColors.textSecondary,
              ),
              _buildAmenityBadge(
                Icons.smoke_free,
                amenities.smokingAllowed ? 'Smoking Allowed' : 'No Smoking',
                amenities.smokingAllowed ? AppColors.warning : AppColors.success,
              ),
              _buildAmenityBadge(
                Icons.pets,
                amenities.petsAllowed ? 'Pets Allowed' : 'No Pets',
                amenities.petsAllowed ? AppColors.info : AppColors.textSecondary,
              ),
              _buildAmenityBadge(
                Icons.airline_seat_recline_normal,
                amenities.maxTwoInBack ? 'Max 2 in back' : '3 in back',
                AppColors.primaryNavy,
              ),
              _buildAmenityBadge(
                Icons.luggage,
                '${amenities.luggageSize} Luggage',
                AppColors.primaryNavy,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
