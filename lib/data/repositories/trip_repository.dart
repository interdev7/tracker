import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/trip_state.dart';

class TripRepository {
  static const String _tripStateKey = 'trip_state';
  final SharedPreferences _prefs;

  TripRepository(this._prefs);

  Future<void> saveTripState(TripState state) async {
    final stateMap = {
      'distanceKm': state.distanceKm,
      'tripTimeSeconds': state.tripTimeSeconds,
      'waitingTimeSeconds': state.waitingTimeSeconds,
      'isTracking': state.isTracking,
      'startTime': state.startTime?.toIso8601String(),
    };
    await _prefs.setString(_tripStateKey, jsonEncode(stateMap));
  }

  TripState? loadTripState() {
    final stateJson = _prefs.getString(_tripStateKey);
    if (stateJson == null) return null;

    final stateMap = jsonDecode(stateJson) as Map<String, dynamic>;
    return TripState(
      distanceKm: stateMap['distanceKm'] as double,
      tripTimeSeconds: stateMap['tripTimeSeconds'] as int,
      waitingTimeSeconds: stateMap['waitingTimeSeconds'] as int,
      isTracking: stateMap['isTracking'] as bool,
      startTime: stateMap['startTime'] != null ? DateTime.parse(stateMap['startTime'] as String) : null,
    );
  }

  Future<void> clearTripState() async {
    await _prefs.remove(_tripStateKey);
  }
}
