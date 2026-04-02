import '../../../../core/result/app_result.dart';
import '../../data/auth_repository.dart';
import '../entities/app_user.dart';
import '../entities/auth_session.dart';

class RefreshSessionUseCase {
  const RefreshSessionUseCase(this._repository);

  final AuthRepository _repository;

  Future<AppResult<AuthSession>> call({required AppUser currentUser}) {
    return _repository.refreshSession(currentUser: currentUser);
  }
}
