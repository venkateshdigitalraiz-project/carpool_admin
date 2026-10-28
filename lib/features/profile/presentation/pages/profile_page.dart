import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../domain/entities/profile_entity.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import 'profile_picture_instructions_page.dart';

/// Screen 2: Modern Clean Profile Page matching Screenshot 2:
/// - "About you" and "Account" tabs
/// - User profile header ("Venkatesh", "Newcomer", avatar)
/// - "Complete your profile" 1/6 progress card with segmented progress bar
/// - "Add profile picture" action navigating to Screenshot 1
/// - "Edit personal details"
/// - "Verify your profile" list (Govt ID, email, phone)
/// - "Your carpooling reliability" badge
class ProfilePage extends StatefulWidget {
  final VoidCallback onOpenAdminDashboard;

  const ProfilePage({
    super.key,
    required this.onOpenAdminDashboard,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<ProfileBloc>().add(LoadProfileEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onOpenPictureGuidelines() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfilePictureInstructionsPage(),
      ),
    );
  }

  void _showEditPersonalDetailsModal(String currentName, String currentEmail) {
    final nameCtrl = TextEditingController(text: currentName);
    final emailCtrl = TextEditingController(text: currentEmail);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6DFE6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Edit personal details',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0A1E34),
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: emailCtrl,
              decoration: InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0084F4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  final email = emailCtrl.text.trim();
                  if (name.isNotEmpty && email.isNotEmpty) {
                    context.read<ProfileBloc>().add(
                          UpdatePersonalDetailsEvent(name: name, email: email),
                        );
                    Navigator.pop(ctx);
                  }
                },
                child: const Text(
                  'Save Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGovtIdVerificationModal() {
    final idCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6DFE6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Verify your Govt. ID',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0A1E34),
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your Aadhaar, Passport, or Driving License number to earn the verified trust badge.',
              style: AppTypography.bodySmall.copyWith(
                color: const Color(0xFF718096),
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: idCtrl,
              decoration: InputDecoration(
                labelText: 'Govt. ID Number',
                hintText: 'e.g. ABCD1234E',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0084F4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () {
                  if (idCtrl.text.trim().isNotEmpty) {
                    context.read<ProfileBloc>().add(
                          VerifyGovtIdEvent(idCtrl.text.trim()),
                        );
                    Navigator.pop(ctx);
                  }
                },
                child: const Text(
                  'Submit for Verification',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, profileState) {
        final profile = profileState.profile;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            toolbarHeight: 0,
            bottom: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF0084F4),
              unselectedLabelColor: const Color(0xFF718096),
              indicatorColor: const Color(0xFF0084F4),
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
              tabs: const [
                Tab(text: 'About you'),
                Tab(text: 'Account'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildAboutYouTab(profile),
              _buildAccountTab(profile),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAboutYouTab(dynamic profile) {
    final int completed = profile.completedSteps;
    final int total = profile.totalSteps;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      children: [
        // 1. User Profile Header matching Screenshot 2
        InkWell(
          onTap: _onOpenPictureGuidelines,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                // Avatar (Image or Silhouette Placeholder)
                Container(
                  width: 76,
                  height: 76,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE2E8F0),
                    shape: BoxShape.circle,
                  ),
                  child: profile.avatarUrl != null
                      ? ClipOval(
                          child: Image.network(
                            profile.avatarUrl!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          size: 52,
                          color: Color(0xFFCBD5E1),
                        ),
                ),
                const SizedBox(width: 16),

                // Name & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        style: AppTypography.displayLarge.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0A1E34),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        profile.subtitle,
                        style: const TextStyle(
                          color: Color(0xFF718096),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Chevron Right
                const Icon(
                  Icons.chevron_right,
                  size: 26,
                  color: Color(0xFF0A1E34),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // 2. "Complete your profile" Card matching Screenshot 2
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFEBF5FB),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Complete your profile',
                style: AppTypography.titleLarge.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0A1E34),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'This helps builds trust, encouraging members to travel with you.',
                style: TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 13.5,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),

              // Progress Text (e.g. "1 out of 6 complete")
              Text(
                '$completed out of $total complete',
                style: const TextStyle(
                  color: Color(0xFF0A1E34),
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),

              // 6-Segment Progress Bar matching Screenshot 2
              Row(
                children: List.generate(total, (index) {
                  final isDone = index < completed;
                  return Expanded(
                    child: Container(
                      height: 4.5,
                      margin: EdgeInsets.only(
                        right: index < total - 1 ? 4 : 0,
                      ),
                      decoration: BoxDecoration(
                        color: isDone
                            ? const Color(0xFF0084F4)
                            : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // "Add profile picture" Action Link matching Screenshot 2
              InkWell(
                onTap: _onOpenPictureGuidelines,
                child: Text(
                  profile.avatarUrl == null
                      ? 'Add profile picture'
                      : 'Update profile picture',
                  style: const TextStyle(
                    color: Color(0xFF0084F4),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 3. "Edit personal details" link matching Screenshot 2
        InkWell(
          onTap: () => _showEditPersonalDetailsModal(
            profile.name,
            profile.email,
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Text(
              'Edit personal details',
              style: TextStyle(
                color: Color(0xFF0084F4),
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),

        const SizedBox(height: 14),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),
        const SizedBox(height: 20),

        // 4. "Verify your profile" Section matching Screenshot 2
        Text(
          'Verify your profile',
          style: AppTypography.titleLarge.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0A1E34),
          ),
        ),
        const SizedBox(height: 14),

        // Item 1: Verify your Govt. ID
        InkWell(
          onTap: profile.isGovtIdVerified
              ? null
              : _showGovtIdVerificationModal,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(
                  profile.isGovtIdVerified
                      ? Icons.check_circle
                      : Icons.add_circle_outline,
                  color: const Color(0xFF0084F4),
                  size: 24,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    profile.isGovtIdVerified
                        ? 'Govt. ID verified'
                        : 'Verify your Govt. ID',
                    style: const TextStyle(
                      color: Color(0xFF0084F4),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 6),

        // Item 2: Confirm email
        InkWell(
          onTap: profile.isEmailConfirmed
              ? null
              : () => context.read<ProfileBloc>().add(ConfirmEmailEvent()),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  profile.isEmailConfirmed
                      ? Icons.check_circle
                      : Icons.add_circle_outline,
                  color: const Color(0xFF0084F4),
                  size: 24,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.isEmailConfirmed
                            ? 'Email confirmed'
                            : 'Confirm email',
                        style: const TextStyle(
                          color: Color(0xFF0084F4),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        profile.email,
                        style: const TextStyle(
                          color: Color(0xFF0A1E34),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 6),

        // Item 3: Phone number verified (+919052575626) matching Screenshot 2
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFF0084F4),
                size: 24,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  profile.phoneNumber,
                  style: const TextStyle(
                    color: Color(0xFF0A1E34),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),
        const SizedBox(height: 20),

        // 5. "Your carpooling reliability" Section matching Screenshot 2
        Text(
          'Your carpooling reliability',
          style: AppTypography.titleLarge.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0A1E34),
          ),
        ),
        const SizedBox(height: 14),

        Row(
          children: [
            const Icon(
              Icons.event_available_outlined,
              color: Color(0xFF16A34A),
              size: 24,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                profile.reliabilityBadge,
                style: const TextStyle(
                  color: Color(0xFF0A1E34),
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 28),

        // Admin Operations Fleet Card
        InkWell(
          onTap: widget.onOpenAdminDashboard,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF054752), Color(0xFF00AFF5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.table_chart, color: Colors.white, size: 26),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Carpool Admin Operations Hub',
                        style: AppTypography.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Manage bookings, drivers & system logs',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildAccountTab(ProfileEntity profile) {
    return ListView(
      padding: const EdgeInsets.only(top: 4, bottom: 40),
      children: [
        // 1. Ratings
        _buildAccountRow(
          title: 'Ratings',
          onTap: () => _showRatingsModal(profile),
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFE5ECEF)),

        // 2. Saved passengers
        _buildAccountRow(
          title: 'Saved passengers',
          onTap: () => _showSavedPassengersModal(profile),
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFE5ECEF)),

        // 3. Help
        _buildAccountRow(
          title: 'Help',
          onTap: _showHelpModal,
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFE5ECEF)),

        // 4. Communication preferences
        _buildAccountRow(
          title: 'Communication preferences',
          onTap: () => _showCommunicationPreferencesModal(profile),
        ),

        // 5. Password
        _buildAccountRow(
          title: 'Password',
          onTap: _showPasswordModal,
        ),

        // 6. Postal address
        _buildAccountRow(
          title: 'Postal address',
          onTap: () => _showPostalAddressModal(profile),
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFE5ECEF)),

        // 7. Payout methods
        _buildAccountRow(
          title: 'Payout methods',
          onTap: () => _showPayoutMethodsModal(profile),
        ),

        // 8. Payouts
        _buildAccountRow(
          title: 'Payouts',
          onTap: _showPayoutsModal,
        ),

        // 9. Payment methods
        _buildAccountRow(
          title: 'Payment methods',
          onTap: () => _showPaymentMethodsModal(profile),
        ),

        // 10. Payments & refunds
        _buildAccountRow(
          title: 'Payments & refunds',
          onTap: _showPaymentsAndRefundsModal,
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFE5ECEF)),

        // 11. Terms and Conditions
        _buildAccountRow(
          title: 'Terms and Conditions',
          onTap: _showTermsModal,
        ),

        // 12. Data protection
        _buildAccountRow(
          title: 'Data protection',
          onTap: _showDataProtectionModal,
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFE5ECEF)),

        // 13. Log out (Left aligned blue text, no chevron, matching screenshot)
        InkWell(
          onTap: _showLogoutConfirmationDialog,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 17),
            child: Row(
              children: [
                Text(
                  'Log out',
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0084F4),
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFE5ECEF)),
      ],
    );
  }

  Widget _buildAccountRow({
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0A1E34),
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF708090),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  void _showRatingsModal(ProfileEntity profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6DFE6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Ratings & Reviews',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0A1E34),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.star, color: Color(0xFFFFA41C), size: 28),
                const SizedBox(width: 8),
                Text(
                  profile.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0A1E34),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${profile.reviewsCount} ratings)',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF708090),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'You have no ratings left yet. Complete trips as a passenger or driver to receive ratings from other verified carpoolers.',
              style: TextStyle(
                fontSize: 14.5,
                color: Color(0xFF5A6E85),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSavedPassengersModal(ProfileEntity profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6DFE6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Saved passengers',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0A1E34),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Easily book seats for friends or family members when you travel together.',
              style: TextStyle(
                fontSize: 14.5,
                color: Color(0xFF5A6E85),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0084F4),
                side: const BorderSide(color: Color(0xFF0084F4)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
              icon: const Icon(Icons.add),
              label: const Text(
                'Add a co-traveler',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Co-traveler feature is ready for booking.'),
                    backgroundColor: Color(0xFF0084F4),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6DFE6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Help & Support Center',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0A1E34),
              ),
            ),
            const SizedBox(height: 18),
            _buildHelpTopicTile('How carpooling rides work'),
            _buildHelpTopicTile('Pricing, payments and cancellation policy'),
            _buildHelpTopicTile('Trust, safety and insurance cover'),
            _buildHelpTopicTile('Contact BlaBlaCar 24/7 Support'),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpTopicTile(String title) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0A1E34),
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF708090), size: 20),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title opened.'),
            backgroundColor: const Color(0xFF0084F4),
          ),
        );
      },
    );
  }

  void _showCommunicationPreferencesModal(ProfileEntity profile) {
    bool push = profile.pushNotifications;
    bool email = profile.emailNotifications;
    bool sms = profile.smsNotifications;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6DFE6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Communication preferences',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0A1E34),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose how BlaBlaCar contacts you about rides and updates.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF5A6E85),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: const Color(0xFF0084F4),
                title: const Text(
                  'Push notifications',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: const Text('Trip reminders, booking requests & messages'),
                value: push,
                onChanged: (val) {
                  setModalState(() => push = val);
                  context.read<ProfileBloc>().add(
                        UpdateCommunicationPreferencesEvent(
                          push: push,
                          email: email,
                          sms: sms,
                        ),
                      );
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: const Color(0xFF0084F4),
                title: const Text(
                  'Email updates',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: const Text('Receipts, booking confirmations & news'),
                value: email,
                onChanged: (val) {
                  setModalState(() => email = val);
                  context.read<ProfileBloc>().add(
                        UpdateCommunicationPreferencesEvent(
                          push: push,
                          email: email,
                          sms: sms,
                        ),
                      );
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: const Color(0xFF0084F4),
                title: const Text(
                  'SMS text messages',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: const Text('Urgent alerts when offline or on the road'),
                value: sms,
                onChanged: (val) {
                  setModalState(() => sms = val);
                  context.read<ProfileBloc>().add(
                        UpdateCommunicationPreferencesEvent(
                          push: push,
                          email: email,
                          sms: sms,
                        ),
                      );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPasswordModal() {
    final curCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6DFE6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Change password',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0A1E34),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: curCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Current password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: newCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: confCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm new password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0084F4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () {
                  if (newCtrl.text.isEmpty || newCtrl.text != confCtrl.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Passwords do not match or are invalid.'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password updated successfully!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                child: const Text(
                  'Update password',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPostalAddressModal(ProfileEntity profile) {
    final addrCtrl = TextEditingController(text: profile.postalAddress);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6DFE6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Postal address',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0A1E34),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your residential address for verified billing and driver documentation.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF5A6E85),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: addrCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Street address & Postal code',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0084F4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () {
                  context.read<ProfileBloc>().add(
                        UpdatePostalAddressEvent(addrCtrl.text.trim()),
                      );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Postal address saved!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                child: const Text(
                  'Save address',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPayoutMethodsModal(ProfileEntity profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6DFE6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Payout methods',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0A1E34),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Where passenger contributions are transferred after completed rides.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF5A6E85),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance, color: Color(0xFF0084F4), size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.payoutMethod,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Color(0xFF0A1E34),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Primary payout account',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF708090),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPayoutsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6DFE6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Payouts history',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0A1E34),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No payouts processed yet. Once you publish a ride and passengers book seats, payouts appear here.',
              style: TextStyle(
                fontSize: 14.5,
                color: Color(0xFF5A6E85),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentMethodsModal(ProfileEntity profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6DFE6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Payment methods',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0A1E34),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.payment, color: Color(0xFF0084F4), size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.paymentMethod,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Color(0xFF0A1E34),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Primary payment method',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF708090),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentsAndRefundsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6DFE6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Payments & refunds',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0A1E34),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No past payment transactions or active refunds to display. Receipts for completed bookings will be logged here.',
              style: TextStyle(
                fontSize: 14.5,
                color: Color(0xFF5A6E85),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTermsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6DFE6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Terms and Conditions',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0A1E34),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'By using BlaBlaCar carpool services, you agree to our general terms of service, passenger safety regulations, driver etiquette requirements, and community code of conduct.',
              style: TextStyle(
                fontSize: 14.5,
                color: Color(0xFF5A6E85),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDataProtectionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6DFE6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Data protection & Privacy',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0A1E34),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'We safeguard your personal data with enterprise-grade encryption. We never share your phone number or financial details without your explicit consent.',
              style: TextStyle(
                fontSize: 14.5,
                color: Color(0xFF5A6E85),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Log out',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF0A1E34),
          ),
        ),
        content: const Text(
          'Are you sure you want to log out of your BlaBlaCar account?',
          style: TextStyle(
            color: Color(0xFF5A6E85),
            fontSize: 15,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFF708090),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(LogoutEvent());
            },
            child: const Text(
              'Log out',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
