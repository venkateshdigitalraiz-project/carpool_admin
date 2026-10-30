import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/distance_calculator.dart';
import '../../../places/domain/entities/place_prediction.dart';
import '../../../places/presentation/bloc/places_bloc.dart';
import '../../../places/presentation/bloc/places_event.dart';
import '../../../places/presentation/bloc/places_state.dart';
import 'interactive_map_canvas.dart';

enum LocationStepStage {
  initialInput, // Screenshot 1: "Drop-off" / "Pick-up" with clean search pill
  searching, // Screenshot 2: Active textfield & places autocomplete list
  mapPreview, // Screenshot 3: "Where would you like to pick up passengers?", map canvas
}

class PublishLocationStepView extends StatefulWidget {
  final bool isPickup;
  final VoidCallback onBack;
  final ValueChanged<PlacePrediction> onLocationConfirmed;
  final PlacePrediction? initialLocation;
  final PlacePrediction? pickupLocation;

  const PublishLocationStepView({
    super.key,
    required this.isPickup,
    required this.onBack,
    required this.onLocationConfirmed,
    this.initialLocation,
    this.pickupLocation,
  });

  @override
  State<PublishLocationStepView> createState() =>
      _PublishLocationStepViewState();
}

class _PublishLocationStepViewState extends State<PublishLocationStepView> {
  late LocationStepStage _stage;
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _mapDetailCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  PlacePrediction? _selectedPrediction;
  RoutePriceEstimate? _mapEstimate;

