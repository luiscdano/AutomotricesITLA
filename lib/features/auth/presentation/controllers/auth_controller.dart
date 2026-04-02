import 'package:flutter/foundation.dart';

import '../../../../core/result/app_result.dart';
import '../../data/auth_repository_impl.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/usecases/activate_account_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/refresh_session_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/restore_session_usecase.dart';

enum AuthStatus { initializing, unauthenticated, authenticated }

class AuthController extends ChangeNotifier {
  AuthController({
    required RegisterUseCase registerUseCase,
    required ActivateAccountUseCase activateAccountUseCase,
    required LoginUseCase loginUseCase,
    required ForgotPasswordUseCase forgotPasswordUseCase,
    required RefreshSessionUseCase refreshSessionUseCase,
    required RestoreSessionUseCase restoreSessionUseCase,
    required GetProfileUseCase getProfileUseCase,
    required LogoutUseCase logoutUseCase,
  }) : _registerUseCase = registerUseCase,
       _activateAccountUseCase = activateAccountUseCase,
       _loginUseCase = loginUseCase,
       _forgotPasswordUseCase = forgotPasswordUseCase,
       _refreshSessionUseCase = refreshSessionUseCase,
       _restoreSessionUseCase = restoreSessionUseCase,
       _getProfileUseCase = getProfileUseCase,
       _logoutUseCase = logoutUseCase;

  final RegisterUseCase _registerUseCase;
  final ActivateAccountUseCase _activateAccountUseCase;
  final LoginUseCase _loginUseCase;
  final ForgotPasswordUseCase _forgotPasswordUseCase;
  final RefreshSessionUseCase _refreshSessionUseCase;
  final RestoreSessionUseCase _restoreSessionUseCase;
  final GetProfileUseCase _getProfileUseCase;
  final LogoutUseCase _logoutUseCase;

  AuthStatus _status = AuthStatus.initializing;
  bool _isBusy = false;
  String? _errorMessage;
  String? _infoMessage;
  String? _temporaryActivationToken;
  AuthSession? _session;

  AuthStatus get status => _status;
  bool get isBusy => _isBusy;
  bool get isAuthenticated =>
      _status == AuthStatus.authenticated && _session != null;

  String? get errorMessage => _errorMessage;
  String? get infoMessage => _infoMessage;
  String? get temporaryActivationToken => _temporaryActivationToken;
  AuthSession? get session => _session;
  AppUser? get currentUser => _session?.user;

  Future<void> bootstrap() async {
    _status = AuthStatus.initializing;
    notifyListeners();

    final result = await _restoreSessionUseCase();
    if (result.isSuccess && result.data != null) {
      _session = result.data;
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      _infoMessage = 'Sesion restaurada.';
    } else {
      _session = null;
      _status = AuthStatus.unauthenticated;
      if (result.errorCode != AuthRepositoryImpl.noSessionCode) {
        _errorMessage = result.errorMessage;
      }
    }

    notifyListeners();
  }

  void clearFeedback() {
    _errorMessage = null;
    _infoMessage = null;
    notifyListeners();
  }

  Future<bool> register({required String matricula}) async {
    _startAction();
    final result = await _registerUseCase(matricula: matricula.trim());

    if (result.isSuccess && result.data != null) {
      _temporaryActivationToken = result.data;
      _infoMessage =
          'Registro exitoso. Usa el token temporal para activar la cuenta.';
      _finishAction(success: true);
      return true;
    }

    _finishAction(error: result.errorMessage);
    return false;
  }

  Future<bool> activate({
    required String temporaryToken,
    required String password,
  }) async {
    _startAction();
    final result = await _activateAccountUseCase(
      temporaryToken: temporaryToken.trim(),
      password: password,
    );

    if (result.isSuccess && result.data != null) {
      _session = result.data;
      _status = AuthStatus.authenticated;
      _temporaryActivationToken = null;
      _infoMessage = 'Cuenta activada correctamente.';
      _finishAction(success: true, notifyStatus: false);
      return true;
    }

    _finishAction(error: result.errorMessage);
    return false;
  }

  Future<bool> login({
    required String matricula,
    required String password,
  }) async {
    _startAction();
    final result = await _loginUseCase(
      matricula: matricula.trim(),
      password: password,
    );

    if (result.isSuccess && result.data != null) {
      _session = result.data;
      _status = AuthStatus.authenticated;
      _infoMessage = 'Bienvenido ${result.data!.user.displayName}.';
      _finishAction(success: true, notifyStatus: false);
      return true;
    }

    _finishAction(error: result.errorMessage);
    return false;
  }

  Future<bool> forgotPassword({required String matricula}) async {
    _startAction();
    final result = await _forgotPasswordUseCase(matricula: matricula.trim());

    if (result.isSuccess) {
      _infoMessage = result.data ?? 'Contrasena temporal restablecida.';
      _finishAction(success: true);
      return true;
    }

    _finishAction(error: result.errorMessage);
    return false;
  }

  Future<bool> refreshToken() async {
    if (_session == null) {
      _errorMessage = 'No hay una sesion activa para refrescar.';
      notifyListeners();
      return false;
    }

    _startAction();
    final result = await _refreshSessionUseCase(currentUser: _session!.user);

    if (result.isSuccess && result.data != null) {
      _session = result.data;
      _infoMessage = 'Token renovado correctamente.';
      _finishAction(success: true);
      return true;
    }

    _finishAction(error: result.errorMessage);
    return false;
  }

  Future<bool> syncProfile() async {
    if (_session == null) {
      _errorMessage = 'Debes iniciar sesion para consultar el perfil.';
      notifyListeners();
      return false;
    }

    _startAction();
    final AppResult<AppUser> result = await _getProfileUseCase();

    if (result.isSuccess && result.data != null) {
      _session = _session!.copyWith(user: result.data!);
      _infoMessage = 'Perfil actualizado desde el API.';
      _finishAction(success: true);
      return true;
    }

    _finishAction(error: result.errorMessage);
    return false;
  }

  Future<void> logout() async {
    _startAction();
    await _logoutUseCase();

    _session = null;
    _status = AuthStatus.unauthenticated;
    _temporaryActivationToken = null;
    _infoMessage = 'Sesion cerrada localmente.';
    _finishAction(success: true, notifyStatus: false);
  }

  void _startAction() {
    _isBusy = true;
    _errorMessage = null;
    _infoMessage = null;
    notifyListeners();
  }

  void _finishAction({
    bool success = false,
    String? error,
    bool notifyStatus = true,
  }) {
    _isBusy = false;
    if (!success) {
      _errorMessage = error ?? 'No fue posible completar la operacion.';
    }
    if (notifyStatus) {
      notifyListeners();
    } else {
      notifyListeners();
    }
  }
}
