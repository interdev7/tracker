class KalmanFilter {
  double _estimate = 0.0;
  double _error = 1.0;
  final double _processNoise;
  final double _measurementNoise;

  KalmanFilter({double processNoise = 1e-3, double measurementNoise = 1e-1})
      : _processNoise = processNoise,
        _measurementNoise = measurementNoise;

  double filter(double measurement) {
    // Prediction update
    _error += _processNoise;

    // Measurement update
    double kalmanGain = _error / (_error + _measurementNoise);
    _estimate += kalmanGain * (measurement - _estimate);
    _error *= (1 - kalmanGain);

    return _estimate;
  }
}
