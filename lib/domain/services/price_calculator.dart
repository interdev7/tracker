import 'package:tracker/core/utils/utils.dart';

import '../../core/constants/tracker_properties.dart';

class PriceCalculator {
  static TotalPrice calculateTripPrice({
    required double distanceKm,
    required int waitingTimeSeconds,
    required DateTime? startTime,
    required TrackerProperties properties,
  }) {
    // Base price (7 манат за подачу)
    double totalPrice = properties.basePrice;

    // Distance price (1.20 манат за километр)
    totalPrice += distanceKm * properties.pricePerKm;

    // Waiting time price (after 2 free minutes)
    final waitingMinutes = waitingTimeSeconds / 60;
    if (waitingMinutes > properties.freeWaitingMinutes) {
      final chargeableMinutes = waitingMinutes - properties.freeWaitingMinutes;
      totalPrice += chargeableMinutes * properties.waitingPricePerMinute;
    }

    // Check if trip started during work hours (6:00 - 14:00)
    if (startTime != null) {
      final hour = startTime.hour;
      if (hour >= properties.workDayStartHour && hour < properties.workDayEndHour) {
        // Standard pricing during work hours (6:00 - 14:00)
      } else {
        // Outside work hours - no additional charges as per requirements
      }
    }

    // Если стоимость поездки меньше минимальной стоимости, то устанавливаем минимальную стоимость
    final movedPrice = totalPrice < properties.minimumTripPrice ? properties.minimumTripPrice : totalPrice;

    return TotalPrice(
      basePrice: properties.basePrice,
      movingPrice: totalPrice,
      tripPrice: movedPrice,
      availableWaitingTime: calculateAvailableWaitingTime(waitingTimeSeconds, properties.freeWaitingMinutes),
    );
  }
}

class TotalPrice {
  /// Стоимость подачи
  double basePrice;

  /// Стоимость движения
  double movingPrice;

  /// Стоимость поездки
  double tripPrice;

  /// Оставшееся допустимое время ожидания
  int availableWaitingTime;

  TotalPrice({
    required this.basePrice,
    required this.movingPrice,
    required this.tripPrice,
    required this.availableWaitingTime,
  });

  @override
  String toString() {
    return """TotalPrice(
    basePrice: ${basePrice.toStringAsFixed(2)} манат, 
    movingPrice: ${movingPrice.toStringAsFixed(2)} манат, 
    tripPrice: ${tripPrice.toStringAsFixed(2)} манат,
    availableWaitingTime: ${formatDuration(availableWaitingTime)}
    )
    """;
  }
}
