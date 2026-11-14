import 'package:flutter/material.dart';

/// Стан «завантаження».
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text('Завантаження даних теплиці…', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Датчики, пороги та підсумок за добу — паралельно',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Стан «помилка» з кнопкою «Повторити».
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('Не вдалося завантажити дані', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Повторити'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Стан «порожньо».
class EmptyView extends StatelessWidget {
  const EmptyView({super.key, required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sensors_off, size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text('У теплиці ще немає датчиків', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
              'Підключіть датчики на контролері теплиці та оновіть сторінку.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Оновити'),
            ),
          ],
        ),
      ),
    );
  }
}
