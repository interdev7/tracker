import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/constants/tariffs.dart';
import '../../data/repositories/trip_repository.dart';
import '../../domain/entities/trip_state.dart';

class TrackerProvider extends ChangeNotifier {
  final TripRepository _repository;
  Timer? _timer;
  Timer? _gpsTimer;
  Position? _lastPosition;
  TripState _state;
  final List<Position> _recentPositions = [];
  bool _isProcessingGPS = false;

  TrackerProvider(this._repository) : _state = TripState();

  // Getters
  double get distanceKm => _state.distanceKm;
  int get tripTime => _state.tripTimeSeconds;
  int get waitingTime => _state.waitingTimeSeconds;
  bool get isTracking => _state.isTracking;
  bool get isMoving => _state.isMoving;
  double get currentSpeed => _state.currentSpeed;

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatSpeed(double speedKmH) {
    return '${speedKmH.toStringAsFixed(1)} км/ч';
  }

  Position _getAveragePosition(List<Position> positions) {
    if (positions.isEmpty) {
      throw Exception('No positions to average');
    }
    if (positions.length == 1) {
      return positions.first;
    }

    double sumLat = 0;
    double sumLng = 0;
    double sumAlt = 0;
    double sumSpeed = 0;
    double sumAccuracy = 0;
    double sumSpeedAccuracy = 0;

    for (var position in positions) {
      sumLat += position.latitude;
      sumLng += position.longitude;
      sumAlt += position.altitude;
      sumSpeed += position.speed;
      sumAccuracy += position.accuracy;
      sumSpeedAccuracy += position.speedAccuracy;
    }

    return Position(
      latitude: sumLat / positions.length,
      longitude: sumLng / positions.length,
      timestamp: positions.last.timestamp,
      accuracy: sumAccuracy / positions.length,
      altitude: sumAlt / positions.length,
      heading: positions.last.heading,
      speed: sumSpeed / positions.length,
      speedAccuracy: sumSpeedAccuracy / positions.length,
      altitudeAccuracy: positions.last.altitudeAccuracy,
      headingAccuracy: positions.last.headingAccuracy,
    );
  }

  // Initialize tracking
  Future<void> initialize() async {
    final savedState = _repository.loadTripState();
    if (savedState != null) {
      _state = savedState;
      if (_state.isTracking) {
        _startTracking();
      }
      notifyListeners();
    }
  }

  // Start tracking
  Future<void> startTracking() async {
    if (_state.isTracking) return;

    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }

    _state = _state.copyWith(
      isTracking: true,
      isMoving: false,
      startTime: DateTime.now(),
    );
    _recentPositions.clear();
    await _repository.saveTripState(_state);
    _startTracking();
    notifyListeners();
  }

  // Stop tracking
  Future<void> stopTracking() async {
    _timer?.cancel();
    _gpsTimer?.cancel();
    _timer = null;
    _gpsTimer = null;
    _lastPosition = null;
    _recentPositions.clear();
    _state = _state.copyWith(
      isTracking: false,
      isMoving: false,
    );
    await _repository.saveTripState(_state);
    notifyListeners();
  }

  // Reset tracking
  Future<void> resetTracking() async {
    _timer?.cancel();
    _gpsTimer?.cancel();
    _timer = null;
    _gpsTimer = null;
    _lastPosition = null;
    _recentPositions.clear();
    _state = TripState();
    await _repository.clearTripState();
    notifyListeners();
  }

  void _startTracking() {
    // Таймер для обновления времени каждую секунду
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_state.isTracking) return;

      if (_state.isMoving) {
        _state = _state.copyWith(
          tripTimeSeconds: _state.tripTimeSeconds + 1,
        );
      } else {
        _state = _state.copyWith(
          waitingTimeSeconds: _state.waitingTimeSeconds + 1,
        );
      }
      notifyListeners();
    });

    // Отдельный таймер для обработки GPS
    _gpsTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!_state.isTracking || _isProcessingGPS) return;

      _isProcessingGPS = true;
      try {
        final currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        // Add current position to recent positions list
        _recentPositions.add(currentPosition);

        // Keep only the last N seconds of positions
        while (_recentPositions.length > Tariffs.locationAveragingSeconds) {
          _recentPositions.removeAt(0);
        }

        // Get averaged position
        final position = _getAveragePosition(_recentPositions);

        // Calculate speed and distance only if we have a previous position
        if (_lastPosition != null) {
          final distance = Geolocator.distanceBetween(
            _lastPosition!.latitude,
            _lastPosition!.longitude,
            position.latitude,
            position.longitude,
          );

          // Calculate current speed in km/h
          final speedMS = distance / 1.0; // speed in m/s
          final speedKmH = speedMS * 3.6; // convert to km/h

          // Only process movement if distance is above minimum threshold
          if (distance >= Tariffs.minDistanceThreshold) {
            if (speedMS > Tariffs.minSpeedThreshold) {
              // Moving
              _state = _state.copyWith(
                distanceKm: _state.distanceKm + (distance / 1000), // Convert to kilometers
                isMoving: true,
                currentSpeed: speedKmH,
              );
            } else {
              // Speed below threshold - waiting
              _state = _state.copyWith(
                isMoving: false,
                currentSpeed: 0.0,
              );
            }
            _lastPosition = position;
          } else {
            // Distance below threshold - definitely waiting
            _state = _state.copyWith(
              isMoving: false,
              currentSpeed: 0.0,
            );
          }
        } else {
          // First position
          _lastPosition = position;
          _state = _state.copyWith(currentSpeed: 0.0);
        }

        await _repository.saveTripState(_state);
        log('''
        #########################################################



        Position: ${position.toString()}
        Speed: ${_formatSpeed(_state.currentSpeed)}
        Distance: ${_state.distanceKm.toStringAsFixed(2)} км или ${(_state.distanceKm * 1000).toStringAsFixed(0)} м
        Current point distance: ${_lastPosition != null ? Geolocator.distanceBetween(
                _lastPosition!.latitude,
                _lastPosition!.longitude,
                position.latitude,
                position.longitude,
              ).toStringAsFixed(2) : '0.00'} м
        Trip time: ${_formatDuration(_state.tripTimeSeconds)}
        Waiting time: ${_formatDuration(_state.waitingTimeSeconds)}
        IsTracking: ${_state.isTracking}
        IsMoving: ${_state.isMoving}



        #########################################################
        ''');
        notifyListeners();
      } catch (e) {
        debugPrint('Error tracking location: $e');
      } finally {
        _isProcessingGPS = false;
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _gpsTimer?.cancel();
    super.dispose();
  }
}
