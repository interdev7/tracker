import 'package:equatable/equatable.dart';

/// Свойства для расчета стоимости поездки
class TrackerProperties extends Equatable {
  const TrackerProperties({
    this.basePrice = 7.0,
    this.pricePerKm = 1.20,
    this.waitingPricePerMinute = 0.70,
    this.freeWaitingMinutes = 2,
    this.minimumTripPrice = 20.0,
    this.workDayStartHour = 6,
    this.workDayEndHour = 14,
    this.minSpeedThreshold = 1.0,
    this.minDistanceThreshold = 2.0,
    this.minSpeedAccuracy = 3.0,
    this.minAcceptableAccuracy = 20.0,
    this.maxRecentSpeeds = 5,
    this.movementThreshold = 5.0,
    this.currency = 'ТМТ',
  });

  //TODO: нужно добавить название тарифа (enum/abstract class)

  /// Валюта. По умолчанию: ТМТ
  final String currency;

  /// Базовая цена в манатах. По умолчанию: 7.0
  final double basePrice;

  /// Цена за километр. По умолчанию: 1.20
  final double pricePerKm;

  /// Цена за минуту ожидания. По умолчанию: 0.70
  final double waitingPricePerMinute;

  /// Бесплатное время ожидания в минутах. По умолчанию: 2
  final int freeWaitingMinutes;

  /// Минимальная цена поездки. По умолчанию: 20.0
  final double minimumTripPrice;

  /// Рабочий день начинается в 6:00. По умолчанию: 6
  final int workDayStartHour;

  /// Рабочий день заканчивается в 14:00. По умолчанию: 14
  final int workDayEndHour;

  /// Минимальная скорость в м/с (3.6 км/ч). По умолчанию: 1.0
  final double minSpeedThreshold;

  /// Минимальное расстояние между точками в метрах. По умолчанию: 2.0
  final double minDistanceThreshold;

  /// Число секунд для усреднения данных о местоположении. По умолчанию: 3.0
  final double minSpeedAccuracy;

  /// Минимальная приемлемая точность местоположения в метрах. По умолчанию: 20.0
  final double minAcceptableAccuracy;

  /// Максимальное количество последних скоростей для усреднения. По умолчанию: 5
  final int maxRecentSpeeds;

  /// Пороговое значение для определения движения. По умолчанию: 5.0 (5 км/ч)
  final double movementThreshold;

  TrackerProperties copyWith({
    double? basePrice,
    double? pricePerKm,
    double? waitingPricePerMinute,
    int? freeWaitingMinutes,
    double? minimumTripPrice,
    int? workDayStartHour,
    int? workDayEndHour,
    double? minSpeedThreshold,
    double? minDistanceThreshold,
    double? minSpeedAccuracy,
    double? minAcceptableAccuracy,
    int? maxRecentSpeeds,
    double? movementThreshold,
    String? currency,
  }) {
    return TrackerProperties(
      basePrice: basePrice ?? this.basePrice,
      pricePerKm: pricePerKm ?? this.pricePerKm,
      waitingPricePerMinute: waitingPricePerMinute ?? this.waitingPricePerMinute,
      freeWaitingMinutes: freeWaitingMinutes ?? this.freeWaitingMinutes,
      minimumTripPrice: minimumTripPrice ?? this.minimumTripPrice,
      workDayStartHour: workDayStartHour ?? this.workDayStartHour,
      workDayEndHour: workDayEndHour ?? this.workDayEndHour,
      minSpeedThreshold: minSpeedThreshold ?? this.minSpeedThreshold,
      minDistanceThreshold: minDistanceThreshold ?? this.minDistanceThreshold,
      minSpeedAccuracy: minSpeedAccuracy ?? this.minSpeedAccuracy,
      minAcceptableAccuracy: minAcceptableAccuracy ?? this.minAcceptableAccuracy,
      maxRecentSpeeds: maxRecentSpeeds ?? this.maxRecentSpeeds,
      movementThreshold: movementThreshold ?? this.movementThreshold,
      currency: currency ?? this.currency,
    );
  }

  @override
  List<Object?> get props => [
        basePrice,
        pricePerKm,
        waitingPricePerMinute,
        freeWaitingMinutes,
        minimumTripPrice,
        workDayStartHour,
        workDayEndHour,
        minSpeedThreshold,
        minDistanceThreshold,
        minSpeedAccuracy,
        minAcceptableAccuracy,
        maxRecentSpeeds,
        movementThreshold,
        currency,
      ];
}
