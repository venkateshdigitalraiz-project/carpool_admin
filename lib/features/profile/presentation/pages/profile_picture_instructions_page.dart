import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';

/// Screen 1: Profile picture guidelines screen matching Screenshot 1:
/// - Circular photo guidelines preview
/// - "Don't wear sunglasses, look straight ahead and make sure you're alone."
/// - "Take a picture" blue button & "Choose a picture" text button
class ProfilePictureInstructionsPage extends StatelessWidget {
  static const String samplePortraitUrl =
      'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=400';

  const ProfilePictureInstructionsPage({super.key});

  void _onSelectPhoto(BuildContext context, String sourceTitle) {
    // Dispatch photo update event to BLoC
    context.read<ProfileBloc>().add(
          const UpdateProfilePictureEvent(samplePortraitUrl),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$sourceTitle successful! Profile picture updated.'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF0084F4),
            size: 26,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),

              // Circular Sample Portrait matching Screenshot 1
              Center(
                child: Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.network(
                      samplePortraitUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(
                        color: const Color(0xFFD6DFE6),
                        child: const Icon(
                          Icons.person,
                          size: 90,
                          color: Color(0xFF8FA3B0),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // Headline matching Screenshot 1 exactly
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  "Don't wear sunglasses,\nlook straight ahead and\nmake sure you're alone.",
                  style: AppTypography.displayLarge.copyWith(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0A1E34),
                    height: 1.25,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const Spacer(),

              // Primary "Take a picture" Button matching Screenshot 1
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0084F4),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  onPressed: () => _onSelectPhoto(context, 'Take a picture'),
                  child: const Text(
                    'Take a picture',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Secondary "Choose a picture" Button matching Screenshot 1
              SizedBox(
                width: double.infinity,
                height: 44,
                child: TextButton(
                  onPressed: () => _onSelectPhoto(context, 'Choose a picture'),
                  child: const Text(
                    'Choose a picture',
                    style: TextStyle(
                      color: Color(0xFF0084F4),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
