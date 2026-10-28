import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

class SurveyHolidayDialog extends StatefulWidget {
  final VoidCallback? onCompleted;

  const SurveyHolidayDialog({super.key, this.onCompleted});

  static Future<void> show(BuildContext context, {VoidCallback? onCompleted}) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(120),
      builder: (_) => SurveyHolidayDialog(onCompleted: onCompleted),
    );
  }

  @override
  State<SurveyHolidayDialog> createState() => _SurveyHolidayDialogState();
}

class _SurveyHolidayDialogState extends State<SurveyHolidayDialog> {
  final Set<String> _selected = {};

  final List<String> _options = [
    'As a couple',
    'With friends',
    'Alone',
    'With family (with children)',
    'With a pet',
  ];

  bool get _hasSelection => _selected.isNotEmpty;

  void _onConfirm() {
    if (!_hasSelection) return;

    context.read<AuthBloc>().add(SaveHolidayPreferencesEvent(_selected.toList()));
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
            // Title matching BlaBlaCar Screenshot 3
            Text(
              'Who do you usually go on holiday with?',
              style: AppTypography.titleLarge.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryNavy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '(Multiple answers possible)',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            // Options list with checkboxes
            ..._options.map((option) {
              final isChecked = _selected.contains(option);
              return InkWell(
                onTap: () {
                  setState(() {
                    if (isChecked) {
                      _selected.remove(option);
                    } else {
                      _selected.add(option);
                    }
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
                          color: isChecked ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isChecked ? AppColors.primary : const Color(0xFF00AFF5),
                            width: 2,
                          ),
                        ),
                        child: isChecked
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
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
            // Bottom Right Forward Action Arrow Button matching Screenshot 3
            Align(
              alignment: Alignment.bottomRight,
              child: InkWell(
                onTap: _hasSelection ? _onConfirm : null,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _hasSelection ? AppColors.primary : const Color(0xFFCFD8DC),
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
