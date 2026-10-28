import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfilePictureUseCase {
  final ProfileRepository repository;

  UpdateProfilePictureUseCase(this.repository);

  Future<ProfileEntity> call(String avatarUrl) async {
    return await repository.updateProfilePicture(avatarUrl);
  }
}
