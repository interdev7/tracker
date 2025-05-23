import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker/core/utils/utils.dart';

import '../../domain/services/price_calculator.dart';
import '../providers/tracker_provider.dart';

class TripInfoWidget extends StatelessWidget {
  const TripInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TrackerProvider>(
      builder: (context, tracker, _) {
        final price = PriceCalculator.calculateTripPrice(
          distanceKm: tracker.distanceKm,
          waitingTimeSeconds: tracker.waitingTime,
          startTime: null, // We'll calculate without time-based pricing in the UI
          properties: tracker.properties,
        );
        // final hasFreeWaitingTime = tracker.waitingTime < tracker.properties.freeWaitingMinutes;

        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Center(
                  child: Text(
                    'Общее время в пути',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    formatDuration(tracker.commonTime),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: tracker.isTracking
                      ? Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                            color: tracker.isMoving ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                tracker.isMoving ? Icons.directions_car : Icons.timer,
                                color: tracker.isMoving ? Colors.green : Colors.orange,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                tracker.isMoving ? 'В движении' : 'Ожидание',
                                style: TextStyle(
                                  color: tracker.isMoving ? Colors.green : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              if (tracker.isMoving) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '(${tracker.currentSpeed.toStringAsFixed(1)} км/ч)',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 16),
                _InfoRow(
                  icon: Icons.speed,
                  label: 'Скорость',
                  value: '${tracker.currentSpeed.toStringAsFixed(1)} км/ч  ${(tracker.currentSpeed * 3.6).toStringAsFixed(1)} м/с',
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.route,
                  label: 'Расстояние',
                  value: '${tracker.distanceKm.toStringAsFixed(2)} км',
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.directions_car,
                  label: 'Время в пути',
                  value: formatDuration(tracker.tripTime),
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.timer,
                  label: 'Время ожидания',
                  color: tracker.hasFreeWaitingTime ? Colors.green : Colors.red,
                  value: formatDuration(tracker.waitingTime),
                ),
                const SizedBox(height: 18),
                const Text(
                  "Стоимость поездки:",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 7),
                _InfoRow(
                  icon: Icons.local_atm,
                  label: 'Подача',
                  value: "${tracker.properties.basePrice.toStringAsFixed(2)} ${tracker.properties.currency}",
                ),
                _InfoRow(
                  icon: Icons.local_atm,
                  label: 'Насчитанная сумма',
                  value: '${price.movingPrice.toStringAsFixed(2)} ${tracker.properties.currency}',
                ),
                _InfoRow(
                  icon: Icons.local_atm,
                  label: 'Минимальная стоимость',
                  value: '${tracker.properties.minimumTripPrice.toStringAsFixed(2)} ${tracker.properties.currency}',
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (tracker.isTracking) {
                          tracker.stopTracking();
                        } else {
                          tracker.startTracking();
                        }
                      },
                      child: Text(
                        tracker.isTracking ? 'Остановить' : 'Начать',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: tracker.resetTracking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Сбросить'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 24),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
