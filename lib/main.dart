import 'package:flutter/material.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/network/api_client.dart';
import 'core/storage/token_storage.dart';
import 'features/auth/data/auth_repository_impl.dart';
import 'features/auth/domain/usecases/activate_account_usecase.dart';
import 'features/auth/domain/usecases/forgot_password_usecase.dart';
import 'features/auth/domain/usecases/get_profile_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/refresh_session_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/domain/usecases/restore_session_usecase.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final tokenStorage = TokenStorage();
  final apiClient = ApiClient(
    baseUrl: AppConfig.apiBaseUrl,
    tokenStorage: tokenStorage,
  );

  final authRepository = AuthRepositoryImpl(
    apiClient: apiClient,
    tokenStorage: tokenStorage,
  );

  final authController = AuthController(
    registerUseCase: RegisterUseCase(authRepository),
    activateAccountUseCase: ActivateAccountUseCase(authRepository),
    loginUseCase: LoginUseCase(authRepository),
    forgotPasswordUseCase: ForgotPasswordUseCase(authRepository),
    refreshSessionUseCase: RefreshSessionUseCase(authRepository),
    restoreSessionUseCase: RestoreSessionUseCase(authRepository),
    getProfileUseCase: GetProfileUseCase(authRepository),
    logoutUseCase: LogoutUseCase(authRepository),
  )..bootstrap();

  runApp(AutomotricesApp(authController: authController));
}
