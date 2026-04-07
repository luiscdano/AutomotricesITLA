import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/feedback_banner.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../controllers/auth_controller.dart';

class RegisterActivateScreen extends StatefulWidget {
  const RegisterActivateScreen({super.key});

  @override
  State<RegisterActivateScreen> createState() => _RegisterActivateScreenState();
}

class _RegisterActivateScreenState extends State<RegisterActivateScreen> {
  static const Color _bg = Color(0xFF111111);
  static const Color _surface = Color(0xE6191919);
  static const Color _text = Colors.white;
  static const Color _muted = Color(0xFFBEBEBE);
  static const Color _fieldBg = Color(0xFF1F1F1F);
  static const Color _fieldBorder = Color(0xFF5A5A5A);
  static const Color _brown = Color(0xFF8E4A2D);
  static const Color _cream = Color(0xFFF4DBD3);
  static const Color _darkText = Color(0xFF2B1F1B);

  final TextEditingController _matriculaController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _matriculaController.dispose();
    _tokenController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final matricula = _matriculaController.text.trim();

    if (matricula.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa una matrícula valida.')),
      );
      return;
    }

    final ok = await context.read<AuthController>().register(
      matricula: matricula,
    );
    if (ok && mounted) {
      final token = context.read<AuthController>().temporaryActivationToken;
      if (token != null && token.isNotEmpty) {
        _tokenController.text = token;
      }
    }
  }

  Future<void> _activate() async {
    final token = _tokenController.text.trim();
    final password = _passwordController.text;

    if (token.isEmpty || password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Token requerido y contrasena minimo 6 caracteres.'),
        ),
      );
      return;
    }

    final ok = await context.read<AuthController>().activate(
      temporaryToken: token,
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
        title: const Text('Registro y activación'),
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
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Paso 1: Registrar matrícula',
                    style: TextStyle(
                      color: _text,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _matriculaController,
                    label: 'Matrícula',
                    hint: '2024-0034',
                    textInputAction: TextInputAction.done,
                    textColor: _text,
                    fillColor: _fieldBg,
                    labelColor: _muted,
                    hintColor: const Color(0xFF7B7B7B),
                    borderColor: _fieldBorder,
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: 'Solicitar token temporal',
                    isLoading: controller.isBusy,
                    onPressed: _register,
                    backgroundColor: _brown,
                    foregroundColor: Colors.white,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Paso 2: Activar cuenta',
                    style: TextStyle(
                      color: _text,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _tokenController,
                    label: 'Token temporal',
                    hint: 'Pega el token recibido en registro',
                    textColor: _text,
                    fillColor: _fieldBg,
                    labelColor: _muted,
                    hintColor: const Color(0xFF7B7B7B),
                    borderColor: _fieldBorder,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _passwordController,
                    label: 'Contraseña nueva',
                    obscureText: true,
                    textColor: _text,
                    fillColor: _fieldBg,
                    labelColor: _muted,
                    hintColor: const Color(0xFF7B7B7B),
                    borderColor: _fieldBorder,
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: 'Activar y entrar',
                    isLoading: controller.isBusy,
                    onPressed: _activate,
                    backgroundColor: _cream,
                    foregroundColor: _darkText,
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
