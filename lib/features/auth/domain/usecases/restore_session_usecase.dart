import '../../../../core/result/app_result.dart';
import '../../data/auth_repository.dart';
import '../entities/auth_session.dart';

class RestoreSessionUseCase {
  const RestoreSessionUseCase(this._repository);

  final AuthRepository _repository;

  Future<AppResult<AuthSession>> call() {
    return _repository.restoreSession();
  }
}
