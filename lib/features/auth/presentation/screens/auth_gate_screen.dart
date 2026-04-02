import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import 'authenticated_home_screen.dart';
import 'public_home_screen.dart';

class AuthGateScreen extends StatelessWidget {
  const AuthGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, controller, _) {
        switch (controller.status) {
          case AuthStatus.initializing:
            return const _SplashScreen();
          case AuthStatus.authenticated:
            return const AuthenticatedHomeScreen();
          case AuthStatus.unauthenticated:
            return const PublicHomeScreen();
        }
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Restaurando sesion...'),
          ],
        ),
      ),
    );
  }
}
