import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/widgets/survey_home_exchange_dialog.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback onOpenAdminDashboard;

  const ProfilePage({
    super.key,
    required this.onOpenAdminDashboard,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        // Name from screenshot 5 is "Vankatesh", fallback to authenticated user name
        final userName = authState.user?.fullName.isNotEmpty == true
            ? authState.user!.fullName
            : 'Vankatesh';

        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            bottom: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF00AFF5),
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: const Color(0xFF00AFF5),
              indicatorWeight: 3,
              labelStyle: AppTypography.titleMedium.copyWith(
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
              _buildAboutYouTab(userName),
              _buildAccountTab(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAboutYouTab(String userName) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        // User profile row matching BlaBlaCar Screenshot 5
        Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFD6DFE6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                size: 48,
                color: Color(0xFF8FA3B0),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: AppTypography.displayLarge.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        'Newcomer',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Home exchange survey promo banner (triggers Screenshot 4 & 5 modal)
        InkWell(
          onTap: () => SurveyHomeExchangeDialog.show(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F7FB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withAlpha(60)),
            ),
            child: Row(
              children: [
                const Icon(Icons.home_work_outlined, color: AppColors.primary, size: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Peer-to-peer home exchange survey',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.primaryNavy,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Would you swap homes on a trip? Tap to answer.',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.primary),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Section: Your carpooling reliability matching Screenshot 5
        Text(
          'Your carpooling reliability',
          style: AppTypography.titleLarge.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryNavy,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F6EE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.event_available,
                color: Color(0xFF1B8A5A),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Never cancels bookings as a passenger',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.primaryNavy,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        // Section: Verifications
        Text(
          'Verify your profile',
          style: AppTypography.titleLarge.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryNavy,
          ),
        ),
        const SizedBox(height: 12),
        _buildVerificationTile(
          icon: Icons.add_circle_outline,
          title: 'Verify your ID',
          onTap: () {},
        ),
        _buildVerificationTile(
          icon: Icons.check_circle,
          iconColor: AppColors.success,
          title: 'Phone number verified',
          isVerified: true,
          onTap: () {},
        ),
        _buildVerificationTile(
          icon: Icons.check_circle,
          iconColor: AppColors.success,
          title: 'Email address verified',
          isVerified: true,
          onTap: () {},
        ),
        const SizedBox(height: 24),
        // Section: Vehicle Info
        Text(
          'Vehicles',
          style: AppTypography.titleLarge.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryNavy,
          ),
        ),
        const SizedBox(height: 12),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F3F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.directions_car, color: AppColors.primaryNavy),
          ),
          title: Text('Toyota Prius (Silver)', style: AppTypography.titleMedium.copyWith(fontSize: 15)),
          subtitle: Text('Plate: ABC-1234', style: AppTypography.bodySmall),
          trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
        ),
        const SizedBox(height: 28),
        // Admin Operations Hub Launch Card
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
                const Icon(Icons.table_chart, color: Colors.white, size: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Carpool Admin Table & Fleet',
                        style: AppTypography.titleMedium.copyWith(color: Colors.white),
                      ),
                      Text(
                        'View all driver bookings & manage rides',
                        style: AppTypography.bodySmall.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildAccountTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ListTile(
          leading: const Icon(Icons.payment, color: AppColors.primaryNavy),
          title: Text('Payment & Refunds', style: AppTypography.titleMedium.copyWith(fontSize: 15)),
          subtitle: const Text('Bank account, cards, and payouts'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.security, color: AppColors.primaryNavy),
          title: Text('Password & Security', style: AppTypography.titleMedium.copyWith(fontSize: 15)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.notifications_none, color: AppColors.primaryNavy),
          title: Text('Communications & Notifications', style: AppTypography.titleMedium.copyWith(fontSize: 15)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.help_outline, color: AppColors.primaryNavy),
          title: Text('Help & Support', style: AppTypography.titleMedium.copyWith(fontSize: 15)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        const SizedBox(height: 32),
        // Log out button to return to first-time welcome screen
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: const BorderSide(color: AppColors.error),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.logout),
          label: const Text('Log out of BlaBlaCar'),
          onPressed: () {
            context.read<AuthBloc>().add(LogoutEvent());
          },
        ),
      ],
    );
  }

  Widget _buildVerificationTile({
    required IconData icon,
    required String title,
    Color? iconColor,
    bool isVerified = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: iconColor ?? AppColors.primary, size: 22),
      title: Text(
        title,
        style: AppTypography.bodyLarge.copyWith(
          color: isVerified ? AppColors.textPrimary : AppColors.primary,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      trailing: isVerified ? null : const Icon(Icons.chevron_right, color: AppColors.textTertiary),
      onTap: isVerified ? null : onTap,
    );
  }
}
