import '../../../../core/result/app_result.dart';
import '../../data/auth_repository.dart';

class ForgotPasswordUseCase {
  const ForgotPasswordUseCase(this._repository);

  final AuthRepository _repository;

  Future<AppResult<String>> call({required String matricula}) {
    return _repository.forgotPassword(matricula: matricula);
  }
}
