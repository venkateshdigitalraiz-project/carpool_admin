import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/route_option.dart';

/// Single selectable route item matching the attached screenshot:
/// - Custom radio button indicator
/// - Bold duration and Toll badge ("7 hr 40 min - Tolls")
/// - Distance and highway summary ("415 km - Greenfield Hwy/Khammam - Devarapalli Expy")
class RouteOptionCard extends StatelessWidget {
  final RouteOption route;
  final bool isSelected;
  final VoidCallback onTap;

  const RouteOptionCard({
    super.key,
    required this.route,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: AppColors.primary.withAlpha(20),
      highlightColor: AppColors.primary.withAlpha(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom Radio Button matching screenshot
            Padding(
              padding: const EdgeInsets.only(top: 2, right: 16),
              child: _buildRadioButton(),
            ),

            // Route Details Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top Line: "7 hr 40 min - Tolls"
                  Text(
                    route.title,
                    style: AppTypography.titleMedium.copyWith(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0A1E34),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Bottom Line: "415 km - Greenfield Hwy/Khammam - Devarapalli Expy"
                  Text(
                    route.subtitle,
                    style: AppTypography.bodyMedium.copyWith(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF5E7A8A),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioButton() {
    if (isSelected) {
      // Selected: outer blue circle, white ring, inner blue dot
      return Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF0070E0), width: 2.2),
        ),
        alignment: Alignment.center,
        child: Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF0070E0),
          ),
        ),
      );
    } else {
      // Unselected: blue outline circle matching screenshot
      return Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF0070E0), width: 2.0),
        ),
      );
    }
  }
}
