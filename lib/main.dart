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
  final UserProfile? initialUser;
  final StoredLocal? storedLocal;

  const BlaBlaCarpoolApp({
    super.key,
    this.authBloc,
    this.carpoolBloc,
    this.placesBloc,
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

