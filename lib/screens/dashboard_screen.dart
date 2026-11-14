import 'dart:async';

import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../models/greenhouse_models.dart';
import '../services/fake_api.dart';
import '../services/greenhouse_service.dart';
import '../services/sensor_feed.dart';
import '../widgets/sensor_card.dart';
import '../widgets/state_views.dart';
import '../widgets/summary_card.dart';

/// Панель теплиці: FutureBuilder (початкове завантаження)
/// + StreamBuilder у кожній картці (оновлення в реальному часі).
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.settings});

  final AppSettings settings;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const Duration _alertCooldown = Duration(seconds: 10);

  late final GreenhouseService _service;

  /// Future створюється в initState / _retry, а НЕ в build().
  late Future<DashboardData> _dashboardFuture;

  final List<SensorFeed> _feeds = [];
  final List<StreamSubscription<SensorReading>> _subscriptions = [];
  final Map<String, Sensor> _sensorsById = {};
  final Map<String, DateTime> _lastAlertAt = {};
  Map<SensorKind, SensorThreshold> _thresholds = const {};
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    _service = GreenhouseService(
      api: FakeApi(
        failureRate: widget.settings.failureRate,
        extraDelayMs: widget.settings.extraDelayMs,
      ),
      emptyGreenhouse: widget.settings.emptyGreenhouse,
    );
    _dashboardFuture = _load();
  }

  Future<DashboardData> _load() async {
    _stopFeeds();
    final data = await _service.loadDashboard();
    // Після await віджет міг бути знятий з дерева.
    if (!mounted) return data;
    _thresholds = data.thresholds;
    _startFeeds(data.sensors);
    return data;
  }

  void _retry() {
    setState(() {
      _paused = false;
      _dashboardFuture = _load();
    });
  }

  void _startFeeds(List<Sensor> sensors) {
    for (final sensor in sensors) {
      final feed = SensorFeed(
        sensor: sensor,
        failureRate: widget.settings.sensorFailureRate,
      );
      _feeds.add(feed);
      _sensorsById[sensor.id] = sensor;
      _subscriptions.add(
        // onError обов'язковий: помилки датчика показує StreamBuilder картки.
        feed.stream.listen(_checkThreshold, onError: (Object _) {}),
      );
      feed.start();
    }
  }

  void _stopFeeds() {
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    _subscriptions.clear();
    for (final feed in _feeds) {
      unawaited(feed.dispose());
    }
    _feeds.clear();
    _sensorsById.clear();
  }

  void _togglePause() {
    setState(() => _paused = !_paused);
    for (final feed in _feeds) {
      // Зупиняємо/запускаємо саме джерело подій (таймер).
      if (_paused) {
        feed.pause();
      } else {
        feed.start();
      }
    }
  }

  /// Перевірка порогу + SnackBar не частіше ніж раз на 10 с для датчика.
  void _checkThreshold(SensorReading reading) {
    final sensor = _sensorsById[reading.sensorId];
    final threshold = sensor == null ? null : _thresholds[sensor.kind];
    if (sensor == null || threshold == null) return;
    if (!threshold.isExceeded(reading.value)) return;

    final now = DateTime.now();
    final last = _lastAlertAt[sensor.id];
    if (last != null && now.difference(last) < _alertCooldown) return;
    _lastAlertAt[sensor.id] = now;

    if (!mounted) return;
    final value = reading.value.toStringAsFixed(sensor.kind.fractionDigits);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 3),
          content: Text(
            '${sensor.name}: $value ${sensor.kind.unit} — поза межами '
            '${threshold.min.toStringAsFixed(0)}–'
            '${threshold.max.toStringAsFixed(0)} ${sensor.kind.unit}',
          ),
        ),
      );
  }

  String _describeError(Object? error) {
    if (error is TimeoutException) {
      return 'Сервер не відповів за '
          '${GreenhouseService.loadTimeout.inSeconds} с (тайм-аут).';
    }
    if (error is StateError) return error.message;
    return '$error';
  }

  @override
  void dispose() {
    final count = _feeds.length;
    _stopFeeds();
    debugPrint('DashboardScreen.dispose(): зупинено таймерів і закрито '
        'контролерів — $count');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DashboardData>(
      future: _dashboardFuture,
      builder: (context, snapshot) {
        final loaded = snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData &&
            _feeds.isNotEmpty;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Моніторинг теплиці'),
            actions: [
              if (loaded)
                TextButton.icon(
                  onPressed: _togglePause,
                  icon: Icon(_paused ? Icons.play_arrow : Icons.pause),
                  label: Text(_paused ? 'Продовжити' : 'Пауза'),
                ),
            ],
          ),
          body: _buildBody(snapshot),
        );
      },
    );
  }

  Widget _buildBody(AsyncSnapshot<DashboardData> snapshot) {
    if (snapshot.connectionState != ConnectionState.done) {
      return const LoadingView();
    }
    if (snapshot.hasError) {
      return ErrorView(
        message: _describeError(snapshot.error),
        onRetry: _retry,
      );
    }
    final data = snapshot.data;
    if (data == null || data.sensors.isEmpty) {
      return EmptyView(onRefresh: _retry);
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SummaryCard(summary: data.summary),
        if (_paused)
          Card(
            color: Colors.amber.shade100,
            child: const ListTile(
              leading: Icon(Icons.pause_circle),
              title: Text('Оновлення призупинено'),
              subtitle: Text('Таймери датчиків зупинені — нових показань немає.'),
            ),
          ),
        const SizedBox(height: 8),
        for (final feed in _feeds)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SensorCard(
              feed: feed,
              threshold: _thresholds[feed.sensor.kind],
              paused: _paused,
            ),
          ),
      ],
    );
  }
}
