import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openExternalUrl(BuildContext context, String rawUrl) async {
  final uri = Uri.tryParse(rawUrl);

  if (uri == null) {
    _showError(context, 'URL no valida: $rawUrl');
    return;
  }

  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!launched && context.mounted) {
    _showError(context, 'No se pudo abrir el enlace.');
  }
}

void _showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
