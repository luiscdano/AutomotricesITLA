import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/app_config.dart';
import '../../../../shared/widgets/feedback_banner.dart';
import '../../../private/presentation/screens/private_hub_screen.dart';
import '../../../public/presentation/screens/public_hub_screen.dart';
import '../controllers/auth_controller.dart';

class AuthenticatedHomeScreen extends StatelessWidget {
  const AuthenticatedHomeScreen({super.key});

  static const Color _bg = Color(0xFF101010);
  static const Color _card = Color(0xCC121212);
  static const Color _text = Colors.white;
  static const Color _muted = Color(0xFFBEBEBE);
  static const Color _brown = Color(0xFF8E4A2D);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AuthController>();
    final user = controller.currentUser;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Sesion autenticada'),
        backgroundColor: _bg,
        foregroundColor: _text,
        actions: [
          IconButton(
            tooltip: 'Cerrar sesion',
            onPressed: controller.isBusy
                ? null
                : () {
                    context.read<AuthController>().logout();
                  },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (controller.errorMessage != null)
              FeedbackBanner(message: controller.errorMessage!, isError: true),
            if (controller.infoMessage != null)
              FeedbackBanner(message: controller.infoMessage!, isError: false),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.displayName ?? 'Usuario autenticado',
                    style: const TextStyle(
                      color: _text,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Correo: ${user?.correo ?? '-'}',
                    style: const TextStyle(color: _muted),
                  ),
                  Text(
                    'Matricula: ${user?.matricula ?? '-'}',
                    style: const TextStyle(color: _muted),
                  ),
                  Text(
                    'Rol: ${user?.rol ?? '-'} | Grupo: ${user?.grupo ?? '-'}',
                    style: const TextStyle(color: _muted),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'API: ${AppConfig.apiBaseUrl}',
                    style: const TextStyle(color: _muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: _brown),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const PrivateHubScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.shield_rounded),
                label: const Text('Abrir Fases 3 y 4 (area privada)'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const PublicHubScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.dashboard_customize_rounded),
                label: const Text('Abrir Fase 2 (modulos publicos)'),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.tonalIcon(
              onPressed: controller.isBusy
                  ? null
                  : () {
                      context.read<AuthController>().syncProfile();
                    },
              icon: const Icon(Icons.person_search),
              label: const Text('Sincronizar perfil (/perfil)'),
            ),
            const SizedBox(height: 8),
            FilledButton.tonalIcon(
              onPressed: controller.isBusy
                  ? null
                  : () {
                      context.read<AuthController>().refreshToken();
                    },
              icon: const Icon(Icons.refresh),
              label: const Text('Refrescar token (/auth/refresh)'),
            ),
          ],
        ),
      ),
    );
  }
}
