import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/lat_lng.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../places/domain/entities/place_prediction.dart';
import '../../data/datasources/routes_remote_datasource.dart';
import '../../data/repositories/routes_repository_impl.dart';
import '../../domain/entities/route_option.dart';
import '../../domain/usecases/get_routes_usecase.dart';
import '../bloc/route_selection/route_selection_bloc.dart';
import '../bloc/route_selection/route_selection_event.dart';
import '../bloc/route_selection/route_selection_state.dart';
import '../widgets/route_map_canvas.dart';
import '../widgets/route_option_card.dart';

/// Route Selection Screen matching the attached screenshot:
/// - Top: Interactive Google Map with origin/destination pins and multi-route polylines
/// - Bottom Sheet: "What is your return route?", radio selection of alternative routes
/// - Floating Action Button: Circular blue button with white arrow to proceed
class RouteSelectionPage extends StatefulWidget {
  final PlacePrediction? origin;
  final PlacePrediction? destination;
  final String? originText;
  final String? destinationText;
  final LatLng? originLatLng;
  final LatLng? destinationLatLng;
  final String title;
  final VoidCallback onBack;
  final ValueChanged<RouteOption> onRouteConfirmed;

  const RouteSelectionPage({
    super.key,
    this.origin,
    this.destination,
    this.originText,
    this.destinationText,
    this.originLatLng,
    this.destinationLatLng,
    this.title = 'What is your return route?',
    required this.onBack,
    required this.onRouteConfirmed,
  });

  @override
  State<RouteSelectionPage> createState() => _RouteSelectionPageState();
}

class _RouteSelectionPageState extends State<RouteSelectionPage> {
  late final RouteSelectionBloc _routeBloc;
  bool _isLocalBloc = false;

  String get _originString {
    if (widget.originText != null && widget.originText!.isNotEmpty) {
      return widget.originText!;
    }
    if (widget.origin != null && widget.origin!.mainText.isNotEmpty) {
      return widget.origin!.mainText;
    }
    return widget.origin?.displayAddress ?? '';
  }

  String get _destString {
    if (widget.destinationText != null && widget.destinationText!.isNotEmpty) {
      return widget.destinationText!;
    }
    if (widget.destination != null && widget.destination!.mainText.isNotEmpty) {
      return widget.destination!.mainText;
    }
    return widget.destination?.displayAddress ?? '';
  }

  @override
  void initState() {
    super.initState();
    // Use existing RouteSelectionBloc from context if present, or instantiate clean repository & bloc
    try {
      _routeBloc = context.read<RouteSelectionBloc>();
    } catch (_) {
      _isLocalBloc = true;
      final remoteDataSource = RoutesRemoteDataSourceImpl();
      final repository = RoutesRepositoryImpl(remoteDataSource: remoteDataSource);
      _routeBloc = RouteSelectionBloc(
        getRoutesUseCase: GetRoutesUseCase(repository),
      );
    }

    _loadRoutes();
  }

  void _loadRoutes() {
    _routeBloc.add(
      LoadRoutesEvent(
        origin: _originString,
        destination: _destString,
        originLatLng: widget.originLatLng,
        destinationLatLng: widget.destinationLatLng,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant RouteSelectionPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.origin != oldWidget.origin ||
        widget.destination != oldWidget.destination ||
        widget.originText != oldWidget.originText ||
        widget.destinationText != oldWidget.destinationText) {
      _loadRoutes();
    }
  }

  @override
  void dispose() {
    if (_isLocalBloc) {
      _routeBloc.close();
    }
    super.dispose();
  }

  void _onConfirm() {
    final state = _routeBloc.state;
    if (state.selectedRoute != null) {
      widget.onRouteConfirmed(state.selectedRoute!);
    } else if (state.routes.isNotEmpty) {
      widget.onRouteConfirmed(state.routes.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _routeBloc,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocBuilder<RouteSelectionBloc, RouteSelectionState>(
          builder: (context, state) {
            final originTitle = state.origin.isNotEmpty ? state.origin : _originString;
            final destTitle = state.destination.isNotEmpty ? state.destination : _destString;

            final LatLng originCoord;
            final LatLng destCoord;
            if (state.selectedRoute != null &&
                state.selectedRoute!.polylinePoints.isNotEmpty) {
              originCoord = state.selectedRoute!.polylinePoints.first;
              destCoord = state.selectedRoute!.polylinePoints.last;
            } else if (state.routes.isNotEmpty &&
                state.routes.first.polylinePoints.isNotEmpty) {
              originCoord = state.routes.first.polylinePoints.first;
              destCoord = state.routes.first.polylinePoints.last;
            } else {
              originCoord = state.originLatLng ??
                  (originTitle.toLowerCase().contains('hyd')
                      ? const LatLng(17.3850, 78.4867)
                      : const LatLng(16.5062, 80.6480));
              destCoord = state.destinationLatLng ??
                  (destTitle.toLowerCase().contains('raja')
                      ? const LatLng(17.0005, 81.8040)
                      : const LatLng(17.3850, 78.4867));
            }

            return Stack(
              children: [
                Column(
                  children: [
                    // Top: Google Map with Route Polylines (taking top 48% of screen)
                    Expanded(
                      flex: 48,
                      child: RouteMapCanvas(
                        origin: originCoord,
                        destination: destCoord,
                        originTitle: originTitle,
                        destinationTitle: destTitle,
                        routes: state.routes,
                        selectedRoute: state.selectedRoute,
                        onBack: widget.onBack,
                      ),
                    ),

                    // Bottom: White Bottom Card with Route Radio Choices
                    Expanded(
                      flex: 52,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(20),
                              blurRadius: 16,
                              offset: const Offset(0, -4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Subtle top drag handle
                            Center(
                              child: Container(
                                margin: const EdgeInsets.only(top: 10, bottom: 12),
                                width: 38,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE2E8F0),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),

                            // Heading: "What is your return route?"
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
                              child: Text(
                                widget.title,
                                style: AppTypography.displayLarge.copyWith(
                                  fontSize: 27,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF0A1E34),
                                  height: 1.2,
                                  letterSpacing: -0.4,
                                ),
                              ),
                            ),

                            // Loading state or Route list
                            if (state.isLoading && state.routes.isEmpty)
                              const Expanded(
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF0070E0),
                                    ),
                                  ),
                                ),
                              )
                            else if (state.routes.isEmpty)
                              Expanded(
                                child: Center(
                                  child: Text(
                                    'No routes found',
                                    style: AppTypography.bodyLarge.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              )
                            else
                              Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.only(bottom: 80),
                                  itemCount: state.routes.length,
                                  itemBuilder: (context, index) {
                                    final route = state.routes[index];
                                    final isSelected = state.selectedRoute?.id == route.id;

                                    return RouteOptionCard(
                                      route: route,
                                      isSelected: isSelected,
                                      onTap: () {
                                        _routeBloc.add(SelectRouteOptionEvent(route.id));
                                      },
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Floating Next Button at Bottom Right matching screenshot
                Positioned(
                  right: 20,
                  bottom: 24,
                  child: SafeArea(
                    top: false,
                    child: Material(
                      color: const Color(0xFF0070E0), // Vibrant blue FAB
                      shape: const CircleBorder(),
                      elevation: 6,
                      shadowColor: const Color(0xFF0070E0).withAlpha(120),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _onConfirm,
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
            );
          },
        ),
      ),
    );
  }
}
