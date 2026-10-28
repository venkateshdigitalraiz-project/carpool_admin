import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource localDataSource;

  ProfileRepositoryImpl({required this.localDataSource});

  @override
  Future<ProfileEntity> getProfile() async {
    return await localDataSource.getProfile();
  }

  @override
  Future<ProfileEntity> updateProfilePicture(String avatarUrl) async {
    final current = await localDataSource.getProfile();
    final updated = current.copyWith(
      avatarUrl: avatarUrl,
      // If photo was not set before, increment completed steps
      completedSteps: current.avatarUrl == null
          ? (current.completedSteps + 1).clamp(1, current.totalSteps)
          : current.completedSteps,
    );
    return await localDataSource.saveProfile(updated);
  }

  @override
  Future<ProfileEntity> verifyGovtId(String idDocument) async {
    final current = await localDataSource.getProfile();
    final updated = current.copyWith(
      isGovtIdVerified: true,
      completedSteps: !current.isGovtIdVerified
          ? (current.completedSteps + 1).clamp(1, current.totalSteps)
          : current.completedSteps,
    );
    return await localDataSource.saveProfile(updated);
  }

  @override
  Future<ProfileEntity> confirmEmail() async {
    final current = await localDataSource.getProfile();
    final updated = current.copyWith(
      isEmailConfirmed: true,
      completedSteps: !current.isEmailConfirmed
          ? (current.completedSteps + 1).clamp(1, current.totalSteps)
          : current.completedSteps,
    );
    return await localDataSource.saveProfile(updated);
  }

  @override
  Future<ProfileEntity> updatePersonalDetails({
    required String name,
    required String email,
  }) async {
    final current = await localDataSource.getProfile();
    final updated = current.copyWith(
      name: name,
      email: email,
    );
    return await localDataSource.saveProfile(updated);
  }

  @override
  Future<ProfileEntity> updatePostalAddress(String address) async {
    final current = await localDataSource.getProfile();
    final updated = current.copyWith(postalAddress: address);
    return await localDataSource.saveProfile(updated);
  }

  @override
  Future<ProfileEntity> updateCommunicationPreferences({
    required bool push,
    required bool email,
    required bool sms,
  }) async {
    final current = await localDataSource.getProfile();
    final updated = current.copyWith(
      pushNotifications: push,
      emailNotifications: email,
      smsNotifications: sms,
    );
    return await localDataSource.saveProfile(updated);
  }

  @override
  Future<ProfileEntity> updatePayoutMethod(String method) async {
    final current = await localDataSource.getProfile();
    final updated = current.copyWith(payoutMethod: method);
    return await localDataSource.saveProfile(updated);
  }

  @override
  Future<ProfileEntity> updatePaymentMethod(String method) async {
    final current = await localDataSource.getProfile();
    final updated = current.copyWith(paymentMethod: method);
    return await localDataSource.saveProfile(updated);
  }
}
