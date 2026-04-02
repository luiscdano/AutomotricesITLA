import '../../../core/errors/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../core/result/app_result.dart';
import '../../../core/storage/token_storage.dart';
import '../domain/entities/app_user.dart';
import '../domain/entities/auth_session.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  }) : _apiClient = apiClient,
       _tokenStorage = tokenStorage;

  static const noSessionCode = 'NO_SESSION';

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  @override
  Future<AppResult<String>> register({required String matricula}) async {
    try {
      final envelope = await _apiClient.postDatax(
        '/auth/registro',
        data: {'matricula': matricula},
      );

      final data = _asMap(envelope.data);
      final temporaryToken = data['token']?.toString() ?? '';

      if (temporaryToken.isEmpty) {
        return AppResult.failure('No se recibio token temporal de activacion.');
      }

      return AppResult.success(temporaryToken);
    } on AppException catch (error) {
      return AppResult.failure(error.message);
    } catch (_) {
      return AppResult.failure('Error inesperado durante el registro.');
    }
  }

  @override
  Future<AppResult<AuthSession>> activate({
    required String temporaryToken,
    required String password,
  }) async {
    try {
      final envelope = await _apiClient.postDatax(
        '/auth/activar',
        data: {'token': temporaryToken, 'contrasena': password},
      );

      final session = _mapSession(_asMap(envelope.data));
      await _tokenStorage.saveTokens(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      );

      return AppResult.success(session);
    } on AppException catch (error) {
      return AppResult.failure(error.message);
    } catch (_) {
      return AppResult.failure('Error inesperado activando la cuenta.');
    }
  }

  @override
  Future<AppResult<AuthSession>> login({
    required String matricula,
    required String password,
  }) async {
    try {
      final envelope = await _apiClient.postDatax(
        '/auth/login',
        data: {'matricula': matricula, 'contrasena': password},
      );

      final session = _mapSession(_asMap(envelope.data));
      await _tokenStorage.saveTokens(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      );

      return AppResult.success(session);
    } on AppException catch (error) {
      return AppResult.failure(error.message);
    } catch (_) {
      return AppResult.failure('Error inesperado iniciando sesion.');
    }
  }

  @override
  Future<AppResult<String>> forgotPassword({required String matricula}) async {
    try {
      final envelope = await _apiClient.postDatax(
        '/auth/olvidar',
        data: {'matricula': matricula},
      );

      final message = envelope.message.isNotEmpty
          ? envelope.message
          : 'Contrasena temporal restablecida.';

      return AppResult.success(message);
    } on AppException catch (error) {
      return AppResult.failure(error.message);
    } catch (_) {
      return AppResult.failure('Error inesperado recuperando la contrasena.');
    }
  }

  @override
  Future<AppResult<AuthSession>> refreshSession({
    required AppUser currentUser,
  }) async {
    try {
      final refreshToken = await _tokenStorage.readRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        return AppResult.failure(
          'No hay refresh token disponible.',
          code: noSessionCode,
        );
      }

      final envelope = await _apiClient.postDatax(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final data = _asMap(envelope.data);
      final newAccessToken = data['token']?.toString() ?? '';
      final newRefreshToken = data['refreshToken']?.toString() ?? refreshToken;

      if (newAccessToken.isEmpty) {
        return AppResult.failure('El servidor no devolvio un token valido.');
      }

      await _tokenStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );

      return AppResult.success(
        AuthSession(
          user: currentUser,
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        ),
      );
    } on AppException catch (error) {
      return AppResult.failure(error.message);
    } catch (_) {
      return AppResult.failure('Error inesperado refrescando la sesion.');
    }
  }

  @override
  Future<AppResult<AuthSession>> restoreSession() async {
    try {
      final accessToken = await _tokenStorage.readAccessToken();
      final refreshToken = await _tokenStorage.readRefreshToken();

      if (accessToken == null || accessToken.isEmpty) {
        return AppResult.failure('No hay sesion activa.', code: noSessionCode);
      }

      final profileResult = await getProfile();
      if (profileResult.isFailure || profileResult.data == null) {
        await _tokenStorage.clear();
        return AppResult.failure(
          profileResult.errorMessage ?? 'Sesion no valida.',
          code: noSessionCode,
        );
      }

      return AppResult.success(
        AuthSession(
          user: profileResult.data!,
          accessToken: accessToken,
          refreshToken: refreshToken ?? '',
        ),
      );
    } catch (_) {
      await _tokenStorage.clear();
      return AppResult.failure(
        'No fue posible restaurar la sesion.',
        code: noSessionCode,
      );
    }
  }

  @override
  Future<AppResult<AppUser>> getProfile() async {
    try {
      final envelope = await _apiClient.get('/perfil', requiresAuth: true);
      final profileData = _asMap(envelope.data);
      return AppResult.success(AppUser.fromMap(profileData));
    } on AppException catch (error) {
      return AppResult.failure(error.message);
    } catch (_) {
      return AppResult.failure('Error inesperado consultando el perfil.');
    }
  }

  @override
  Future<AppResult<void>> logout() async {
    try {
      await _tokenStorage.clear();
      return AppResult.success(null);
    } catch (_) {
      return AppResult.failure('No fue posible cerrar sesion localmente.');
    }
  }

  AuthSession _mapSession(Map<String, dynamic> data) {
    final token = data['token']?.toString() ?? '';
    final refreshToken = data['refreshToken']?.toString() ?? '';

    if (token.isEmpty || refreshToken.isEmpty) {
      throw AppException('El servidor no devolvio tokens validos.');
    }

    final user = AppUser.fromMap(data);

    return AuthSession(
      user: user,
      accessToken: token,
      refreshToken: refreshToken,
    );
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return <String, dynamic>{};
  }
}
