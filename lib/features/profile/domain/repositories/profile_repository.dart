import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity> getProfile();
  Future<ProfileEntity> updateProfilePicture(String avatarUrl);
  Future<ProfileEntity> verifyGovtId(String idDocument);
  Future<ProfileEntity> confirmEmail();
  Future<ProfileEntity> updatePersonalDetails({
    required String name,
    required String email,
  });
  Future<ProfileEntity> updatePostalAddress(String address);
  Future<ProfileEntity> updateCommunicationPreferences({
    required bool push,
    required bool email,
    required bool sms,
  });
  Future<ProfileEntity> updatePayoutMethod(String method);
  Future<ProfileEntity> updatePaymentMethod(String method);
}
