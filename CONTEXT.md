# CONTEXT.md

## Название модуля
Модуль отслеживания поездки для онлайн-такси (Flutter)

## Цель
Реализация модуля отслеживания поездки с учётом расстояния, времени движения и времени ожидания. Система должна работать в фоновом режиме и восстанавливаться после перезапуска приложения. Расчёт стоимости поездки зависит от времени суток и скорости движения.

---

## Архитектура
Используется **чистая архитектура (Clean Architecture)** с разделением на слои:
- `data` — источники данных, репозитории
- `domain` — сущности и use case
- `presentation` — UI и провайдеры
- `core` — утилиты, сервисы, общие зависимости

---

## Платформенные библиотеки
- [`geolocator`](https://pub.dev/packages/geolocator) — для отслеживания позиции и расчёта скорости
- [`provider`](https://pub.dev/packages/provider) — управление состоянием
- [`equatable`](https://pub.dev/packages/equatable) — сравнение объектов в сущностях и состояниях
- [`shared_preferences`](https://pub.dev/packages/shared_preferences) — для хранения состояния трекера и возобновления отслеживания после перезапуска приложения

---

## Функциональные требования

### 📍 Счётчики

#### 1. Расстояние
- Отображается: `0.00 км`
- Считается по изменениям геопозиции
- Обновляется только при скорости > 1 км/сw

#### 2. Время поездки
- Считается при скорости > 10 км/с
- Формат отображения: `HH:mm:ss` или `mm:ss`

#### 3. Время ожидания
- Считается при скорости ≤ 10 км/с
- Первые 2 минуты бесплатны
- Далее каждая минута: +0.70 манат

---

### ⏰ Временные тарифы

#### Временной диапазон
**С 6:00 до 14:00**

#### Тарифы
- Подача: `7 манат`
- Стоимость километра: `1.20 манат`
- Ожидание:
  - 2 минуты бесплатно
  - После 2 минут: `0.70 манат` за каждую минуту ожидания

#### Минимальная стоимость поездки
- Не менее: `20 манат`

---

## Класс `TrackerProvider`

```dart
class TrackerProvider extends ChangeNotifier {
  final TrackerController controller;
  double get distanceKm;      // расстояние в км
  int get tripTime;           // время поездки в секундах (если скорость > 1 м/с)
  int get waitingTime;        // время ожидания в секундах (если скорость ≤ 1 м/с)
}
