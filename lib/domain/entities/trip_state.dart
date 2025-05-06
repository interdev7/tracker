import 'package:equatable/equatable.dart';

class TripState extends Equatable {
  final double distanceKm;
  final int tripTimeSeconds;
  final int waitingTimeSeconds;
  final bool isTracking;
  final bool isMoving;
  final double currentSpeed; // Speed in km/h
  final DateTime? startTime;

  const TripState({
    this.distanceKm = 0.0,
    this.tripTimeSeconds = 0,
    this.waitingTimeSeconds = 0,
    this.isTracking = false,
    this.isMoving = false,
    this.currentSpeed = 0.0,
    this.startTime,
  });

  TripState copyWith({
    double? distanceKm,
    int? tripTimeSeconds,
    int? waitingTimeSeconds,
    bool? isTracking,
    bool? isMoving,
    double? currentSpeed,
    DateTime? startTime,
  }) {
    return TripState(
      distanceKm: distanceKm ?? this.distanceKm,
      tripTimeSeconds: tripTimeSeconds ?? this.tripTimeSeconds,
      waitingTimeSeconds: waitingTimeSeconds ?? this.waitingTimeSeconds,
      isTracking: isTracking ?? this.isTracking,
      isMoving: isMoving ?? this.isMoving,
      currentSpeed: currentSpeed ?? this.currentSpeed,
      startTime: startTime ?? this.startTime,
    );
  }

  @override
  List<Object?> get props => [
        distanceKm,
        tripTimeSeconds,
        waitingTimeSeconds,
        isTracking,
        isMoving,
        currentSpeed,
        startTime,
      ];
}
