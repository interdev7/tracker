import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/repositories/trip_repository.dart';
import '../../domain/entities/trip_state.dart';
import '../../core/constants/tracker_properties.dart';

class TrackerProvider extends ChangeNotifier {
  /// Репозиторий для сохранения и загрузки состояния поездки
  final TripRepository _repository;

  /// Контроллер для расчета стоимости поездки
  TrackerProperties _properties;

  Timer? _timer;
  Timer? _gpsTimer;
  Position? _lastPosition;
  TripState _state;

  TrackerProvider({TripRepository? repository, TrackerProperties? properties})
      : _repository = repository ?? TripRepository(),
        _properties = properties ?? const TrackerProperties(),
        _state = const TripState();

  // Getters
  double get distanceKm => _state.distanceKm;
  int get tripTime => _state.tripTimeSeconds;
  int get waitingTime => _state.waitingTimeSeconds;
  bool get isTracking => _state.isTracking;
  bool get isMoving => _state.isMoving;
  double get currentSpeed => _state.currentSpeed;
  double get averageSpeed => _state.averageSpeed;

  TrackerProperties get properties => _properties;

  void setProperties(TrackerProperties properties) {
    _properties = properties;
    notifyListeners();
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
      recentSpeeds: [],
    );
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
    _state = _state.copyWith(
      isTracking: false,
      isMoving: false,
      recentSpeeds: [],
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
    _state = const TripState();
    await _repository.clearTripState();
    notifyListeners();
  }

  void _startTracking() {
    // Настройка для получения GPS данных в реальном времени
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0,
    );

    // Подписываемся на поток GPS данных
    Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position? position) async {
        if (!_state.isTracking || position == null) return;

        try {
          final now = DateTime.now();
          double speedKmH = position.speed * 3.6; // Convert m/s to km/h

          // Немедленная проверка скорости
          if (speedKmH < _properties.movementThreshold) {
            _state = _state.copyWith(
              isMoving: false,
              currentSpeed: speedKmH,
              speedAccuracy: position.speedAccuracy,
              locationAccuracy: position.accuracy,
              lastUpdateTime: now,
            );
            await _repository.saveTripState(_state);
            notifyListeners();
            return;
          }

          // Update recent speeds buffer
          List<double> updatedSpeeds = List<double>.from(_state.recentSpeeds);
          updatedSpeeds.add(speedKmH);
          if (updatedSpeeds.length > _properties.maxRecentSpeeds) {
            updatedSpeeds.removeAt(0);
          }

          // Проверяем точность GPS
          bool isAccurate = position.accuracy <= _properties.minAcceptableAccuracy && position.speedAccuracy <= _properties.minSpeedAccuracy;

          // Рассчитываем среднюю скорость для более плавного обнаружения движения
          double avgSpeed = updatedSpeeds.isEmpty ? speedKmH : updatedSpeeds.reduce((a, b) => a + b) / updatedSpeeds.length;

          // Определяем, движемся ли на основе средней скорости и точности
          bool isMovingNow = isAccurate && avgSpeed >= _properties.movementThreshold;

          double distanceIncrement = 0.0;
          if (_lastPosition != null && isMovingNow) {
            // Calculate distance only if we're confident about movement
            distanceIncrement = Geolocator.distanceBetween(
                  _lastPosition!.latitude,
                  _lastPosition!.longitude,
                  position.latitude,
                  position.longitude,
                ) /
                1000; // Convert to kilometers

            // Validate distance increment
            if (distanceIncrement > 0.1) {
              // More than 100m
              // If distance seems too large, validate with speed
              double timeSeconds = now.difference(_lastPosition!.timestamp).inSeconds.toDouble();
              double expectedDistance = (_lastPosition!.speed * timeSeconds) / 1000;
              if (distanceIncrement > expectedDistance * 1.5) {
                // Distance increment seems invalid, adjust it
                distanceIncrement = expectedDistance;
              }
            }
          }

          // Update state with new values
          _state = _state.copyWith(
            distanceKm: _state.distanceKm + (isMovingNow ? distanceIncrement : 0),
            isMoving: isMovingNow,
            currentSpeed: speedKmH,
            speedAccuracy: position.speedAccuracy,
            locationAccuracy: position.accuracy,
            lastUpdateTime: now,
            recentSpeeds: updatedSpeeds,
          );

          _lastPosition = position;
          await _repository.saveTripState(_state);

          log('''
              #########################################################
              Speed: ${speedKmH.toStringAsFixed(1)} км/ч
              Avg Speed: ${avgSpeed.toStringAsFixed(1)} км/ч
              Distance: ${_state.distanceKm.toStringAsFixed(2)} км
              GPS Accuracy: ${position.accuracy.toStringAsFixed(1)}m
              Speed Accuracy: ${position.speedAccuracy.toStringAsFixed(1)}m/s
              Is Moving: ${_state.isMoving}
              Is Accurate: $isAccurate
              #########################################################
              ''');

          notifyListeners();
        } catch (e) {
          debugPrint('Error processing location: $e');
        }
      },
      onError: (error) {
        debugPrint('Location subscription error: $error');
      },
    );

    // Таймер для обновления времени
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!_state.isTracking) return;

      final now = DateTime.now();
      final lastUpdate = _state.lastUpdateTime ?? now;

      // Проверяем, не устарели ли данные GPS
      final isGpsStale = now.difference(lastUpdate).inSeconds > 5;

      if (_state.isMoving && !isGpsStale) {
        _state = _state.copyWith(
          tripTimeSeconds: _state.tripTimeSeconds + 1,
        );
      } else {
        _state = _state.copyWith(
          waitingTimeSeconds: _state.waitingTimeSeconds + 1,
          isMoving: false, // Reset movement state if GPS is stale
        );
      }

      await _repository.saveTripState(_state);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _gpsTimer?.cancel();
    super.dispose();
  }
}
