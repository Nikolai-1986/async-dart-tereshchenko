import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import 'dashboard_screen.dart';

/// Стартовий екран: налаштування імітації мережі та вхід на панель.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppSettings _settings = const AppSettings();

  void _openDashboard() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DashboardScreen(settings: _settings),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = (_settings.failureRate * 100).round();

    return Scaffold(
      appBar: AppBar(title: const Text('Розумна теплиця')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.eco, size: 48, color: Colors.green),
                    const SizedBox(height: 8),
                    Text('Панель моніторингу теплиці',
                        style: theme.textTheme.titleLarge),
                    const SizedBox(height: 4),
                    const Text('Практична робота 8 · Варіант 1 · Терещенко М. А.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Налаштування імітації мережі',
                style: theme.textTheme.titleMedium),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Частота збоїв сервера: $percent %'),
              subtitle: Slider(
                value: _settings.failureRate,
                divisions: 10,
                label: '$percent %',
                onChanged: (value) => setState(
                  () => _settings = _settings.copyWith(failureRate: value),
                ),
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Повільна мережа'),
              subtitle: const Text('+4 с до кожного запиту → тайм-аут 3 с'),
              value: _settings.slowNetwork,
              onChanged: (value) => setState(
                () => _settings = _settings.copyWith(slowNetwork: value),
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Порожня теплиця'),
              subtitle: const Text('Сервер повертає порожній список датчиків'),
              value: _settings.emptyGreenhouse,
              onChanged: (value) => setState(
                () => _settings = _settings.copyWith(emptyGreenhouse: value),
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Часті збої датчиків'),
              subtitle: const Text('25 % замість 5 % на кожне оновлення'),
              value: _settings.frequentSensorFailures,
              onChanged: (value) => setState(
                () => _settings =
                    _settings.copyWith(frequentSensorFailures: value),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _openDashboard,
              icon: const Icon(Icons.sensors),
              label: const Text('Відкрити панель теплиці'),
            ),
          ],
        ),
      ),
    );
  }
}
