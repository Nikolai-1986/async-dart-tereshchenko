/// Налаштування імітації мережі, що задаються на головному екрані.
/// Дозволяють показати помилку, тайм-аут і порожні дані без зміни коду.
class AppSettings {
  const AppSettings({
    this.failureRate = 0.2,
    this.slowNetwork = false,
    this.emptyGreenhouse = false,
    this.frequentSensorFailures = false,
  });

  /// Імовірність збою кожного запиту до «сервера» (0..1).
  final double failureRate;

  /// Додає 4 с до кожного запиту — спрацьовує тайм-аут 3 с.
  final bool slowNetwork;

  /// «Сервер» повертає порожній список датчиків.
  final bool emptyGreenhouse;

  /// Частіші збої окремих датчиків під час оновлень.
  final bool frequentSensorFailures;

  int get extraDelayMs => slowNetwork ? 4000 : 0;

  double get sensorFailureRate => frequentSensorFailures ? 0.25 : 0.05;

  AppSettings copyWith({
    double? failureRate,
    bool? slowNetwork,
    bool? emptyGreenhouse,
    bool? frequentSensorFailures,
  }) {
    return AppSettings(
      failureRate: failureRate ?? this.failureRate,
      slowNetwork: slowNetwork ?? this.slowNetwork,
      emptyGreenhouse: emptyGreenhouse ?? this.emptyGreenhouse,
      frequentSensorFailures:
          frequentSensorFailures ?? this.frequentSensorFailures,
    );
  }
}
