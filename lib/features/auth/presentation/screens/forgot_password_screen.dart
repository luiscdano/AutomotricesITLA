import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/feedback_banner.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../controllers/auth_controller.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _matriculaController = TextEditingController();

  @override
  void dispose() {
    _matriculaController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final matricula = _matriculaController.text.trim();
    if (matricula.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa la matricula para continuar.')),
      );
      return;
    }

    await context.read<AuthController>().forgotPassword(matricula: matricula);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AuthController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Olvidar contrasena')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (controller.errorMessage != null)
              FeedbackBanner(message: controller.errorMessage!, isError: true),
            if (controller.infoMessage != null)
              FeedbackBanner(message: controller.infoMessage!, isError: false),
            const Text(
              'Este flujo restablece la clave a una temporal en el API.',
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _matriculaController,
              label: 'Matricula',
              hint: '2024-0034',
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Restablecer contrasena',
              isLoading: controller.isBusy,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
