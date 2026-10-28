import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/custom_button.dart';

class RideFilterSheet extends StatefulWidget {
  final double currentMaxPrice;
  final bool currentInstantBooking;
  final bool currentVerifiedOnly;
  final String currentSortBy;
  final Function({
    double? maxPrice,
    bool? instantBooking,
    bool? verifiedOnly,
    String? sortBy,
  }) onApply;

  const RideFilterSheet({
    super.key,
    required this.currentMaxPrice,
    required this.currentInstantBooking,
    required this.currentVerifiedOnly,
    required this.currentSortBy,
    required this.onApply,
  });

  @override
  State<RideFilterSheet> createState() => _RideFilterSheetState();
}

class _RideFilterSheetState extends State<RideFilterSheet> {
  late double _maxPrice;
  late bool _instantBooking;
  late bool _verifiedOnly;
  late String _sortBy;

  @override
  void initState() {
    super.initState();
    _maxPrice = widget.currentMaxPrice;
    _instantBooking = widget.currentInstantBooking;
    _verifiedOnly = widget.currentVerifiedOnly;
    _sortBy = widget.currentSortBy;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filter & Sort Rides', style: AppTypography.titleLarge),
              TextButton(
                onPressed: () {
                  setState(() {
                    _maxPrice = 50.0;
                    _instantBooking = false;
                    _verifiedOnly = false;
                    _sortBy = 'earliest';
                  });
                },
                child: Text('Reset', style: AppTypography.titleMedium.copyWith(color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Sort By', style: AppTypography.titleMedium.copyWith(fontSize: 14)),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildSortChip('earliest', 'Earliest Departure'),
              const SizedBox(width: 8),
              _buildSortChip('cheapest', 'Lowest Price'),
              const SizedBox(width: 8),
              _buildSortChip('shortest', 'Shortest Ride'),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Max Price per Seat', style: AppTypography.titleMedium.copyWith(fontSize: 14)),
              Text(
                '₹${_maxPrice.toInt()}',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Slider(
            value: _maxPrice,
            min: 5.0,
            max: 50.0,
            divisions: 9,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.border,
            onChanged: (val) {
              setState(() {
                _maxPrice = val;
              });
            },
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Instant Booking only', style: AppTypography.titleMedium.copyWith(fontSize: 15)),
            subtitle: Text('Book without waiting for driver confirmation', style: AppTypography.bodySmall),
            value: _instantBooking,
            activeThumbColor: AppColors.primary,
            onChanged: (val) {
              setState(() {
                _instantBooking = val;
              });
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Verified Drivers only', style: AppTypography.titleMedium.copyWith(fontSize: 15)),
            subtitle: Text('Travel with drivers who have verified Government ID', style: AppTypography.bodySmall),
            value: _verifiedOnly,
            activeThumbColor: AppColors.primary,
            onChanged: (val) {
              setState(() {
                _verifiedOnly = val;
              });
            },
          ),
          const SizedBox(height: 20),
          CustomButton(
            text: 'Apply Filters',
            onPressed: () {
              widget.onApply(
                maxPrice: _maxPrice,
                instantBooking: _instantBooking,
                verifiedOnly: _verifiedOnly,
                sortBy: _sortBy,
              );
              context.pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String key, String label) {
    final isSelected = _sortBy == key;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _sortBy = key;
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.inputFill,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
