import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

class SurveyHomeExchangeDialog extends StatefulWidget {
  final VoidCallback? onCompleted;

  const SurveyHomeExchangeDialog({super.key, this.onCompleted});

  static Future<void> show(BuildContext context, {VoidCallback? onCompleted}) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(120),
      builder: (_) => SurveyHomeExchangeDialog(onCompleted: onCompleted),
    );
  }

  @override
  State<SurveyHomeExchangeDialog> createState() => _SurveyHomeExchangeDialogState();
}

class _SurveyHomeExchangeDialogState extends State<SurveyHomeExchangeDialog> {
  String _selectedOption = 'No';

  final List<String> _options = [
    "Yes, I've already done it",
    "Yes, I could be interested",
    "No",
    "I don't know",
  ];

  void _onConfirm() {
    context.read<AuthBloc>().add(SaveHomeExchangePreferenceEvent(_selectedOption));
    context.pop();
    widget.onCompleted?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Close 'X' Button at top right
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.close, color: AppColors.primaryNavy, size: 22),
                onPressed: () => context.pop(),
              ),
            ),
            const SizedBox(height: 4),
            // Title matching BlaBlaCar Screenshot 4 & 5
            Text(
              'Would you consider a peer-to-peer home exchange for an upcoming trip?',
              style: AppTypography.titleLarge.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryNavy,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 12),
            // Explanatory footnote matching Screenshot 4 & 5
            Text(
              '*Home exchange is a way to go on holiday where two people or families agree to swap their homes for a set period of time.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 16),
            // Radio options list matching Screenshot 4 & 5
            ..._options.map((option) {
              final isSelected = _selectedOption == option;
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedOption = option;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF00AFF5),
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Center(
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF00AFF5),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          option,
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.primaryNavy,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
            // Bottom Right Forward Action Arrow Button matching Screenshot 4 & 5
            Align(
              alignment: Alignment.bottomRight,
              child: InkWell(
                onTap: _onConfirm,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
