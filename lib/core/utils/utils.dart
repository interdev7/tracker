String formatDuration(int seconds) {
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  final remainingSeconds = seconds % 60;

  return hours > 0
      ? '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}'
      : '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
}

int calculateAvailableWaitingTime(int waitingTimeSeconds, int freeWaitingSeconds) {
  final free = (freeWaitingSeconds * 60) - waitingTimeSeconds;
  return free > 0 ? free : 0;
}
