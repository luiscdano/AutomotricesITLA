import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/feedback_banner.dart';
import '../../../public/presentation/screens/public_hub_screen.dart';
import '../controllers/auth_controller.dart';
import 'forgot_password_screen.dart';
import 'login_screen.dart';
import 'register_activate_screen.dart';

class PublicHomeScreen extends StatelessWidget {
  const PublicHomeScreen({super.key});

  static const Color _cardColor = Color(0xCC111111);
  static const Color _brown = Color(0xFF8E4A2D);
  static const Color _cream = Color(0xFFF4DBD3);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AuthController>();
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const Positioned.fill(child: ColoredBox(color: Colors.black)),
          Positioned.fill(
            child: Align(
              alignment: Alignment.topCenter,
              child: Image.asset(
                'assets/images/portada.png',
                width: screenWidth,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.08),
                    Colors.black.withValues(alpha: 0.35),
                    Colors.black.withValues(alpha: 0.88),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton.filledTonal(
                      tooltip: 'Explorar modulos publicos',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: 0.42),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const PublicHubScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.dashboard_customize_rounded),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Spacer(),
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
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _cardColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Column(
                      children: [
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            backgroundColor: _brown,
                            foregroundColor: Colors.white,
                          ),
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
                        const SizedBox(height: 10),
                        FilledButton.tonalIcon(
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            backgroundColor: _cream,
                            foregroundColor: const Color(0xFF2B1F1B),
                          ),
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
                        const SizedBox(height: 10),
                        FilledButton.tonalIcon(
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            backgroundColor: _cream,
                            foregroundColor: const Color(0xFF2B1F1B),
                          ),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
