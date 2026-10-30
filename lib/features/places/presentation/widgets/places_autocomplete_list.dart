import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/place_prediction.dart';

class PlacesAutocompleteList extends StatelessWidget {
  final List<PlacePrediction> predictions;
  final bool isLoading;
  final ValueChanged<PlacePrediction> onPlaceSelected;
  final VoidCallback? onClose;

  const PlacesAutocompleteList({
    super.key,
    required this.predictions,
    this.isLoading = false,
    required this.onPlaceSelected,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading && predictions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 6, bottom: 8),
      constraints: const BoxConstraints(maxHeight: 240),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(16),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              const LinearProgressIndicator(
                minHeight: 2.5,
                backgroundColor: AppColors.chipBackground,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            if (predictions.isNotEmpty)
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: predictions.length,
                  separatorBuilder: (_, _) => const Divider(
                    height: 1,
                    indent: 52,
                    endIndent: 16,
                    color: AppColors.borderLight,
                  ),
                  itemBuilder: (context, index) {
                    final place = predictions[index];
                    final subtitle = place.secondaryText.isNotEmpty
                        ? place.secondaryText
                        : (place.fullText != place.mainText
                              ? place.fullText
                              : '');
                    return InkWell(
                      onTap: () => onPlaceSelected(place),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.chipBackground,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.location_on_rounded,
                                size: 17,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    place.mainText,
                                    style: AppTypography.bodyLarge.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (subtitle.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      subtitle,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.north_west_rounded,
                              size: 15,
                              color: AppColors.textTertiary,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
