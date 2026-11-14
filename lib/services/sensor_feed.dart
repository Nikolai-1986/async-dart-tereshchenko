import 'dart:async';
import 'dart:math';

import '../models/greenhouse_models.dart';

/// Джерело показань одного датчика в реальному часі.
///
/// Події генерує Timer.periodic (кожні 1–2 с) і додає у власний
/// StreamController. Пауза зупиняє саме таймер — джерело подій.
class SensorFeed {
  SensorFeed({required this.sensor, this.failureRate = 0.05, Random? random})
      : _random = random ?? Random(),
        _value = sensor.initialValue {
    _period = Duration(milliseconds: 1000 + _random.nextInt(1001));
  }

  final Sensor sensor;
  final double failureRate;
  final Random _random;

  /// broadcast — бо потік слухають двоє: StreamBuilder картки
  /// і підписка екрана, що перевіряє пороги.
  final StreamController<SensorReading> _controller =
      StreamController<SensorReading>.broadcast();

  late final Duration _period;
  Timer? _timer;
  double _value;
  SensorReading? _lastReading;

  Stream<SensorReading> get stream => _controller.stream;
  SensorReading? get lastReading => _lastReading;
  bool get isRunning => _timer != null;
  bool get isClosed => _controller.isClosed;

  void start() {
    if (_timer != null || _controller.isClosed) return;
    _timer = Timer.periodic(_period, (_) => _tick());
  }

  void pause() {
    _timer?.cancel();
    _timer = null;
  }

  void _tick() {
    if (_controller.isClosed) return;
    if (_random.nextDouble() < failureRate) {
      // Помилка йде в потік, але потік НЕ закривається.
      _controller.addError(
        SensorFailure(sensor.id, 'немає відповіді від датчика'),
      );
      return;
    }
    _value = _nextValue();
    final reading = SensorReading(
      sensorId: sensor.id,
      value: _value,
      time: DateTime.now(),
    );
    _lastReading = reading;
    _controller.add(reading);
  }

  /// Випадкове блукання з поверненням до початкового значення.
  double _nextValue() {
    final (low, high) = sensor.kind.physicalRange;
    final noise = (_random.nextDouble() * 2 - 1) * sensor.kind.step;
    final pull = (sensor.initialValue - _value) * 0.05;
    return (_value + noise + pull).clamp(low, high).toDouble();
  }

  /// Зупиняє таймер і закриває контролер.
  Future<void> dispose() async {
    pause();
    await _controller.close();
  }
}
