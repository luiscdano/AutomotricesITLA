import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/feedback_banner.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../private_ui.dart';
import 'profile_screen.dart';
import 'vehicles_screen.dart';

class PrivateHubScreen extends StatelessWidget {
  const PrivateHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AuthController>();
    final user = controller.currentUser;

    return Scaffold(
      backgroundColor: PrivateUi.bg,
      appBar: AppBar(
        title: const Text('Fase 3 - Perfil y vehiculos'),
        backgroundColor: PrivateUi.bg,
        foregroundColor: PrivateUi.text,
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
              decoration: PrivateUi.cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.displayName ?? 'Usuario autenticado',
                    style: const TextStyle(
                      color: PrivateUi.text,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Matricula: ${user?.matricula ?? '-'}',
                    style: const TextStyle(color: PrivateUi.muted),
                  ),
                  Text(
                    'Correo: ${user?.correo ?? '-'}',
                    style: const TextStyle(color: PrivateUi.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _HubTile(
                  icon: Icons.person_rounded,
                  title: 'Mi perfil',
                  subtitle: 'Consultar y cambiar foto',
                  onTap: () => _push(context, const ProfileScreen()),
                ),
                _HubTile(
                  icon: Icons.directions_car_filled_rounded,
                  title: 'Mis vehiculos',
                  subtitle: 'CRUD + fotos + detalle',
                  onTap: () => _push(context, const VehiclesScreen()),
                ),
              ],
            ),
            const SizedBox(height: 14),
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

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }
}

class _HubTile extends StatelessWidget {
  const _HubTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        decoration: PrivateUi.cardDecoration(),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: PrivateUi.cream),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: PrivateUi.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: PrivateUi.muted, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
