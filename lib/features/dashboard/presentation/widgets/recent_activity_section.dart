import 'package:flutter/material.dart';
import '../../domain/entities/recent_activity_entry.dart';

class RecentActivitySection extends StatelessWidget {
  final List<RecentActivityEntry> activities;
  final VoidCallback onSeeAll;
  final ValueChanged<RecentActivityEntry>? onActivityTap;

  const RecentActivitySection({
    super.key,
    required this.activities,
    required this.onSeeAll,
    this.onActivityTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title & See All
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
            InkWell(
              onTap: onSeeAll,
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'See All',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0070E0),
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: Color(0xFF0070E0),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // List of Activity Cards
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: activities.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = activities[index];
            return _buildActivityCard(context, item);
          },
        ),
      ],
    );
  }

  Widget _buildActivityCard(BuildContext context, RecentActivityEntry item) {
    final isCarpool = item.type == ActivityType.carpool;

    final Color iconBgColor =
        isCarpool ? const Color(0xFFEFF6FF) : const Color(0xFFFFF7ED);
    final Color iconColor =
        isCarpool ? const Color(0xFF2563EB) : const Color(0xFFEA580C);
    final IconData icon =
        isCarpool ? Icons.directions_car_rounded : Icons.inventory_2_rounded;

    return InkWell(
      onTap: () => onActivityTap?.call(item),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withAlpha(8),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconBgColor,
              ),
              child: Icon(
                icon,
                size: 22,
                color: iconColor,
              ),
            ),

            const SizedBox(width: 12),

            // Title & Timestamp
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.timestampText,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),

            // Status Badge & Route/ID
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildStatusBadge(item.status),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ActivityStatus status) {
    Color bgColor;
    Color textColor;
    String text;

    switch (status) {
      case ActivityStatus.upcoming:
        bgColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF15803D);
        text = 'Upcoming';
        break;
      case ActivityStatus.delivered:
        bgColor = const Color(0xFFDBEAFE);
        textColor = const Color(0xFF1D4ED8);
        text = 'Delivered';
        break;
      case ActivityStatus.completed:
        bgColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF15803D);
        text = 'Completed';
        break;
      case ActivityStatus.cancelled:
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFDC2626);
        text = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}