  PlaceSearchTarget get _target => widget.isPickup
      ? PlaceSearchTarget.origin
      : PlaceSearchTarget.destination;

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _selectedPrediction = widget.initialLocation;
      _searchCtrl.text = widget.initialLocation!.mainText;
      _mapDetailCtrl.text = widget.initialLocation!.mainText;
      _stage = LocationStepStage.mapPreview;
      _updateMapEstimate();
    } else {
      _stage = LocationStepStage.initialInput;
    }
  }

  @override
  void didUpdateWidget(covariant PublishLocationStepView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialLocation != oldWidget.initialLocation) {
      if (widget.initialLocation != null) {
        _selectedPrediction = widget.initialLocation;
        _searchCtrl.text = widget.initialLocation!.mainText;
        _mapDetailCtrl.text = widget.initialLocation!.mainText;
        _stage = LocationStepStage.mapPreview;
        _updateMapEstimate();
      } else {
        _selectedPrediction = null;
        _searchCtrl.clear();
        _mapDetailCtrl.clear();
        _stage = LocationStepStage.initialInput;
        _mapEstimate = null;
      }
    }
  }

  void _updateMapEstimate() async {
    if (widget.isPickup || widget.pickupLocation == null) return;
    final destText = _mapDetailCtrl.text.trim().isNotEmpty
        ? _mapDetailCtrl.text.trim()
        : (_selectedPrediction?.mainText ?? '');
    if (destText.isEmpty) return;

    final estimate = await DistanceCalculator.calculateRouteEstimate(
      originText: widget.pickupLocation!.mainText,
      destinationText: destText,
      ratePerKm: 5.0,
    );
    if (mounted) {
      setState(() {
        _mapEstimate = estimate;
      });
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _mapDetailCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onEnterSearchMode() {
    setState(() {
      _stage = LocationStepStage.searching;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_focusNode.canRequestFocus) {
        _focusNode.requestFocus();
      }
    });
    context.read<PlacesBloc>().add(
      SearchPlacesQueryEvent(query: _searchCtrl.text.trim(), target: _target),
    );
  }

  void _onQueryChanged(String query) {
    context.read<PlacesBloc>().add(
      SearchPlacesQueryEvent(query: query, target: _target),
    );
  }

  void _onSelectPrediction(PlacePrediction prediction) {
    context.read<PlacesBloc>().add(
      SelectPlacePredictionEvent(prediction: prediction, target: _target),
    );
    setState(() {
      _selectedPrediction = prediction;
      _searchCtrl.text = prediction.mainText;
      _mapDetailCtrl.text = prediction.mainText;
      _stage = LocationStepStage.mapPreview;
    });
    _updateMapEstimate();
  }

  void _onConfirmLocation() {
    if (_selectedPrediction != null) {
      widget.onLocationConfirmed(_selectedPrediction!);
    } else {
      // Fallback if custom text entered
      final text = _mapDetailCtrl.text.trim().isNotEmpty
          ? _mapDetailCtrl.text.trim()
          : _searchCtrl.text.trim();
      final mainPart = text.contains(',') ? text.split(',').first.trim() : text;
      final defaultLabel = widget.isPickup ? 'Pick-up Location' : 'Drop-off Location';
      final custom = PlacePrediction(
        placeId: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        fullText: text.isNotEmpty ? text : defaultLabel,
        mainText: mainPart.isNotEmpty ? mainPart : defaultLabel,
        secondaryText: '',
      );
      widget.onLocationConfirmed(custom);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: switch (_stage) {
          LocationStepStage.initialInput => _buildInitialInputView(),
          LocationStepStage.searching => _buildSearchingView(),
          LocationStepStage.mapPreview => _buildMapPreviewView(),
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SCREENSHOT 1: Clean Initial Input Page (Pick-up / Drop-off)
  // ---------------------------------------------------------------------------
  Widget _buildInitialInputView() {
    final title = widget.isPickup ? 'Pick-up' : 'Drop-off';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back Arrow
          IconButton(
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.primaryNavy,
              size: 26,
            ),
            onPressed: widget.onBack,
          ),
          const SizedBox(height: 24),

          // Big Bold Title matching Screenshot 1
          Text(
            title,
            style: AppTypography.displayLarge.copyWith(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryNavy,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 28),

          // Search Pill Box matching Screenshot 1
          GestureDetector(
            onTap: _onEnterSearchMode,
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF2F6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Color(0xFF708C91), size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedPrediction?.mainText.isNotEmpty == true
                          ? _selectedPrediction!.mainText
                          : (_searchCtrl.text.isNotEmpty
                              ? _searchCtrl.text
                              : (widget.isPickup
                                  ? 'Search pick-up city, town, or area'
                                  : 'Search drop-off city, town, or area')),
                      style: AppTypography.bodyLarge.copyWith(
                        color: (_selectedPrediction != null || _searchCtrl.text.isNotEmpty)
                            ? AppColors.primaryNavy
                            : const Color(0xFF708C91),
                        fontSize: 16,
                        fontWeight: (_selectedPrediction != null || _searchCtrl.text.isNotEmpty)
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SCREENSHOT 2: Autocomplete Prediction List
  // ---------------------------------------------------------------------------
  Widget _buildSearchingView() {
    return BlocBuilder<PlacesBloc, PlacesState>(
      builder: (context, placesState) {
        final predictions = widget.isPickup
            ? placesState.originPredictions
            : placesState.destPredictions;
        final isLoading = widget.isPickup
            ? placesState.isOriginLoading
            : placesState.isDestLoading;

        return Column(
          children: [
            // Top Search Bar matching Screenshot 2
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF2F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    // Back chevron '<'
                    IconButton(
                      icon: const Icon(
                        Icons.chevron_left,
                        color: AppColors.primaryNavy,
                        size: 26,
                      ),
                      onPressed: () {
                        if (_selectedPrediction != null) {
                          setState(() {
                            _stage = LocationStepStage.mapPreview;
                          });
                        } else {
                          widget.onBack();
                        }
                      },
                    ),
                    // Search input
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        focusNode: _focusNode,
                        style: AppTypography.bodyLarge.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryNavy,
                        ),
                        decoration: InputDecoration(
                          hintText: widget.isPickup
                              ? 'Enter pick-up city or town'
                              : 'Enter drop-off city or town',
                          hintStyle: AppTypography.bodyLarge.copyWith(
                            color: const Color(0xFF708C91),
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                        onChanged: _onQueryChanged,
                      ),
                    ),
                    // Clear '✕' button
                    if (_searchCtrl.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Color(0xFF708C91),
                          size: 20,
                        ),
                        onPressed: () {
                          _searchCtrl.clear();
                          context.read<PlacesBloc>().add(
                            SearchPlacesQueryEvent(query: '', target: _target),
                          );
                          setState(() {});
                        },
                      ),
                  ],
                ),
              ),
            ),

            if (isLoading)
              const LinearProgressIndicator(
                minHeight: 2,
                backgroundColor: Color(0xFFEFF2F6),
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),

            // Section Header
            if (predictions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
                child: Row(
                  children: [
                    Icon(
                      _searchCtrl.text.trim().isEmpty
                          ? Icons.star_rounded
                          : Icons.location_city_rounded,
                      size: 16,
                      color: const Color(0xFF708C91),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _searchCtrl.text.trim().isEmpty
                          ? 'ALL CITIES & TOWNS'
                          : 'MATCHING CITIES & TOWNS (${predictions.length})',
                      style: AppTypography.bodySmall.copyWith(
                        color: const Color(0xFF708C91),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

            // Autocomplete Prediction List matching Screenshot 2
            if (predictions.isEmpty && !isLoading)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_city_outlined,
                          size: 48,
                          color: Color(0xFF708C91),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No matching city or town found',
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.primaryNavy,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (_searchCtrl.text.trim().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'You can still select "${_searchCtrl.text.trim()}" directly',
                            style: AppTypography.bodySmall.copyWith(
                              color: const Color(0xFF708C91),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.check, size: 18),
                            label: Text('Use "${_searchCtrl.text.trim()}"'),
                            onPressed: () {
                              final query = _searchCtrl.text.trim();
                              final custom = PlacePrediction(
                                placeId: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                                fullText: query,
                                mainText: query,
                                secondaryText: '',
                              );
                              _onSelectPrediction(custom);
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  itemCount: predictions.length,
                  separatorBuilder: (_, _) => const Divider(
                    height: 1,
                    color: Color(0xFFE8ECEF),
                    indent: 0,
                    endIndent: 0,
                  ),
                  itemBuilder: (context, index) {
                    final item = predictions[index];
                    final isFirstItem = index == 0;
                    final subtitle = item.secondaryText.isNotEmpty
                        ? item.secondaryText
                        : item.fullText;

                    return InkWell(
                      onTap: () => _onSelectPrediction(item),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Clock icon for top item or location pin
                            Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: Icon(
                                isFirstItem ? Icons.access_time : Icons.location_on_outlined,
                                color: const Color(0xFF708C91),
                                size: 22,
                              ),
                            ),

                            // Text Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.mainText,
                                    style: AppTypography.titleMedium.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primaryNavy,
                                    ),
                                  ),
                                  if (subtitle.isNotEmpty) ...[
                                    const SizedBox(height: 3),
                                    Text(
                                      subtitle,
                                      style: AppTypography.bodySmall.copyWith(
                                        fontSize: 13,
                                        color: const Color(0xFF708C91),
                                        fontWeight: FontWeight.w500,
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            // Right Chevron '>'
                            const Icon(
                              Icons.chevron_right,
                              color: Color(0xFF708C91),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // SCREENSHOT 3: Map View with Pin, Search Box & "Where would you like..."
  // ---------------------------------------------------------------------------
  Widget _buildMapPreviewView() {
    final title = widget.isPickup
        ? 'Pick up passengers?'
        : 'Drop off passengers?';
    final selectedText = _mapDetailCtrl.text.trim().isNotEmpty
        ? _mapDetailCtrl.text.trim()
        : (_selectedPrediction?.mainText.isNotEmpty == true
              ? _selectedPrediction!.mainText
              : _searchCtrl.text.trim());
    final locTitle = selectedText.isNotEmpty
        ? selectedText
        : (widget.isPickup ? 'Pick-up Location' : 'Drop-off Location');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Section: Back, Title, Info Chip & Search Field
        //Colors(0xFF2A1034),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Arrow
              IconButton(
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.primaryNavy,
                  size: 26,
                ),
                onPressed: widget.onBack,
              ),
              const SizedBox(height: 12),

              // Title matching Screenshot 3
              Text(
                title,
                style: AppTypography.displayLarge.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryNavy,
                  height: 1.25,
                ),
              ),

              const SizedBox(height: 16),

              // Search Box Field matching Screenshot 3
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF2F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search,
                      color: Color(0xFF708C91),
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _mapDetailCtrl,
                        onChanged: (val) {
                          setState(() {});
                        },
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.primaryNavy,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: InputDecoration(
                          hintText: widget.isPickup
                              ? 'e.g. Hyderabad, Vijayawada'
                              : 'e.g. Rajamahendravaram, Guntur',
                          hintStyle: const TextStyle(
                            color: Color(0xFF708C91),
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Full Interactive Google Maps Canvas matching Screenshot 3 (edge-to-edge open style)
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveMapCanvas(
                  key: ValueKey(
                    'map_${widget.isPickup ? "pickup" : "dropoff"}_$locTitle',
                  ),
                  locationTitle: locTitle,
                  subtitle: _selectedPrediction?.secondaryText,
                  isPickup: widget.isPickup,
                ),
              ),

              // Floating Distance & Estimate Badge over Map
              if (_mapEstimate != null && !widget.isPickup)
                Positioned(
                  top: 14,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF86EFAC),
                            ),
                          ),
                          child: const Icon(
                            Icons.directions_car_rounded,
                            color: Color(0xFF16A34A),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${widget.pickupLocation?.mainText ?? "Origin"} ➔ $locTitle • ${_mapEstimate!.distanceKm.round()} km',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: Color(0xFF0A1E34),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Estimate: ₹${_mapEstimate!.estimatedPrice.round()} (@ ₹5/km) • Margin: ${_mapEstimate!.priceRangeFormatted}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: Color(0xFF15803D),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Right-bottom circular arrow button displayed after exact location is selected
              if (_selectedPrediction != null ||
                  _mapDetailCtrl.text.trim().isNotEmpty)
                Positioned(
                  right: 20,
                  bottom: 24,
                  child: SafeArea(
                    top: false,
                    child: Material(
                      color: AppColors.primary,
                      shape: const CircleBorder(),
                      elevation: 6,
                      shadowColor: AppColors.primary.withAlpha(120),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _onConfirmLocation,
                        child: Container(
                          width: 58,
                          height: 58,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
