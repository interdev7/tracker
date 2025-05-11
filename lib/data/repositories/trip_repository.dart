import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/trip_state.dart';

class TripRepository {
  static const String _tripStateKey = 'trip_state';
  SharedPreferences? _prefs;

  TripRepository();

  Future<SharedPreferences?> init() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs;
  }

  Future<void> saveTripState(TripState state) async {
    final stateMap = {
      'distanceKm': state.distanceKm,
      'tripTimeSeconds': state.tripTimeSeconds,
      'waitingTimeSeconds': state.waitingTimeSeconds,
      'availableWaitingTime': state.availableWaitingTime,
      'isTracking': state.isTracking,
      'isMoving': state.isMoving,
      'currentSpeed': state.currentSpeed,
      'startTime': state.startTime?.toIso8601String(),
      'speedAccuracy': state.speedAccuracy,
      'locationAccuracy': state.locationAccuracy,
      'lastUpdateTime': state.lastUpdateTime?.toIso8601String(),
      'recentSpeeds': state.recentSpeeds,
      'commonTime': state.commonTime,
    };
    await _prefs?.setString(_tripStateKey, jsonEncode(stateMap));
  }

  TripState? loadTripState() {
    final stateJson = _prefs?.getString(_tripStateKey);
    if (stateJson == null) return null;

    final stateMap = jsonDecode(stateJson) as Map<String, dynamic>;
    return TripState(
      distanceKm: (stateMap['distanceKm'] ?? 0.0) as double,
      tripTimeSeconds: (stateMap['tripTimeSeconds'] ?? 0) as int,
      waitingTimeSeconds: (stateMap['waitingTimeSeconds'] ?? 0) as int,
      availableWaitingTime: (stateMap['availableWaitingTime'] ?? 2) as int,
      isTracking: (stateMap['isTracking'] ?? false) as bool,
      isMoving: (stateMap['isMoving'] ?? false) as bool,
      currentSpeed: (stateMap['currentSpeed'] ?? 0.0) as double,
      startTime: stateMap['startTime'] != null ? DateTime.parse(stateMap['startTime'] as String) : null,
      speedAccuracy: stateMap['speedAccuracy'] as double? ?? 0.0,
      locationAccuracy: stateMap['locationAccuracy'] as double? ?? 0.0,
      lastUpdateTime: stateMap['lastUpdateTime'] != null ? DateTime.parse(stateMap['lastUpdateTime'] as String) : null,
      recentSpeeds: (stateMap['recentSpeeds'] as List<dynamic>?)?.cast<double>() ?? const [],
      commonTime: (stateMap['commonTime'] ?? 0) as int,
    );
  }

  Future<void> clearTripState() async {
    await _prefs?.remove(_tripStateKey);
  }
}
