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
        const SnackBar(content: Text('Ingresa una matricula valida.')),
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
      appBar: AppBar(title: const Text('Registro y activacion')),
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
                      'Paso 1: Registrar matricula',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _matriculaController,
                      label: 'Matricula',
                      hint: '2024-0034',
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      label: 'Solicitar token temporal',
                      isLoading: controller.isBusy,
                      onPressed: _register,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paso 2: Activar cuenta',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _tokenController,
                      label: 'Token temporal',
                      hint: 'Pega el token recibido en registro',
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _passwordController,
                      label: 'Contrasena nueva',
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      label: 'Activar y entrar',
                      isLoading: controller.isBusy,
                      onPressed: _activate,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
