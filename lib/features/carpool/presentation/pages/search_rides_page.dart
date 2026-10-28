import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../bloc/carpool_bloc.dart';
import '../bloc/carpool_event.dart';
import '../bloc/carpool_state.dart';
import '../widgets/carpool_ride_card.dart';
import '../widgets/ride_filter_sheet.dart';
import '../../../places/presentation/bloc/places_bloc.dart';
import '../../../places/presentation/bloc/places_event.dart';
import '../../../places/presentation/bloc/places_state.dart';
import '../../../places/presentation/widgets/places_autocomplete_list.dart';

class SearchRidesPage extends StatefulWidget {
  const SearchRidesPage({super.key});

  @override
  State<SearchRidesPage> createState() => _SearchRidesPageState();
}

class _SearchRidesPageState extends State<SearchRidesPage> {
  final TextEditingController _originCtrl = TextEditingController();
  final TextEditingController _destCtrl = TextEditingController();
  final TextEditingController _passengersCtrl = TextEditingController(
    text: '1',
  );
  final TextEditingController _returnPassengersCtrl = TextEditingController(
    text: '1',
  );
  DateTime? _selectedDate;
  DateTime? _returnDate;
  int _passengers = 1;
  bool _isSearchCardExpanded = true;

  @override
  void dispose() {
    _originCtrl.dispose();
    _destCtrl.dispose();
    _passengersCtrl.dispose();
    _returnPassengersCtrl.dispose();
    super.dispose();
  }

