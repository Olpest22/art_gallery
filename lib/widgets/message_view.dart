import 'package:flutter/material.dart';

/// Понятный текст вместо пустого экрана: ошибка, "ничего не найдено", пусто.
class MessageView extends StatelessWidget {
  final IconData icon;
  final String message;
  final VoidCallback? onRetry;

  const MessageView({
    super.key,
    required this.icon,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Повторить'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
