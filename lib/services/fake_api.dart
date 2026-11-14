import 'dart:math';

/// Імітація мережі: затримка та керована частота збоїв.
class FakeApi {
  FakeApi({this.failureRate = 0.2, this.extraDelayMs = 0, Random? random})
      : _random = random ?? Random();

  final double failureRate;

  /// Додаткова затримка для імітації повільної мережі.
  final int extraDelayMs;

  final Random _random;

  Future<T> request<T>(T Function() respond, {int delayMs = 800}) async {
    await Future<void>.delayed(
      Duration(milliseconds: delayMs + extraDelayMs),
    );
    if (_random.nextDouble() < failureRate) {
      throw StateError('Сервер недоступний');
    }
    return respond();
  }
}
