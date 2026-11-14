/// Моделі даних панелі моніторингу теплиці.
enum SensorKind { temperature, humidity, light }

extension SensorKindInfo on SensorKind {
  String get label => switch (this) {
        SensorKind.temperature => 'Температура',
        SensorKind.humidity => 'Вологість',
        SensorKind.light => 'Освітленість',
      };

  String get unit => switch (this) {
        SensorKind.temperature => '°C',
        SensorKind.humidity => '%',
        SensorKind.light => 'лк',
      };

  /// Фізичні межі, в яких «датчик» може видавати значення.
  (double, double) get physicalRange => switch (this) {
        SensorKind.temperature => (10.0, 40.0),
        SensorKind.humidity => (20.0, 100.0),
        SensorKind.light => (0.0, 2000.0),
      };

  /// Максимальна зміна показника за одне оновлення.
  double get step => switch (this) {
        SensorKind.temperature => 0.7,
        SensorKind.humidity => 2.0,
        SensorKind.light => 70.0,
      };

  int get fractionDigits => this == SensorKind.temperature ? 1 : 0;
}

class Sensor {
  const Sensor({
    required this.id,
    required this.name,
    required this.kind,
    required this.initialValue,
  });

  final String id;
  final String name;
  final SensorKind kind;
  final double initialValue;
}

class SensorThreshold {
  const SensorThreshold({required this.min, required this.max});

  final double min;
  final double max;

  bool isExceeded(double value) => value < min || value > max;
}

class DailySummary {
  const DailySummary({
    required this.avgTemperature,
    required this.avgHumidity,
    required this.lightHours,
    required this.alertsCount,
  });

  final double avgTemperature;
  final double avgHumidity;
  final double lightHours;
  final int alertsCount;
}

/// Результат початкового паралельного завантаження.
class DashboardData {
  const DashboardData({
    required this.sensors,
    required this.thresholds,
    required this.summary,
  });

  final List<Sensor> sensors;
  final Map<SensorKind, SensorThreshold> thresholds;
  final DailySummary summary;
}

/// Одне показання датчика з потоку.
class SensorReading {
  const SensorReading({
    required this.sensorId,
    required this.value,
    required this.time,
  });

  final String sensorId;
  final double value;
  final DateTime time;
}

/// Збій окремого датчика: передається в потік через addError.
class SensorFailure implements Exception {
  const SensorFailure(this.sensorId, this.message);

  final String sensorId;
  final String message;

  @override
  String toString() => message;
}
