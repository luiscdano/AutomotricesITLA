import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/private/data/private_repository.dart';
import 'features/auth/presentation/screens/auth_gate_screen.dart';
import 'features/public/data/public_repository.dart';

class AutomotricesApp extends StatelessWidget {
  const AutomotricesApp({
    super.key,
    required this.authController,
    required this.privateRepository,
    required this.publicRepository,
  });

  final AuthController authController;
  final PrivateRepository privateRepository;
  final PublicRepository publicRepository;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFCF4A00),
      brightness: Brightness.light,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>.value(value: authController),
        Provider<PrivateRepository>.value(value: privateRepository),
        Provider<PublicRepository>.value(value: publicRepository),
      ],
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
