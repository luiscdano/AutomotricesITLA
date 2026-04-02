import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/auth/presentation/screens/auth_gate_screen.dart';

class AutomotricesApp extends StatelessWidget {
  const AutomotricesApp({super.key, required this.authController});

  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFCF4A00),
      brightness: Brightness.light,
    );

    return ChangeNotifierProvider<AuthController>.value(
      value: authController,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Automotrices ITLA',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: colorScheme,
          appBarTheme: const AppBarTheme(centerTitle: false),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
          ),
        ),
        home: const AuthGateScreen(),
      ),
    );
  }
}
