import '../../../../core/result/app_result.dart';
import '../../data/auth_repository.dart';

class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<AppResult<String>> call({required String matricula}) {
    return _repository.register(matricula: matricula);
  }
}
