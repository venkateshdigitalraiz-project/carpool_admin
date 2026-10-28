import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/carpool_ride.dart';

class CarpoolTable extends StatefulWidget {
  final List<CarpoolRide> rides;
  final Function(CarpoolRide) onRideSelected;
  final Function(String rideId, String status) onStatusChanged;

  const CarpoolTable({
    super.key,
    required this.rides,
    required this.onRideSelected,
    required this.onStatusChanged,
  });

  @override
  State<CarpoolTable> createState() => _CarpoolTableState();
}

class _CarpoolTableState extends State<CarpoolTable> {
  String _selectedStatusFilter = 'ALL';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CarpoolRide> get _filteredRides {
    return widget.rides.where((ride) {
      final matchesStatus = _selectedStatusFilter == 'ALL' ||
          ride.status.toUpperCase() == _selectedStatusFilter;

      final query = _searchQuery.toLowerCase();
      final matchesSearch = query.isEmpty ||
          ride.id.toLowerCase().contains(query) ||
          ride.driver.name.toLowerCase().contains(query) ||
          ride.origin.toLowerCase().contains(query) ||
          ride.destination.toLowerCase().contains(query);

      return matchesStatus && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildFilterHeader(),
          const Divider(height: 1, color: AppColors.borderLight),
          _filteredRides.isEmpty
              ? _buildEmptyState()
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    horizontalMargin: 20,
                    columnSpacing: 24,
                    headingRowHeight: 48,
                    dataRowMinHeight: 64,
                    dataRowMaxHeight: 68,
                    headingRowColor: WidgetStateProperty.all(
                      AppColors.inputFill,
                    ),
                    columns: [
                      DataColumn(
                        label: Text('Ride ID', style: AppTypography.titleMedium.copyWith(fontSize: 13)),
                      ),
                      DataColumn(
                        label: Text('Driver', style: AppTypography.titleMedium.copyWith(fontSize: 13)),
                      ),
                      DataColumn(
                        label: Text('Route', style: AppTypography.titleMedium.copyWith(fontSize: 13)),
                      ),
                      DataColumn(
                        label: Text('Departure', style: AppTypography.titleMedium.copyWith(fontSize: 13)),
                      ),
                      DataColumn(
                        label: Text('Fare', style: AppTypography.titleMedium.copyWith(fontSize: 13)),
                      ),
                      DataColumn(
                        label: Text('Seats (Booked/Total)', style: AppTypography.titleMedium.copyWith(fontSize: 13)),
                      ),
                      DataColumn(
                        label: Text('Status', style: AppTypography.titleMedium.copyWith(fontSize: 13)),
                      ),
                      DataColumn(
                        label: Text('Actions', style: AppTypography.titleMedium.copyWith(fontSize: 13)),
                      ),
                    ],
                    rows: _filteredRides.map((ride) => _buildDataRow(ride)).toList(),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildFilterHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search by driver, city or ride ID...',
                      hintStyle: AppTypography.bodySmall,
                      prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatusChip('ALL', 'All Rides (${widget.rides.length})'),
                const SizedBox(width: 8),
                _buildStatusChip(
                  'ACTIVE',
                  'Active (${widget.rides.where((r) => r.status == 'ACTIVE').length})',
                ),
                const SizedBox(width: 8),
                _buildStatusChip(
                  'FULL',
                  'Full (${widget.rides.where((r) => r.status == 'FULL').length})',
                ),
                const SizedBox(width: 8),
                _buildStatusChip(
                  'COMPLETED',
                  'Completed (${widget.rides.where((r) => r.status == 'COMPLETED').length})',
                ),
                const SizedBox(width: 8),
                _buildStatusChip(
                  'CANCELLED',
                  'Cancelled (${widget.rides.where((r) => r.status == 'CANCELLED').length})',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String statusKey, String label) {
    final isSelected = _selectedStatusFilter == statusKey;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedStatusFilter = statusKey;
          });
        }
      },
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        fontSize: 12,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  DataRow _buildDataRow(CarpoolRide ride) {
    final bookedSeats = ride.totalSeats - ride.availableSeats;
    return DataRow(
      cells: [
        // Ride ID
        DataCell(
          Text(
            ride.id,
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryNavy,
            ),
          ),
        ),
        // Driver
        DataCell(
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundImage: NetworkImage(ride.driver.avatarUrl),
                onBackgroundImageError: (error, stack) {},
                child: Text(
                  ride.driver.name.isNotEmpty ? ride.driver.name[0] : 'D',
                  style: const TextStyle(fontSize: 10),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    ride.driver.name,
                    style: AppTypography.titleMedium.copyWith(fontSize: 13),
                  ),
                  Text(
                    '★ ${ride.driver.rating.toStringAsFixed(1)}',
                    style: AppTypography.bodySmall.copyWith(color: Colors.amber.shade800),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Route
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  const Icon(Icons.trip_origin, size: 12, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(ride.origin, style: AppTypography.titleMedium.copyWith(fontSize: 13)),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 12, color: AppColors.primaryNavy),
                  const SizedBox(width: 4),
                  Text(ride.destination, style: AppTypography.titleMedium.copyWith(fontSize: 13)),
                ],
              ),
            ],
          ),
        ),
        // Departure
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormatter.formatDate(ride.departureTime),
                style: AppTypography.titleMedium.copyWith(fontSize: 12),
              ),
              Text(
                DateFormatter.formatTime(ride.departureTime),
                style: AppTypography.bodySmall,
              ),
            ],
          ),
        ),
        // Fare
        DataCell(
          Text(
            DateFormatter.formatCurrency(ride.pricePerSeat),
            style: AppTypography.titleMedium.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
        ),
        // Seats
        DataCell(
          Row(
            children: [
              Text(
                '$bookedSeats / ${ride.totalSeats}',
                style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 6),
              Container(
                width: 40,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: ride.totalSeats > 0 ? (bookedSeats / ride.totalSeats).clamp(0.0, 1.0) : 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: bookedSeats == ride.totalSeats ? AppColors.accentCoral : AppColors.primary,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Status Badge
        DataCell(_buildStatusBadge(ride.status)),
        // Actions
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility_outlined, size: 20, color: AppColors.primary),
                tooltip: 'View details',
                onPressed: () => widget.onRideSelected(ride),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textSecondary),
                tooltip: 'Change Status',
                onSelected: (val) => widget.onStatusChanged(ride.id, val),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'ACTIVE', child: Text('Mark Active')),
                  const PopupMenuItem(value: 'COMPLETED', child: Text('Mark Completed')),
                  const PopupMenuItem(value: 'CANCELLED', child: Text('Cancel Ride')),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;

    switch (status.toUpperCase()) {
      case 'ACTIVE':
        bg = AppColors.success.withAlpha(30);
        fg = AppColors.success;
        break;
      case 'FULL':
        bg = Colors.amber.withAlpha(35);
        fg = Colors.amber.shade900;
        break;
      case 'COMPLETED':
        bg = AppColors.primary.withAlpha(30);
        fg = AppColors.primaryDark;
        break;
      case 'CANCELLED':
        bg = AppColors.error.withAlpha(30);
        fg = AppColors.error;
        break;
      default:
        bg = AppColors.border;
        fg = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(36),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.directions_car_outlined, size: 48, color: AppColors.textTertiary),
            const SizedBox(height: 12),
            Text(
              'No carpool rides match your filter',
              style: AppTypography.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Try adjusting your search query or selecting a different status.',
              style: AppTypography.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
