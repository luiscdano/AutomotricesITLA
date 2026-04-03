import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/feedback_banner.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color _bg = Color(0xFF111111);
  static const Color _surface = Color(0xE6191919);
  static const Color _text = Colors.white;
  static const Color _muted = Color(0xFFBEBEBE);
  static const Color _fieldBg = Color(0xFF1F1F1F);
  static const Color _fieldBorder = Color(0xFF5A5A5A);
  static const Color _brown = Color(0xFF8E4A2D);

  final TextEditingController _matriculaController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _matriculaController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final matricula = _matriculaController.text.trim();
    final password = _passwordController.text;

    if (matricula.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa matricula y contrasena.')),
      );
      return;
    }

    final ok = await context.read<AuthController>().login(
      matricula: matricula,
      password: password,
    );

    if (ok && mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Iniciar sesion'),
        backgroundColor: _bg,
        foregroundColor: _text,
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Accede con tu matricula ITLA',
                    style: TextStyle(
                      color: _text,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ingresa tus credenciales para continuar.',
                    style: TextStyle(color: _muted),
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: _matriculaController,
                    label: 'Matricula',
                    hint: '2024-0034',
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    textColor: _text,
                    fillColor: _fieldBg,
                    labelColor: _muted,
                    hintColor: const Color(0xFF7B7B7B),
                    borderColor: _fieldBorder,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _passwordController,
                    label: 'Contrasena',
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    textColor: _text,
                    fillColor: _fieldBg,
                    labelColor: _muted,
                    hintColor: const Color(0xFF7B7B7B),
                    borderColor: _fieldBorder,
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: 'Entrar',
                    isLoading: controller.isBusy,
                    onPressed: _submit,
                    backgroundColor: _brown,
                    foregroundColor: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
