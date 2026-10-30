import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/storage/storedlocal.dart';
import 'features/auth/domain/entities/user_profile.dart';
import 'features/auth/domain/usecases/continue_as_guest_usecase.dart';
import 'features/auth/domain/usecases/get_current_user_usecase.dart';
import 'features/auth/domain/usecases/login_with_facebook_usecase.dart';
import 'features/auth/domain/usecases/login_with_google_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/register_with_email_usecase.dart';
import 'features/auth/domain/usecases/send_phone_otp_usecase.dart';
import 'features/auth/domain/usecases/update_profile_name_usecase.dart';
import 'features/auth/domain/usecases/update_survey_preferences_usecase.dart';
import 'features/auth/domain/usecases/verify_phone_otp_usecase.dart';
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/carpool/data/datasources/carpool_remote_datasource.dart';
import 'features/carpool/data/repositories/carpool_repository_impl.dart';
import 'features/carpool/domain/usecases/book_ride_usecase.dart';
import 'features/carpool/domain/usecases/cancel_booking_usecase.dart';
import 'features/carpool/domain/usecases/get_carpool_rides_usecase.dart';
import 'features/carpool/domain/usecases/publish_ride_usecase.dart';
import 'features/carpool/domain/usecases/search_rides_usecase.dart';
import 'features/carpool/domain/usecases/update_ride_status_usecase.dart';
import 'features/carpool/presentation/bloc/carpool_bloc.dart';
import 'features/carpool/presentation/bloc/carpool_event.dart';

import 'features/places/data/datasources/places_remote_datasource.dart';
import 'features/places/data/repositories/places_repository_impl.dart';
import 'features/places/domain/usecases/get_place_predictions_usecase.dart';
import 'features/places/presentation/bloc/places_bloc.dart';

import 'features/profile/data/datasources/profile_local_datasource.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/usecases/get_profile_usecase.dart';
import 'features/profile/domain/usecases/update_profile_picture_usecase.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/profile/presentation/bloc/profile_event.dart';

import 'features/carpool/data/datasources/routes_remote_datasource.dart';
import 'features/carpool/data/repositories/routes_repository_impl.dart';
import 'features/carpool/domain/usecases/get_routes_usecase.dart';
import 'features/carpool/presentation/bloc/route_selection/route_selection_bloc.dart';

import 'features/carpool/data/datasources/stopovers_remote_datasource.dart';
import 'features/carpool/data/repositories/stopovers_repository_impl.dart';
import 'features/carpool/domain/usecases/get_stopovers_usecase.dart';
import 'features/carpool/presentation/bloc/stopovers/stopovers_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storedLocal = StoredLocal();
  await storedLocal.init();
  final initialUser = await storedLocal.getUser();
  debugPrint('[main] App starting. Persisted user: ${initialUser?.fullName} (${initialUser?.phoneNumber}), isAuthenticated: ${initialUser != null}');
  runApp(BlaBlaCarpoolApp(
    initialUser: initialUser,
    storedLocal: storedLocal,
  ));
}

class BlaBlaCarpoolApp extends StatefulWidget {
  final AuthBloc? authBloc;
  final CarpoolBloc? carpoolBloc;
  final PlacesBloc? placesBloc;
  final ProfileBloc? profileBloc;
  final UserProfile? initialUser;
  final StoredLocal? storedLocal;

  const BlaBlaCarpoolApp({
    super.key,
    this.authBloc,
    this.carpoolBloc,
    this.placesBloc,
    this.profileBloc,
    this.initialUser,
    this.storedLocal,
  });

  @override
  State<BlaBlaCarpoolApp> createState() => _BlaBlaCarpoolAppState();
}

