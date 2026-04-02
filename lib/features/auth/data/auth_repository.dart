import '../../../core/result/app_result.dart';
import '../domain/entities/app_user.dart';
import '../domain/entities/auth_session.dart';

abstract class AuthRepository {
  Future<AppResult<String>> register({required String matricula});

  Future<AppResult<AuthSession>> activate({
    required String temporaryToken,
    required String password,
  });

  Future<AppResult<AuthSession>> login({
    required String matricula,
    required String password,
  });

  Future<AppResult<String>> forgotPassword({required String matricula});

  Future<AppResult<AuthSession>> refreshSession({required AppUser currentUser});

  Future<AppResult<AuthSession>> restoreSession();

  Future<AppResult<AppUser>> getProfile();

  Future<AppResult<void>> logout();
}
