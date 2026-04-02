import '../../../../core/result/app_result.dart';
import '../../data/auth_repository.dart';
import '../entities/app_user.dart';

class GetProfileUseCase {
  const GetProfileUseCase(this._repository);

  final AuthRepository _repository;

  Future<AppResult<AppUser>> call() {
    return _repository.getProfile();
  }
}
