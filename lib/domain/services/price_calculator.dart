import '../../core/constants/tracker_properties.dart';

class PriceCalculator {
  static double calculateTripPrice({
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

    // Ensure minimum trip price (20 манат)
    return totalPrice < properties.minimumTripPrice ? properties.minimumTripPrice : totalPrice;
  }
}
