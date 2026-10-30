import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../domain/entities/dashboard_service_item.dart';
import '../../domain/entities/recent_activity_entry.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/recent_activity_section.dart';
import '../widgets/service_grid_card.dart';
import 'dashboard_home_page.dart';

class DashboardShellPage extends StatefulWidget {
  const DashboardShellPage({super.key});

  @override
  State<DashboardShellPage> createState() => _DashboardShellPageState();
}

class _DashboardShellPageState extends State<DashboardShellPage> {
  int _currentIndex = 0;

  void _onNavigateToCarpool() {
    // Navigate to the full Carpool module (MainNavigationShell with its own tabs)
    // Using push ensures Carpool displays its own navigator without any overlap.
    context.push(AppRoutes.carpool);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      DashboardHomePage(
        onOpenCarpool: _onNavigateToCarpool,
        onOpenActiveRide: _onNavigateToCarpool,
        onSeeAllActivity: () {
          setState(() {
            _currentIndex = 2; // Jump to Activity tab
          });
        },
      ),
      // Services tab: displays all services via DashboardBloc
      _buildServicesTab(),
      // Activity tab: unified history via DashboardBloc
      _buildActivityTab(),
      // Account / Profile tab: using existing ProfilePage
      ProfilePage(
        onOpenAdminDashboard: () {
          context.push(AppRoutes.adminDashboard);
        },
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(color: Color(0xFFE2E8F0), width: 0.8),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_rounded,
                  label: 'Home',
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.directions_car_outlined,
                  label: 'Services',
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.access_time_rounded,
                  label: 'Activity',
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.person_outline_rounded,
                  label: 'Account',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;
    const activeColor = Color(0xFF0070E0);
    const inactiveColor = Color(0xFF64748B);

    return InkWell(
      onTap: () {
        // Switch tab cleanly without auto-opening Carpool
        setState(() {
          _currentIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
            const SizedBox(height: 3),
            // Bottom Indicator Bar matching screenshot under active tab
            Container(
              width: 36,
              height: 3,
              decoration: BoxDecoration(
                color: isSelected ? activeColor : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesTab() {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFD),
      appBar: AppBar(
        title: const Text(
          'All Services',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          final services = state.data?.services ?? [];
          if (services.isEmpty && state.status == DashboardStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Explore available services & mobility options',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.54,
                  ),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final service = services[index];
                    return ServiceGridCard(
                      service: service,
                      onTap: () {
                        if (service.type == DashboardServiceType.carpool) {
                          _onNavigateToCarpool();
                        } else {
                          _showComingSoonDialog(context, service.title);
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActivityTab() {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFD),
      appBar: AppBar(
        title: const Text(
          'Activity History',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          final activities = state.data?.recentActivities ?? [];
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: RecentActivitySection(
              activities: activities,
              onSeeAll: () {},
              onActivityTap: (activity) {
                if (activity.type == ActivityType.carpool) {
                  _onNavigateToCarpool();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '${activity.title} (${activity.subtitle}) details'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String serviceName) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.rocket_launch_rounded, color: Color(0xFF0070E0)),
            const SizedBox(width: 8),
            Text('$serviceName Module'),
          ],
        ),
        content: Text(
          '$serviceName service is currently being integrated and will be available soon.',
          style: const TextStyle(color: Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