class _BlaBlaCarpoolAppState extends State<BlaBlaCarpoolApp> {
  late final AuthBloc _authBloc;
  late final CarpoolBloc _carpoolBloc;
  late final PlacesBloc _placesBloc;
  late final ProfileBloc _profileBloc;
  late final RouteSelectionBloc _routeSelectionBloc;
  late final StopoversBloc _stopoversBloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final storedLocal = widget.storedLocal ?? StoredLocal();
    final authLocalDataSource = AuthLocalDataSourceImpl(storedLocal: storedLocal);
    final authRepository = AuthRepositoryImpl(
      localDataSource: authLocalDataSource,
    );
    _authBloc = widget.authBloc ??
        (AuthBloc(
          authRepository: authRepository,
          getCurrentUserUseCase: GetCurrentUserUseCase(authRepository),
          sendPhoneOtpUseCase: SendPhoneOtpUseCase(authRepository),
          verifyPhoneOtpUseCase: VerifyPhoneOtpUseCase(authRepository),
          loginWithFacebookUseCase: LoginWithFacebookUseCase(authRepository),
          loginWithGoogleUseCase: LoginWithGoogleUseCase(authRepository),
          registerWithEmailUseCase: RegisterWithEmailUseCase(authRepository),
          continueAsGuestUseCase: ContinueAsGuestUseCase(authRepository),
          updateProfileNameUseCase: UpdateProfileNameUseCase(authRepository),
          updateSurveyPreferencesUseCase: UpdateSurveyPreferencesUseCase(authRepository),
          logoutUseCase: LogoutUseCase(authRepository),
          initialUser: widget.initialUser,
        )..add(CheckAuthStatusEvent()));

    final carpoolRemoteDataSource = CarpoolRemoteDataSourceImpl();
    final carpoolRepository = CarpoolRepositoryImpl(
      remoteDataSource: carpoolRemoteDataSource,
    );
    _carpoolBloc = widget.carpoolBloc ??
        (CarpoolBloc(
          getCarpoolRidesUseCase: GetCarpoolRidesUseCase(carpoolRepository),
          searchRidesUseCase: SearchRidesUseCase(carpoolRepository),
          publishRideUseCase: PublishRideUseCase(carpoolRepository),
          bookRideUseCase: BookRideUseCase(carpoolRepository),
          cancelBookingUseCase: CancelBookingUseCase(carpoolRepository),
          updateRideStatusUseCase: UpdateRideStatusUseCase(carpoolRepository),
          repository: carpoolRepository,
        )..add(const LoadCarpoolRidesEvent()));

    final placesRemoteDataSource = PlacesRemoteDataSourceImpl();
    final placesRepository = PlacesRepositoryImpl(
      remoteDataSource: placesRemoteDataSource,
    );
    _placesBloc = widget.placesBloc ??
        PlacesBloc(
          getPlacePredictionsUseCase:
              GetPlacePredictionsUseCase(placesRepository),
        );

    final profileLocalDataSource = ProfileLocalDataSourceImpl();
    final profileRepository = ProfileRepositoryImpl(
      localDataSource: profileLocalDataSource,
    );
    _profileBloc = widget.profileBloc ??
        (ProfileBloc(
          repository: profileRepository,
          getProfileUseCase: GetProfileUseCase(profileRepository),
          updateProfilePictureUseCase:
              UpdateProfilePictureUseCase(profileRepository),
        )..add(LoadProfileEvent()));

    final routesRemoteDataSource = RoutesRemoteDataSourceImpl();
    final routesRepository = RoutesRepositoryImpl(
      remoteDataSource: routesRemoteDataSource,
    );
    _routeSelectionBloc = RouteSelectionBloc(
      getRoutesUseCase: GetRoutesUseCase(routesRepository),
    );

    final stopoversRemoteDataSource = StopoversRemoteDataSourceImpl();
    final stopoversRepository = StopoversRepositoryImpl(
      remoteDataSource: stopoversRemoteDataSource,
    );
    _stopoversBloc = StopoversBloc(
      getStopoversUseCase: GetStopoversUseCase(stopoversRepository),
    );

    _router = AppRouter.createRouter(_authBloc);
  }

  @override
  void dispose() {
    if (widget.authBloc == null) {
      _authBloc.close();
    }
    if (widget.carpoolBloc == null) {
      _carpoolBloc.close();
    }
    if (widget.placesBloc == null) {
      _placesBloc.close();
    }
    if (widget.profileBloc == null) {
      _profileBloc.close();
    }
    _routeSelectionBloc.close();
    _stopoversBloc.close();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
        BlocProvider<CarpoolBloc>.value(value: _carpoolBloc),
        BlocProvider<PlacesBloc>.value(value: _placesBloc),
        BlocProvider<ProfileBloc>.value(value: _profileBloc),
        BlocProvider<RouteSelectionBloc>.value(value: _routeSelectionBloc),
        BlocProvider<StopoversBloc>.value(value: _stopoversBloc),
      ],
      child: MaterialApp.router(
        title: 'Carpool',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: _router,
      ),
    );
  }
}

