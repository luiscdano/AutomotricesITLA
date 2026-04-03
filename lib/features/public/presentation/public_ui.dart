import 'package:flutter/material.dart';

class PublicUi {
  const PublicUi._();

  static const Color bg = Color(0xFF101010);
  static const Color surface = Color(0xE6191919);
  static const Color card = Color(0xCC111111);
  static const Color text = Colors.white;
  static const Color muted = Color(0xFFBEBEBE);
  static const Color brown = Color(0xFF8E4A2D);
  static const Color cream = Color(0xFFF4DBD3);
  static const Color darkText = Color(0xFF2B1F1B);

  static BoxDecoration cardDecoration() {
    return BoxDecoration(
      color: card,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
    );
  }
}

class PublicErrorView extends StatelessWidget {
  const PublicErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 42),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: PublicUi.text),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(backgroundColor: PublicUi.brown),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class PublicEmptyView extends StatelessWidget {
  const PublicEmptyView({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: PublicUi.muted),
        ),
      ),
    );
  }
}
