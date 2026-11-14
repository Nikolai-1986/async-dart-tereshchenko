import 'dart:async';

import '../models/greenhouse_models.dart';
import 'fake_api.dart';

/// Сервіс теплиці: усі «мережеві» запити йдуть через FakeApi.
class GreenhouseService {
  GreenhouseService({required this.api, this.emptyGreenhouse = false});

  /// Тайм-аут початкового завантаження.
  static const Duration loadTimeout = Duration(seconds: 3);

  final FakeApi api;
  final bool emptyGreenhouse;

  Future<List<Sensor>> fetchSensors() => api.request<List<Sensor>>(
        () => emptyGreenhouse ? const <Sensor>[] : _demoSensors,
        delayMs: 900,
      );

  Future<Map<SensorKind, SensorThreshold>> fetchThresholds() =>
      api.request<Map<SensorKind, SensorThreshold>>(
        () => _demoThresholds,
        delayMs: 700,
      );

  Future<DailySummary> fetchSummary() => api.request<DailySummary>(
        () => const DailySummary(
          avgTemperature: 23.8,
          avgHumidity: 64,
          lightHours: 11.5,
          alertsCount: 3,
        ),
        delayMs: 1200,
      );

  /// Паралельне завантаження трьох ресурсів з одним спільним тайм-аутом.
  /// Загальний час ≈ найдовший запит (1,2 с), а не сума (2,8 с).
  Future<DashboardData> loadDashboard() async {
    final results = await Future.wait<Object>(
      [fetchSensors(), fetchThresholds(), fetchSummary()],
      eagerError: true,
    ).timeout(loadTimeout);

    return DashboardData(
      sensors: results[0] as List<Sensor>,
      thresholds: results[1] as Map<SensorKind, SensorThreshold>,
      summary: results[2] as DailySummary,
    );
  }
}

const List<Sensor> _demoSensors = [
  Sensor(
    id: 't-a',
    name: 'Температура, зона А',
    kind: SensorKind.temperature,
    initialValue: 24.0,
  ),
  Sensor(
    id: 't-b',
    name: 'Температура, зона Б',
    kind: SensorKind.temperature,
    initialValue: 29.0,
  ),
  Sensor(
    id: 'h-1',
    name: 'Вологість повітря',
    kind: SensorKind.humidity,
    initialValue: 76.0,
  ),
  Sensor(
    id: 'l-1',
    name: 'Освітленість',
    kind: SensorKind.light,
    initialValue: 950.0,
  ),
];

const Map<SensorKind, SensorThreshold> _demoThresholds = {
  SensorKind.temperature: SensorThreshold(min: 18, max: 30),
  SensorKind.humidity: SensorThreshold(min: 40, max: 80),
  SensorKind.light: SensorThreshold(min: 300, max: 1000),
};
