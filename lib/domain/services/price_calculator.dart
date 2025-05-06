import '../../core/constants/tariffs.dart';

class PriceCalculator {
  static double calculateTripPrice({
    required double distanceKm,
    required int waitingTimeSeconds,
    required DateTime? startTime,
  }) {
    // Base price
    double totalPrice = Tariffs.basePrice;

    // Distance price
    totalPrice += distanceKm * Tariffs.pricePerKm;

    // Waiting time price (after free minutes)
    final waitingMinutes = waitingTimeSeconds / 60;
    if (waitingMinutes > Tariffs.freeWaitingMinutes) {
      final chargeableMinutes = waitingMinutes - Tariffs.freeWaitingMinutes;
      totalPrice += chargeableMinutes * Tariffs.waitingPricePerMinute;
    }

    // Check if trip started during work hours
    if (startTime != null) {
      final hour = startTime.hour;
      if (hour >= Tariffs.workDayStartHour && hour < Tariffs.workDayEndHour) {
        // No additional charges during work hours
      } else {
        // Add 20% surcharge outside work hours
        totalPrice *= 1.2;
      }
    }

    // Ensure minimum trip price
    return totalPrice < Tariffs.minimumTripPrice ? Tariffs.minimumTripPrice : totalPrice;
  }
}
