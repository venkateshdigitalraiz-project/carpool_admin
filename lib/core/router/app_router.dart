import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/auth_welcome_page.dart';
import '../../features/auth/presentation/pages/name_input_page.dart';
import '../../features/carpool/domain/entities/carpool_ride.dart';
import '../../features/carpool/presentation/pages/main_navigation_shell.dart';
import '../../features/carpool/presentation/pages/ride_details_page.dart';

import '../../features/places/domain/entities/place_prediction.dart';
import '../../features/carpool/domain/entities/route_option.dart';
import '../../features/carpool/presentation/pages/route_selection_page.dart';
import '../../features/carpool/presentation/pages/stopovers_selection_page.dart';

import '../../features/dashboard/presentation/pages/dashboard_shell_page.dart';

/// Centralized route constants for type-safe and consistent navigation
class AppRoutes {
  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String nameInput = '/name-input';
  static const String main = '/';
  static const String carpool = '/carpool';
  static const String rideDetails = '/ride-details';
  static const String routeSelection = '/route-selection';
  static const String stopovers = '/stopovers';
  static const String adminDashboard = '/admin';
}

/// Helper class that adapts a stream (such as a BLoC stream) to a Listenable for GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Central application router adhering to Clean Architecture
class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  /// Creates and configures the GoRouter instance reactive to AuthBloc
  static GoRouter createRouter(AuthBloc authBloc) {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: AppRoutes.main,
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (BuildContext context, GoRouterState state) {
        final authState = authBloc.state;
        final bool isAuthenticated =
            authState.status == AuthStatus.authenticated ||
            authState.user != null;
        final String location = state.matchedLocation;

        final bool isAuthRoute =
            location == AppRoutes.welcome || location == AppRoutes.nameInput;

        // If authenticated and currently on an auth page, redirect to Dashboard
        if (isAuthenticated && isAuthRoute) {
          return AppRoutes.main;
        }

        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.welcome,
          name: 'welcome',
          builder: (context, state) => const AuthWelcomePage(),
        ),

        GoRoute(
          path: AppRoutes.nameInput,
          name: 'name-input',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            final email = extra['email'] as String? ?? '';
            final optOutMarketing = extra['optOutMarketing'] as bool? ?? false;
            final phoneNumber = extra['phoneNumber'] as String? ?? '';
            return NameInputPage(
              email: email,
              optOutMarketing: optOutMarketing,
              phoneNumber: phoneNumber,
            );
          },
        ),
        GoRoute(
          path: AppRoutes.main,
          name: 'main',
          builder: (context, state) => const DashboardShellPage(),
        ),
        GoRoute(
          path: AppRoutes.carpool,
          name: 'carpool',
          builder: (context, state) => const MainNavigationShell(),
        ),
        GoRoute(
          path: AppRoutes.rideDetails,
          name: 'ride-details',
          builder: (context, state) {
            final ride = state.extra as CarpoolRide?;
            if (ride == null) {
              return Scaffold(
                appBar: AppBar(title: const Text('Ride Details')),
                body: const Center(child: Text('Ride details not provided')),
              );
            }
            return RideDetailsPage(ride: ride);
          },
        ),
        GoRoute(
          path: AppRoutes.routeSelection,
          name: 'route-selection',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            final origin = extra['origin'] as PlacePrediction?;
            final destination = extra['destination'] as PlacePrediction?;
            final originText = extra['originText'] as String?;
            final destinationText = extra['destinationText'] as String?;
            final title = extra['title'] as String? ?? 'What is your return route?';
            final onRouteConfirmed =
                extra['onRouteConfirmed'] as ValueChanged<RouteOption>?;
            return RouteSelectionPage(
              origin: origin,
              destination: destination,
              originText: originText,
              destinationText: destinationText,
              title: title,
              onBack: () => context.pop(),
              onRouteConfirmed: (route) {
                if (onRouteConfirmed != null) {
                  onRouteConfirmed(route);
                } else {
                  context.pop(route);
                }
              },
            );
          },
        ),
        GoRoute(
          path: AppRoutes.stopovers,
          name: 'stopovers',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            final origin = extra['origin'] as String? ?? '';
            final destination = extra['destination'] as String? ?? '';
            final selectedRoute = extra['selectedRoute'] as RouteOption?;
            final onStopoversConfirmed =
                extra['onStopoversConfirmed'] as ValueChanged<List<String>>?;
            return StopoversSelectionPage(
              origin: origin,
              destination: destination,
              selectedRoute: selectedRoute,
              onBack: () => context.pop(),
              onStopoversConfirmed: (stopovers) {
                if (onStopoversConfirmed != null) {
                  onStopoversConfirmed(stopovers);
                } else {
                  context.pop(stopovers);
                }
              },
            );
          },
        ),
      ],
      errorBuilder: (context, state) =>
          Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
    );
  }
}
