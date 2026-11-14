import 'package:flutter/material.dart';

import '../models/greenhouse_models.dart';
import '../services/sensor_feed.dart';

/// Картка датчика: показання в реальному часі через StreamBuilder.
class SensorCard extends StatelessWidget {
  const SensorCard({
    super.key,
    required this.feed,
    required this.threshold,
    required this.paused,
  });

  final SensorFeed feed;
  final SensorThreshold? threshold;
  final bool paused;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sensor = feed.sensor;

    return StreamBuilder<SensorReading>(
      stream: feed.stream,
      initialData: feed.lastReading,
      builder: (context, snapshot) {
        final failed = snapshot.hasError;
        // При помилці показуємо останнє відоме значення.
        final reading = failed ? feed.lastReading : snapshot.data;
        final exceeded = !failed &&
            reading != null &&
            (threshold?.isExceeded(reading.value) ?? false);

        final Color accent = failed
            ? Colors.orange.shade700
            : exceeded
                ? Colors.red.shade700
                : Colors.green.shade600;
        final Color? background = failed
            ? Colors.orange.shade50
            : exceeded
                ? Colors.red.shade50
                : null;

        return Card(
          color: background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: accent, width: failed || exceeded ? 2 : 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(_iconFor(sensor.kind), color: accent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(sensor.name, style: theme.textTheme.titleMedium),
                    ),
                    if (paused)
                      const Chip(
                        label: Text('Пауза'),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (reading == null && !failed) ...[
                  const Text('Очікування показань…'),
                  const SizedBox(height: 8),
                  const LinearProgressIndicator(),
                ] else
                  Text(
                    reading == null
                        ? '—'
                        : '${reading.value.toStringAsFixed(sensor.kind.fractionDigits)} ${sensor.kind.unit}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: failed ? Colors.grey : accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (threshold != null)
                  Text(
                    'Норма: ${threshold!.min.toStringAsFixed(0)}–'
                    '${threshold!.max.toStringAsFixed(0)} ${sensor.kind.unit}',
                    style: theme.textTheme.bodySmall,
                  ),
                const SizedBox(height: 4),
                if (failed)
                  Row(
                    children: [
                      Icon(Icons.warning_amber, color: accent, size: 18),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Збій датчика: ${snapshot.error}. Інші датчики працюють.',
                          style: TextStyle(color: accent),
                        ),
                      ),
                    ],
                  )
                else if (exceeded)
                  Text(
                    'Поза пороговими значеннями!',
                    style: TextStyle(color: accent, fontWeight: FontWeight.bold),
                  )
                else if (reading != null)
                  Text(
                    'Оновлено: ${_formatTime(reading.time)}',
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  static IconData _iconFor(SensorKind kind) => switch (kind) {
        SensorKind.temperature => Icons.thermostat,
        SensorKind.humidity => Icons.water_drop,
        SensorKind.light => Icons.wb_sunny,
      };

  static String _formatTime(DateTime t) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(t.hour)}:${two(t.minute)}:${two(t.second)}';
  }
}
