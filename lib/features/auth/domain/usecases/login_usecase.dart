import '../../../../core/result/app_result.dart';
import '../../data/auth_repository.dart';
import '../entities/auth_session.dart';

class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<AppResult<AuthSession>> call({
    required String matricula,
    required String password,
  }) {
    return _repository.login(matricula: matricula, password: password);
  }
}
