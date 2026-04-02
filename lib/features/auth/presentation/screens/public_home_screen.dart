import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/app_config.dart';
import '../../../../shared/widgets/feedback_banner.dart';
import 'forgot_password_screen.dart';
import 'login_screen.dart';
import 'register_activate_screen.dart';
import '../controllers/auth_controller.dart';

class PublicHomeScreen extends StatelessWidget {
  const PublicHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AuthController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Automotrices ITLA')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fase 1 lista para pruebas de autenticacion',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'API: ${AppConfig.apiBaseUrl}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              if (controller.errorMessage != null)
                FeedbackBanner(
                  message: controller.errorMessage!,
                  isError: true,
                ),
              if (controller.infoMessage != null)
                FeedbackBanner(
                  message: controller.infoMessage!,
                  isError: false,
                ),
              const SizedBox(height: 8),
              const Text(
                'Desde aqui puedes ejecutar todo el flujo base: registro, activacion, login, recuperacion y cambio de estado de sesion.',
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const LoginScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.login),
                label: const Text('Iniciar sesion'),
              ),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const RegisterActivateScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('Registro y activacion'),
              ),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ForgotPasswordScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.lock_reset),
                label: const Text('Olvidar contrasena'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