  void _onSearchPressed() {
    context.read<PlacesBloc>().add(const ClearPlacesEvent());
    final count = int.tryParse(_passengersCtrl.text.trim()) ?? _passengers;
    context.read<CarpoolBloc>().add(
      SearchRidesEvent(
        origin: _originCtrl.text.trim(),
        destination: _destCtrl.text.trim(),
        date: _selectedDate ?? DateTime.now(),
        passengers: count > 0 ? count : 1,
        returnDate: _returnDate,
      ),
    );
    setState(() {
      _isSearchCardExpanded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.directions_car,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Carpool',
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.primaryNavy,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: AppColors.textPrimary),
            tooltip: 'Filter rides',
            onPressed: () => _openFilterSheet(context),
          ),
        ],
      ),
      body: BlocConsumer<CarpoolBloc, CarpoolState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        builder: (context, state) {
          final rides = state.filteredRides;

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              context.read<CarpoolBloc>().add(
                const LoadCarpoolRidesEvent(refresh: true),
              );
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                _buildSearchCard(),
                const SizedBox(height: 16),
                _buildResultsHeader(rides.length, state),
                const SizedBox(height: 12),
                if (state.status == CarpoolStatus.loading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  )
                else if (rides.isEmpty)
                  _buildEmptyRidesState()
                else
                  ...rides.map(
                    (ride) => CarpoolRideCard(
                      ride: ride,
                      onTap: () {
                        context.read<CarpoolBloc>().add(SelectRideEvent(ride));
                        context.push(AppRoutes.rideDetails, extra: ride);
                      },
                    ),
                  ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Collapsible Header
          InkWell(
            onTap: () {
              setState(() {
                _isSearchCardExpanded = !_isSearchCardExpanded;
              });
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _originCtrl.text.isNotEmpty || _destCtrl.text.isNotEmpty
                          ? '${_originCtrl.text.isEmpty ? "Anywhere" : _originCtrl.text} ${_returnDate != null ? "⇄" : "→"} ${_destCtrl.text.isEmpty ? "Everywhere" : _destCtrl.text}'
                          : 'Where are you going?',
                      style: AppTypography.titleMedium.copyWith(
                        fontSize: 15,
                        color:
                            _originCtrl.text.isNotEmpty ||
                                _destCtrl.text.isNotEmpty
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    _isSearchCardExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (_isSearchCardExpanded) ...[
            const Divider(height: 1, color: AppColors.borderLight),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CustomTextField(
                    controller: _originCtrl,
                    hintText: 'Leaving from (city, station, or landmark)',
                    prefixIcon: Icons.trip_origin,
                    suffixIcon: _originCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              setState(() {
                                _originCtrl.clear();
                              });
                              context.read<PlacesBloc>().add(
                                const ClearPlacesEvent(
                                  target: PlaceSearchTarget.origin,
                                ),
                              );
                            },
                          )
                        : null,
                    onChanged: (val) {
                      setState(() {});
                      context.read<PlacesBloc>().add(
                        SearchPlacesQueryEvent(
                          query: val,
                          target: PlaceSearchTarget.origin,
                        ),
                      );
                    },
                  ),
                  BlocBuilder<PlacesBloc, PlacesState>(
                    buildWhen: (prev, curr) =>
                        prev.originPredictions != curr.originPredictions ||
                        prev.isOriginLoading != curr.isOriginLoading ||
                        prev.activeTarget != curr.activeTarget,
                    builder: (context, placesState) {
                      if (placesState.activeTarget !=
                              PlaceSearchTarget.origin &&
                          placesState.originPredictions.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return PlacesAutocompleteList(
                        predictions: placesState.originPredictions,
                        isLoading: placesState.isOriginLoading,
                        onPlaceSelected: (prediction) {
                          setState(() {
                            _originCtrl.text = prediction.displayAddress;
                          });
                          context.read<PlacesBloc>().add(
                            SelectPlacePredictionEvent(
                              prediction: prediction,
                              target: PlaceSearchTarget.origin,
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _destCtrl,
                    hintText: 'Going to (city, destination)',
                    prefixIcon: Icons.location_on_outlined,
                    suffixIcon: _destCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              setState(() {
                                _destCtrl.clear();
                              });
                              context.read<PlacesBloc>().add(
                                const ClearPlacesEvent(
                                  target: PlaceSearchTarget.destination,
                                ),
                              );
                            },
                          )
                        : null,
                    onChanged: (val) {
                      setState(() {});
                      context.read<PlacesBloc>().add(
                        SearchPlacesQueryEvent(
                          query: val,
                          target: PlaceSearchTarget.destination,
                        ),
                      );
                    },
                  ),
                  BlocBuilder<PlacesBloc, PlacesState>(
                    buildWhen: (prev, curr) =>
                        prev.destPredictions != curr.destPredictions ||
                        prev.isDestLoading != curr.isDestLoading ||
                        prev.activeTarget != curr.activeTarget,
                    builder: (context, placesState) {
                      if (placesState.activeTarget !=
                              PlaceSearchTarget.destination &&
                          placesState.destPredictions.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return PlacesAutocompleteList(
                        predictions: placesState.destPredictions,
                        isLoading: placesState.isDestLoading,
                        onPlaceSelected: (prediction) {
                          setState(() {
                            _destCtrl.text = prediction.displayAddress;
                          });
                          context.read<PlacesBloc>().add(
                            SelectPlacePredictionEvent(
                              prediction: prediction,
                              target: PlaceSearchTarget.destination,
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  // First Row: Departure Date & Number of Persons
                  Row(
                    children: [
                      // Departure Date Selector
                      Expanded(
                        flex: 3,
                        child: InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 11,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.inputFill,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedDate != null
                                    ? AppColors.primary.withAlpha(140)
                                    : AppColors.inputBorder,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 18,
                                  color: _selectedDate != null
                                      ? AppColors.primaryNavy
                                      : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Departure',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: _selectedDate != null
                                              ? AppColors.primaryNavy
                                              : AppColors.textSecondary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _selectedDate != null
                                            ? DateFormatter.formatDate(
                                                _selectedDate!,
                                              )
                                            : 'Select date',
                                        style: AppTypography.bodyMedium
                                            .copyWith(
                                              color: _selectedDate != null
                                                  ? AppColors.textPrimary
                                                  : AppColors.textSecondary,
                                              fontWeight: _selectedDate != null
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                              fontSize: 14,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                if (_selectedDate != null)
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedDate = null;
                                      });
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.only(left: 4),
                                      child: Icon(
                                        Icons.close,
                                        size: 16,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Departure Passengers Selector
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 11,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.inputFill,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.inputBorder),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.person,
                                size: 18,
                                color: AppColors.primaryNavy,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Seats',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    TextField(
                                      controller: _passengersCtrl,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(2),
                                      ],
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        hintText: '1',
                                      ),
                                      onChanged: (val) {
                                        final count = int.tryParse(val.trim());
                                        if (count != null && count > 0) {
                                          _passengers = count;
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Second Row: Return Date & Number of Persons
                  Row(
                    children: [
                      // Return Date Selector
                      Expanded(
                        flex: 3,
                        child: InkWell(
                          onTap: _pickReturnDate,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 11,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.inputFill,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _returnDate != null
                                    ? AppColors.primary.withAlpha(140)
                                    : AppColors.inputBorder,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_month_outlined,
                                  size: 18,
                                  color: _returnDate != null
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Return Date',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: _returnDate != null
                                              ? AppColors.primary
                                              : AppColors.textSecondary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _returnDate != null
                                            ? DateFormatter.formatDate(
                                                _returnDate!,
                                              )
                                            : 'Add return date',
                                        style: AppTypography.bodyMedium
                                            .copyWith(
                                              color: _returnDate != null
                                                  ? AppColors.textPrimary
                                                  : AppColors.textSecondary,
                                              fontWeight: _returnDate != null
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                              fontSize: 14,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                if (_returnDate != null)
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _returnDate = null;
                                      });
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.only(left: 4),
                                      child: Icon(
                                        Icons.close,
                                        size: 16,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Return Passengers Selector
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 11,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.inputFill,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _returnDate != null
                                  ? AppColors.primary.withAlpha(140)
                                  : AppColors.inputBorder,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 18,
                                color: _returnDate != null
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Seats',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: _returnDate != null
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    TextField(
                                      controller: _returnPassengersCtrl,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(2),
                                      ],
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: _returnDate != null
                                            ? AppColors.textPrimary
                                            : AppColors.textSecondary,
                                        fontWeight: _returnDate != null
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        hintText: '1',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Search Rides',
                    icon: Icons.search,
                    onPressed: _onSearchPressed,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultsHeader(int count, CarpoolState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$count rides available',
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (state.searchOrigin != null || state.searchDestination != null)
          TextButton.icon(
            onPressed: () {
              _originCtrl.clear();
              _destCtrl.clear();
              context.read<CarpoolBloc>().add(ClearSearchEvent());
            },
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Show All'),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
      ],
    );
  }

  Widget _buildEmptyRidesState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.directions_car_filled_outlined,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text('No rides found', style: AppTypography.titleLarge),
          const SizedBox(height: 8),
          Text(
            'We couldn’t find any carpool trips matching your route and date. Try adjusting your filters or publish your own ride!',
            style: AppTypography.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          CustomButton(
            text: 'Clear Filters & Show All',
            isOutlined: true,
            onPressed: () {
              _originCtrl.clear();
              _destCtrl.clear();
              setState(() {
                _selectedDate = null;
                _returnDate = null;
                _passengers = 1;
                _passengersCtrl.text = '1';
                _returnPassengersCtrl.text = '1';
              });
              context.read<CarpoolBloc>().add(ClearSearchEvent());
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        if (_returnDate != null && _returnDate!.isBefore(picked)) {
          _returnDate = picked;
        }
      });
    }
  }

  Future<void> _pickReturnDate() async {
    final baseDate = _selectedDate ?? DateTime.now();
    final initial = _returnDate != null && !_returnDate!.isBefore(baseDate)
        ? _returnDate!
        : baseDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: baseDate,
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _returnDate = picked;
      });
    }
  }

  void _openFilterSheet(BuildContext context) {
    final bloc = context.read<CarpoolBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RideFilterSheet(
        currentMaxPrice: bloc.state.maxPriceFilter ?? 50.0,
        currentInstantBooking: bloc.state.instantBookingFilter,
        currentVerifiedOnly: bloc.state.verifiedOnlyFilter,
        currentSortBy: bloc.state.sortBy,
        onApply: ({maxPrice, instantBooking, verifiedOnly, sortBy}) {
          bloc.add(
            FilterRidesEvent(
              maxPrice: maxPrice,
              instantBookingOnly: instantBooking,
              verifiedOnly: verifiedOnly,
              sortBy: sortBy,
            ),
          );
        },
      ),
    );
  }
}
