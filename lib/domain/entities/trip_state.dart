import 'package:equatable/equatable.dart';

class TripState extends Equatable {
  final double distanceKm;
  final int tripTimeSeconds;
  final int waitingTimeSeconds;
  final bool isTracking;
  final bool isMoving;
  final double currentSpeed; // Speed in km/h
  final DateTime? startTime;
  final double speedAccuracy; // GPS speed accuracy
  final double locationAccuracy; // GPS location accuracy
  final DateTime? lastUpdateTime; // Last GPS update time
  final List<double> recentSpeeds; // Buffer for recent speed values
  final int availableWaitingTime; // Available waiting time in minutes
  final int commonTime; // Common time in seconds

  const TripState({
    this.distanceKm = 0.0,
    this.tripTimeSeconds = 0,
    this.waitingTimeSeconds = 0,
    this.isTracking = false,
    this.isMoving = false,
    this.currentSpeed = 0.0,
    this.startTime,
    this.speedAccuracy = 0.0,
    this.locationAccuracy = 0.0,
    this.availableWaitingTime = 2,
    this.lastUpdateTime,
    this.recentSpeeds = const [],
    this.commonTime = 0,
  });

  TripState copyWith({
    double? distanceKm,
    int? tripTimeSeconds,
    int? waitingTimeSeconds,
    bool? isTracking,
    bool? isMoving,
    double? currentSpeed,
    DateTime? startTime,
    double? speedAccuracy,
    double? locationAccuracy,
    DateTime? lastUpdateTime,
    List<double>? recentSpeeds,
    int? availableWaitingTime,
    int? commonTime,
  }) {
    return TripState(
      distanceKm: distanceKm ?? this.distanceKm,
      tripTimeSeconds: tripTimeSeconds ?? this.tripTimeSeconds,
      waitingTimeSeconds: waitingTimeSeconds ?? this.waitingTimeSeconds,
      isTracking: isTracking ?? this.isTracking,
      isMoving: isMoving ?? this.isMoving,
      currentSpeed: currentSpeed ?? this.currentSpeed,
      startTime: startTime ?? this.startTime,
      speedAccuracy: speedAccuracy ?? this.speedAccuracy,
      locationAccuracy: locationAccuracy ?? this.locationAccuracy,
      lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
      recentSpeeds: recentSpeeds ?? this.recentSpeeds,
      availableWaitingTime: availableWaitingTime ?? this.availableWaitingTime,
      commonTime: commonTime ?? this.commonTime,
    );
  }

  // Calculate average speed from recent measurements
  double get averageSpeed {
    if (recentSpeeds.isEmpty) return 0.0;
    return recentSpeeds.reduce((a, b) => a + b) / recentSpeeds.length;
  }

  // Check if GPS data is accurate enough
  bool get isGpsAccurate {
    return speedAccuracy <= 1.0 && locationAccuracy <= 10.0;
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
        speedAccuracy,
        locationAccuracy,
        lastUpdateTime,
        recentSpeeds,
        availableWaitingTime,
        commonTime,
      ];
}
