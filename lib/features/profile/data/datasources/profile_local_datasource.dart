import '../../domain/entities/profile_entity.dart';

abstract class ProfileLocalDataSource {
  Future<ProfileEntity> getProfile();
  Future<ProfileEntity> saveProfile(ProfileEntity profile);
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  ProfileEntity _cachedProfile = const ProfileEntity(
    name: 'Venkatesh',
    subtitle: 'Newcomer',
    avatarUrl: null,
    completedSteps: 1,
    totalSteps: 6,
    email: 'venkateshdigitalraiz@gmail.com',
    isEmailConfirmed: false,
    phoneNumber: '+919052575626',
    isPhoneVerified: true,
    isGovtIdVerified: false,
    reliabilityBadge: 'Never cancels bookings as a passenger',
  );

  @override
  Future<ProfileEntity> getProfile() async {
    return _cachedProfile;
  }

  @override
  Future<ProfileEntity> saveProfile(ProfileEntity profile) async {
    _cachedProfile = profile;
    return _cachedProfile;
  }
}
