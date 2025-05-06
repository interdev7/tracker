import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker/core/constants/tariffs.dart';
import '../providers/tracker_provider.dart';
import '../../domain/services/price_calculator.dart';

class TripInfoWidget extends StatelessWidget {
  const TripInfoWidget({super.key});

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;

    return hours > 0
        ? '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}'
        : '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TrackerProvider>(
      builder: (context, tracker, _) {
        final price = PriceCalculator.calculateTripPrice(
          distanceKm: tracker.distanceKm,
          waitingTimeSeconds: tracker.waitingTime,
          startTime: null, // We'll calculate without time-based pricing in the UI
        );

        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (tracker.isTracking) ...[
                  Container(
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
                  ),
                  const SizedBox(height: 16),
                ],
                _InfoRow(
                  icon: Icons.speed,
                  label: 'Скорость',
                  value: '${tracker.currentSpeed.toStringAsFixed(1)} км/ч  ${(tracker.currentSpeed * 3.6).toStringAsFixed(1)} м/ч',
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
                  value: _formatDuration(tracker.tripTime),
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.timer,
                  label: 'Время ожидания',
                  value: _formatDuration(tracker.waitingTime),
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.local_atm,
                  label: 'Стоимость подачи',
                  value: Tariffs.basePrice.toStringAsFixed(2),
                ),
                _InfoRow(
                  icon: Icons.local_atm,
                  label: 'Стоимость',
                  value: '${price.toStringAsFixed(2)} ТМТ',
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

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 24),
        const SizedBox(width: 12),
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
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
