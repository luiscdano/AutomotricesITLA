import '../../../../core/result/app_result.dart';
import '../../data/auth_repository.dart';
import '../entities/auth_session.dart';

class ActivateAccountUseCase {
  const ActivateAccountUseCase(this._repository);

  final AuthRepository _repository;

  Future<AppResult<AuthSession>> call({
    required String temporaryToken,
    required String password,
  }) {
    return _repository.activate(
      temporaryToken: temporaryToken,
      password: password,
    );
  }
}
