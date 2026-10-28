import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_picture_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository repository;
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfilePictureUseCase updateProfilePictureUseCase;

  ProfileBloc({
    required this.repository,
    required this.getProfileUseCase,
    required this.updateProfilePictureUseCase,
  }) : super(const ProfileState()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateProfilePictureEvent>(_onUpdateProfilePicture);
    on<VerifyGovtIdEvent>(_onVerifyGovtId);
    on<ConfirmEmailEvent>(_onConfirmEmail);
    on<UpdatePersonalDetailsEvent>(_onUpdatePersonalDetails);
    on<UpdatePostalAddressEvent>(_onUpdatePostalAddress);
    on<UpdateCommunicationPreferencesEvent>(_onUpdateCommunicationPreferences);
    on<UpdatePayoutMethodEvent>(_onUpdatePayoutMethod);
    on<UpdatePaymentMethodEvent>(_onUpdatePaymentMethod);
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final profile = await getProfileUseCase();
      emit(state.copyWith(status: ProfileStatus.loaded, profile: profile));
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.error,
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateProfilePicture(
    UpdateProfilePictureEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final updated = await updateProfilePictureUseCase(event.avatarUrl);
      emit(
        state.copyWith(
          status: ProfileStatus.loaded,
          profile: updated,
          message: 'Profile picture updated successfully!',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.error,
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> _onVerifyGovtId(
    VerifyGovtIdEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final updated = await repository.verifyGovtId(event.idDocument);
      emit(
        state.copyWith(
          status: ProfileStatus.loaded,
          profile: updated,
          message: 'Govt. ID verified successfully!',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.error,
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> _onConfirmEmail(
    ConfirmEmailEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final updated = await repository.confirmEmail();
      emit(
        state.copyWith(
          status: ProfileStatus.loaded,
          profile: updated,
          message: 'Confirmation email sent!',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.error,
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdatePersonalDetails(
    UpdatePersonalDetailsEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final updated = await repository.updatePersonalDetails(
        name: event.name,
        email: event.email,
      );
      emit(
        state.copyWith(
          status: ProfileStatus.loaded,
          profile: updated,
          message: 'Personal details updated!',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.error,
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdatePostalAddress(
    UpdatePostalAddressEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final updated = await repository.updatePostalAddress(event.address);
      emit(
        state.copyWith(
          status: ProfileStatus.loaded,
          profile: updated,
          message: 'Postal address updated successfully!',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.error,
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateCommunicationPreferences(
    UpdateCommunicationPreferencesEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final updated = await repository.updateCommunicationPreferences(
        push: event.push,
        email: event.email,
        sms: event.sms,
      );
      emit(
        state.copyWith(
          status: ProfileStatus.loaded,
          profile: updated,
          message: 'Communication preferences updated!',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.error,
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdatePayoutMethod(
    UpdatePayoutMethodEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final updated = await repository.updatePayoutMethod(event.method);
      emit(
        state.copyWith(
          status: ProfileStatus.loaded,
          profile: updated,
          message: 'Payout method updated!',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.error,
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdatePaymentMethod(
    UpdatePaymentMethodEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final updated = await repository.updatePaymentMethod(event.method);
      emit(
        state.copyWith(
          status: ProfileStatus.loaded,
          profile: updated,
          message: 'Payment method updated!',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.error,
          message: e.toString(),
        ),
      );
    }
  }
}
