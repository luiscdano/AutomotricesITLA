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
  static const Color _bg = Color(0xFF111111);
  static const Color _surface = Color(0xE6191919);
  static const Color _text = Colors.white;
  static const Color _muted = Color(0xFFBEBEBE);
  static const Color _fieldBg = Color(0xFF1F1F1F);
  static const Color _fieldBorder = Color(0xFF5A5A5A);
  static const Color _cream = Color(0xFFF4DBD3);
  static const Color _darkText = Color(0xFF2B1F1B);

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
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Olvidar contrasena'),
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
                    'Recuperar contrasena',
                    style: TextStyle(
                      color: _text,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Este flujo restablece la clave temporal de tu cuenta.',
                    style: TextStyle(color: _muted),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _matriculaController,
                    label: 'Matricula',
                    hint: '2024-0034',
                    textColor: _text,
                    fillColor: _fieldBg,
                    labelColor: _muted,
                    hintColor: const Color(0xFF7B7B7B),
                    borderColor: _fieldBorder,
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: 'Restablecer contrasena',
                    isLoading: controller.isBusy,
                    onPressed: _submit,
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
