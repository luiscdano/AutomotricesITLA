import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/app_config.dart';
import '../../../../shared/widgets/feedback_banner.dart';
import '../controllers/auth_controller.dart';

class AuthenticatedHomeScreen extends StatelessWidget {
  const AuthenticatedHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AuthController>();
    final user = controller.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sesion autenticada'),
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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? 'Usuario autenticado',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('Correo: ${user?.correo ?? '-'}'),
                    Text('Matricula: ${user?.matricula ?? '-'}'),
                    Text('Rol: ${user?.rol ?? '-'}'),
                    Text('Grupo: ${user?.grupo ?? '-'}'),
                    const SizedBox(height: 8),
                    Text('API activa: ${AppConfig.apiBaseUrl}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
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
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: controller.isBusy
                  ? null
                  : () {
                      context.read<AuthController>().logout();
                    },
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar sesion local'),
            ),
          ],
        ),
      ),
    );
  }
}
