import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/dashboard_service_item.dart';
import '../../domain/entities/recent_activity_entry.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/active_ride_card.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/recent_activity_section.dart';
import '../widgets/service_grid_card.dart';

class DashboardHomePage extends StatelessWidget {
  final VoidCallback onOpenCarpool;
  final VoidCallback? onOpenActiveRide;
  final VoidCallback? onSeeAllActivity;

  const DashboardHomePage({
    super.key,
    required this.onOpenCarpool,
    this.onOpenActiveRide,
    this.onSeeAllActivity,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFD),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          final data = state.data;
          if (data == null && state.status == DashboardStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (data == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Failed to load dashboard data'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<DashboardBloc>().add(
                      const LoadDashboardDataEvent(),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<DashboardBloc>().add(
                const RefreshDashboardDataEvent(),
              );
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header (Charminar background + Location + Greeting)
                  DashboardHeader(
                    userName: data.userName,
                    locationCity: data.locationCity,
                    unreadNotifications: data.unreadNotificationsCount,
                    onLocationTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Current city: Hyderabad'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    onNotificationTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'You have ${data.unreadNotificationsCount} notifications',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),

                  // 2. Services Grid (2x3)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            childAspectRatio: 1.8,
                          ),
                      itemCount: data.services.length,
                      itemBuilder: (context, index) {
                        final service = data.services[index];
                        return ServiceGridCard(
                          service: service,
                          onTap: () {
                            if (service.type == DashboardServiceType.carpool) {
                              onOpenCarpool();
                            } else {
                              _showServiceComingSoonDialog(
                                context,
                                service.title,
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 3. Active Ride Banner
                  if (data.activeRide != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ActiveRideCard(
                        banner: data.activeRide!,
                        onViewDetails: () {
                          if (onOpenActiveRide != null) {
                            onOpenActiveRide!();
                          } else {
                            onOpenCarpool();
                          }
                        },
                      ),
                    ),

                  const SizedBox(height: 20),

                  // 4. Recent Activity
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: RecentActivitySection(
                      activities: data.recentActivities,
                      onSeeAll: () {
                        onSeeAllActivity?.call();
                      },
                      onActivityTap: (activity) {
                        if (activity.type == ActivityType.carpool) {
                          onOpenCarpool();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${activity.title} (${activity.subtitle}) details',
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showServiceComingSoonDialog(BuildContext context, String serviceName) {
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
