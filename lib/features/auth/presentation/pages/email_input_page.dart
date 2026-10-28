import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class EmailInputPage extends StatefulWidget {
  const EmailInputPage({super.key});

  @override
  State<EmailInputPage> createState() => _EmailInputPageState();
}

class _EmailInputPageState extends State<EmailInputPage> {
  final TextEditingController _emailCtrl = TextEditingController();
  bool _optOutMarketing = false;

  bool get _isValidEmail {
    final text = _emailCtrl.text.trim();
    return text.contains('@') && text.contains('.');
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _onNext() {
    if (!_isValidEmail) return;

    context.push(
      AppRoutes.nameInput,
      extra: {
        'email': _emailCtrl.text.trim(),
        'optOutMarketing': _optOutMarketing,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryNavy, size: 24),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Big bold title matching BlaBlaCar Screenshot 1
              Text(
                "What's your email?",
                style: AppTypography.displayLarge.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryNavy,
                ),
              ),
              const SizedBox(height: 24),
              // Email input field
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF2F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  autofocus: true,
                  onChanged: (_) => setState(() {}),
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Checkbox row matching BlaBlaCar Screenshot 1
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _optOutMarketing,
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: const BorderSide(color: AppColors.primaryNavy, width: 1.5),
                      onChanged: (val) {
                        setState(() {
                          _optOutMarketing = val ?? false;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _optOutMarketing = !_optOutMarketing;
                        });
                      },
                      child: Text(
                        "I don't want to receive commercial offers or recommendations from BlaBlaCar by email",
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.primaryNavy,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Subtitle footnote matching BlaBlaCar Screenshot 1
              Padding(
                padding: const EdgeInsets.only(left: 36),
                child: Text(
                  'You can change your preferences at any time from your profile or by clicking the unsubscribe links.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
              const Spacer(),
              // Floating bottom right circle forward button
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: InkWell(
                    onTap: _isValidEmail ? _onNext : null,
                    borderRadius: BorderRadius.circular(28),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _isValidEmail ? AppColors.primary : AppColors.textDisabled.withAlpha(80),
                        shape: BoxShape.circle,
                        boxShadow: _isValidEmail
                            ? const [
                                BoxShadow(
                                  color: Color(0x3300AFF5),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
