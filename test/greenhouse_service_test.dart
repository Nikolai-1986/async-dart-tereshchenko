import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:greenhouse_monitor/models/greenhouse_models.dart';
import 'package:greenhouse_monitor/services/fake_api.dart';
import 'package:greenhouse_monitor/services/greenhouse_service.dart';
import 'package:greenhouse_monitor/services/sensor_feed.dart';

void main() {
  group('GreenhouseService.loadDashboard', () {
    test('паралельно завантажує датчики, пороги та підсумок', () async {
      final service = GreenhouseService(api: FakeApi(failureRate: 0));
      final stopwatch = Stopwatch()..start();
      final data = await service.loadDashboard();
      stopwatch.stop();

      expect(data.sensors, hasLength(4));
      expect(data.thresholds.keys, containsAll(SensorKind.values));
      // Паралельно ≈ max(900, 700, 1200) мс, а не сума 2800 мс.
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });

    test('порожня теплиця повертає порожній список', () async {
      final service = GreenhouseService(
        api: FakeApi(failureRate: 0),
        emptyGreenhouse: true,
      );
      final data = await service.loadDashboard();
      expect(data.sensors, isEmpty);
    });

    test('збій сервера дає StateError', () async {
      final service = GreenhouseService(api: FakeApi(failureRate: 1));
      await expectLater(service.loadDashboard(), throwsA(isA<StateError>()));
    });

    test('повільна мережа дає TimeoutException', () async {
      final service = GreenhouseService(
        api: FakeApi(failureRate: 0, extraDelayMs: 4000),
      );
      await expectLater(
        service.loadDashboard(),
        throwsA(isA<TimeoutException>()),
      );
    });
  });

  group('SensorFeed', () {
    const sensor = Sensor(
      id: 't',
      name: 'Тест',
      kind: SensorKind.temperature,
      initialValue: 24.0,
    );

    test('пауза зупиняє джерело подій', () async {
      final feed = SensorFeed(sensor: sensor, failureRate: 0);
      final readings = <SensorReading>[];
      final subscription = feed.stream.listen(readings.add);

      feed.start();
      await Future<void>.delayed(const Duration(milliseconds: 2500));
      expect(readings, isNotEmpty);

      feed.pause();
      expect(feed.isRunning, isFalse);
      final countOnPause = readings.length;
      await Future<void>.delayed(const Duration(milliseconds: 2500));
      expect(readings.length, countOnPause);

      await subscription.cancel();
      await feed.dispose();
      expect(feed.isClosed, isTrue);
    });

    test('збій датчика йде через addError і не закриває потік', () async {
      final feed = SensorFeed(sensor: sensor, failureRate: 1);
      var errors = 0;
      final subscription = feed.stream.listen(
        (_) {},
        onError: (Object error) {
          if (error is SensorFailure) errors++;
        },
      );

      feed.start();
      await Future<void>.delayed(const Duration(milliseconds: 2500));
      expect(errors, greaterThan(0));
      expect(feed.isClosed, isFalse);

      await subscription.cancel();
      await feed.dispose();
    });
  });
}
