import 'package:flutter/material.dart';

import '../models/greenhouse_models.dart';

/// Підсумок за добу (третій із паралельних запитів).
class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key, required this.summary});

  final DailySummary summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Підсумок за добу',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 24,
              runSpacing: 12,
              children: [
                _Metric(
                  label: 'Сер. температура',
                  value: '${summary.avgTemperature.toStringAsFixed(1)} °C',
                ),
                _Metric(
                  label: 'Сер. вологість',
                  value: '${summary.avgHumidity.toStringAsFixed(0)} %',
                ),
                _Metric(
                  label: 'Світловий день',
                  value: '${summary.lightHours.toStringAsFixed(1)} год',
                ),
                _Metric(label: 'Тривог', value: '${summary.alertsCount}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodySmall),
        Text(value, style: theme.textTheme.titleMedium),
      ],
    );
  }
}
