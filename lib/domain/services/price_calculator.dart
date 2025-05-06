import '../../core/constants/tariffs.dart';

class PriceCalculator {
  static double calculateTripPrice({
    required double distanceKm,
    required int waitingTimeSeconds,
    required DateTime? startTime,
  }) {
    // Base price (7 манат за подачу)
    double totalPrice = Tariffs.basePrice;

    // Distance price (1.20 манат за километр)
    totalPrice += distanceKm * Tariffs.pricePerKm;

    // Waiting time price (after 2 free minutes)
    final waitingMinutes = waitingTimeSeconds / 60;
    if (waitingMinutes > Tariffs.freeWaitingMinutes) {
      final chargeableMinutes = waitingMinutes - Tariffs.freeWaitingMinutes;
      totalPrice += chargeableMinutes * Tariffs.waitingPricePerMinute;
    }

    // Check if trip started during work hours (6:00 - 14:00)
    if (startTime != null) {
      final hour = startTime.hour;
      if (hour >= Tariffs.workDayStartHour && hour < Tariffs.workDayEndHour) {
        // Standard pricing during work hours (6:00 - 14:00)
      } else {
        // Outside work hours - no additional charges as per requirements
      }
    }

    // Ensure minimum trip price (20 манат)
    return totalPrice < Tariffs.minimumTripPrice ? Tariffs.minimumTripPrice : totalPrice;
  }
}
