// Tariff constants for the taxi service
class Tariffs {
  static const double basePrice = 7.0; // Базовая цена в манатах
  static const double pricePerKm = 1.20; // Цена за километр
  static const double waitingPricePerMinute = 0.70; // Цена за минуту ожидания
  static const int freeWaitingMinutes = 2; // Бесплатное время ожидания в минутах
  static const double minimumTripPrice = 20.0; // Минимальная цена поездки

  static const int workDayStartHour = 6; // Рабочий день начинается в 6:00
  static const int workDayEndHour = 14; // Рабочий день заканчивается в 14:00

  // Movement detection thresholds
  static const double minSpeedThreshold = 1.0; // Минимальная скорость в м/с (примерно 3.6 км/ч)
  static const double minDistanceThreshold = 5.0; // Минимальное расстояние между точками в метрах
  static const int locationAveragingSeconds = 3; // Число секунд для усреднения данных о местоположении
}
