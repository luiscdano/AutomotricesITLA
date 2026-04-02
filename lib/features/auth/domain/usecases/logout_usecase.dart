import '../../../../core/result/app_result.dart';
import '../../data/auth_repository.dart';

class LogoutUseCase {
  const LogoutUseCase(this._repository);

  final AuthRepository _repository;

  Future<AppResult<void>> call() {
    return _repository.logout();
  }
}
