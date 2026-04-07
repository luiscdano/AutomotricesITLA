import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/feedback_banner.dart';
import '../../../public/presentation/screens/public_hub_screen.dart';
import '../controllers/auth_controller.dart';
import 'forgot_password_screen.dart';
import 'login_screen.dart';
import 'register_activate_screen.dart';

class PublicHomeScreen extends StatefulWidget {
  const PublicHomeScreen({super.key});

  @override
  State<PublicHomeScreen> createState() => _PublicHomeScreenState();
}

class _PublicHomeScreenState extends State<PublicHomeScreen> {
  static const Color _cardColor = Color(0xCC111111);
  static const Color _brown = Color(0xFF8E4A2D);
  static const Color _cream = Color(0xFFF4DBD3);

  
  static const List<_Slide> _slides = [
    _Slide(asset: 'assets/images/portada.png',   frase: null),
    _Slide(asset: 'assets/images/auto1.png',      frase: 'Tu vehículo, tu responsabilidad.\nCuídalo como se merece.'),
    _Slide(asset: 'assets/images/auto2.png',      frase: 'Un motor bien mantenido\nes sinónimo de seguridad.'),
    _Slide(asset: 'assets/images/auto3.png',      frase: 'El mantenimiento preventivo\nte ahorra tiempo y dinero.'),
    _Slide(asset: 'assets/images/auto4.png',      frase: 'Conduce con confianza.\nRevisa tu vehículo hoy.'),
  ];

  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      final next = (_currentPage + 1) % _slides.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AuthController>();
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [

          // ── SLIDER DE FONDO ──────────────────────────────────────────────
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemCount: _slides.length,
              itemBuilder: (context, index) {
                final slide = _slides[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      slide.asset,
                      width: screenWidth,
                      fit: BoxFit.cover,
                    ),
                    // Gradiente sobre cada slide
                    DecoratedBox(
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
                    // Frase encima de la imagen (si tiene)
                    if (slide.frase != null)
                      Positioned(
                        top: 120,
                        left: 24,
                        right: 24,
                        child: Text(
                          slide.frase!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            height: 1.4,
                            shadows: [
                              Shadow(
                                blurRadius: 12,
                                color: Colors.black,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),

          Positioned(
            bottom: 220,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (i) {
                final active = i == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? _brown : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
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

class _Slide {
  const _Slide({required this.asset, required this.frase});
  final String asset;
  final String? frase;
}