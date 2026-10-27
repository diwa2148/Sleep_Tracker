# SOMNA — Smart Sleep Tracker

[![Flutter](https://img.shields.io/badge/Flutter-3.47.8-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13.7-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-blue)](https://flutter.dev)

A calm, privacy-conscious mobile wellness companion designed to help users track, understand, and optimize their sleep cycles and circadian consistency without sacrificing privacy or requiring cloud accounts.

---

## Table of Contents

- [Overview & Product Vision](#overview--product-vision)
- [Key Features](#key-features)
- [Design System & Aesthetics](#design-system--aesthetics)
- [Architecture & Tech Stack](#architecture--tech-stack)
- [Directory Structure](#directory-structure)
- [Database Schema & Data Model](#database-schema--data-model)
- [Mathematical Engine & Algorithms](#mathematical-engine--algorithms)
- [Prerequisites & Environment](#prerequisites--environment)
- [Installation & Running](#installation--running)
- [Automated Testing](#automated-testing)
- [Privacy & Security Charter](#privacy--security-charter)
- [Health Platform Integration Points](#health-platform-integration-points)
- [Known Limitations & Future Roadmap](#known-limitations--future-roadmap)

---

## Overview & Product Vision

Sleep tracking often forces a difficult trade-off: invasive wearable requirements, expensive subscriptions, and mandatory cloud accounts that monetize sensitive biometric data.

**SOMNA** (*Latin for dreams/sleep*) is built on a **local-first philosophy**:
- **Zero Mandatory Accounts**: No sign-up, email, or passwords required.
- **100% Offline-First**: All data is stored in a structured SQLite database on your device.
- **Accurate Time-Math**: Solves circular time averaging around midnight (e.g. 23:30 and 00:30 averaging to midnight, not noon).
- **Explainable Insights**: Transparent observations with verifiable calculations rather than hallucinated AI sleep stages.

---

## Key Features

### 1. Onboarding & Personalization (Module A)
- Multi-step welcome experience explaining local storage privacy.
- Sleep duration goal slider (4h to 12h, default: 8h).
- Target bedtime and wake-up time pickers.
- Optional bedtime reminder setup.
- Persistent onboarding completion state with skip capabilities.

### 2. Home Dashboard (Module B)
- Dynamic greeting reflecting time of day and formatted date.
- Sleep duration visualization with a custom progress ring against the user's goal.
- Bedtime and wake-up summary for last night's session.
- Weekly average sleep duration and circadian consistency score.
- 7-day mini trend bar preview with goal reference threshold.
- Actionable insight preview cards.

### 3. Active Sleep Tracker & Manual Logging (Module C)
- **Live Sleep Timer**:
  - Live elapsed timer derived strictly from authoritative start timestamps (`DateTime.now().difference(startTimestamp)`).
  - Survives app restarts and background process termination via immediate SQLite persistence.
  - One-touch **Wake Up** flow with 5-star subjective rating and notes collection.
  - Safe cancellation with confirmation dialog.
- **Manual Sleep Entry & Editing**:
  - Native date and time pickers.
  - Overnight session detection and tag indicator.
  - Multi-day session validation.
  - Strict interval validation (future dates, non-zero durations, max 24h).
  - Overlap collision detection preventing duplicate sessions.

### 4. Sleep History Log (Module D)
- Chronological session feed grouped by day.
- Filter chips: **All Time**, **This Week**, **Last Week**, and **This Month**.
- Detailed session view modal showing exact times, durations, quality stars, and user notes.
- Full editing and swipe-to-delete with destructive confirmation safeguards.

### 5. Advanced Sleep Analytics (Module E)
- Rolling 7-day and 30-day analytics toggle.
- Interactive canvas bar charts with daily durations and goal threshold indicators.
- Circular average bedtime and circular average wake-up time.
- Sleep goal achievement rate (%) and duration variability ($\pm$ standard deviation).
- Bedtime regularity score (0–100%) based on circular mean resultant vector lengths ($R$).
- Week-over-week comparison ($\pm$ minutes change).
- Extremes: Shortest and longest recorded sessions.

### 6. Deterministic Insights Engine (Module F)
- Rules-based, transparent observations:
  - Goal streaks and deficits.
  - Bedtime regularity and circadian stability.
  - Week-over-week duration shifts.
  - Quality correlations (e.g. duration on 4-5 star nights).
- Clear explanation attached to each insight detailing the exact formula and time period used.

### 7. Bedtime & Wake-Up Reminders (Module G)
- Integrated via `flutter_local_notifications`.
- Independent toggles for bedtime and wake reminders.
- Respects Android 13+ runtime notification permissions and exact alarm policies.
- Graceful degradation when permissions are denied.

### 8. Data Management & Privacy (Module J)
- Complete RFC-4180 compliant CSV export with proper escaping for commas, double quotes, and newlines.
- Full machine-readable JSON backup export.
- OS share sheet integration via `share_plus`.
- Factory reset option with safety confirmation dialog.

---

## Design System & Aesthetics

SOMNA uses a bespoke, calm wellness aesthetic:
- **Dark Theme (Default)**:
  - Deep Midnight Navy Background: `#0B1020`
  - Dark Surface: `#141B2D`
  - Elevated Card: `#1C2540`
  - Lavender / Violet Primary Accent: `#9B8CFF`
  - Sky / Cyan Secondary Accent: `#7DD3FC`
  - Restorative Mint Accent: `#86D9B2`
  - Text Primary Dark: `#F4F5FF`
  - Text Secondary Dark: `#A6AEC8`
- **Light Theme**:
  - Clean Off-White Background: `#F6F7FC`
  - Pure White Surface: `#FFFFFF`
  - Border Accents: `#E2E8F0`
- **Typography**: Clean scale with tabular numeral support (`FontFeature.tabularFigures()`) for accurate clock and duration readability.
- **Haptic Feedback**: Subtle vibration on buttons, ratings, and state toggles.

---

## Architecture & Tech Stack

```
                     ┌───────────────────────────────┐
                     │          Presentation         │
                     │  (Screens, Widgets, Dialogs)  │
                     └───────────────┬───────────────┘
                                     │
                     ┌───────────────▼───────────────┐
                     │        State Management       │
                     │  (Provider / ChangeNotifiers) │
                     └───────────────┬───────────────┘
                                     │
                     ┌───────────────▼───────────────┐
                     │       Service / Domain        │
                     │ (Analytics, Insights, Export) │
                     └───────────────┬───────────────┘
                                     │
                     ┌───────────────▼───────────────┐
                     │       Repository Layer        │
                     │ (SleepRepository, Preferences)│
                     └───────────────┬───────────────┘
                                     │
                     ┌───────────────▼───────────────┐
                     │        Local Database         │
                     │      (SQLite via sqflite)     │
                     └───────────────────────────────┘
```

- **Framework**: Flutter (Channel Stable 3.47.8)
- **Language**: Dart (3.13.7) with sound null safety
- **State Management**: `provider: ^6.1.2`
- **Database**: `sqflite: ^2.4.1` + `sqflite_common_ffi: ^2.3.4+4`
- **Preferences**: `shared_preferences: ^2.3.3`
- **Notifications**: `flutter_local_notifications: ^18.0.1`
- **Export & Sharing**: `share_plus: ^10.1.2` + `path_provider: ^2.1.5`
- **Date & Time Formatting**: `intl: ^0.20.3`

---

## Directory Structure

```
lib/
├── app/
│   ├── app.dart                   # MultiProvider & MaterialApp setup
│   ├── app_config.dart            # Global configurations & constants
│   ├── main_screen.dart           # 5-tab root scaffold & bottom nav
│   └── theme/
│       ├── app_colors.dart        # Dark & light palettes
│       ├── app_theme.dart         # Material 3 ThemeData
│       └── app_typography.dart    # Typographic scales
├── core/
│   ├── utils/
│   │   ├── date_time_formatter.dart # Date/time/duration formatting
│   │   └── time_calculator.dart     # Circular math, overlap checks
│   └── widgets/
│       ├── confirm_dialog.dart    # Destructive action safeguards
│       ├── somna_button.dart      # Custom buttons with haptics
│       ├── somna_card.dart        # Elevated surface containers
│       ├── somna_stat_badge.dart  # Metric summary cards
│       └── star_rating_bar.dart   # Interactive 5-star rating widget
├── features/
│   ├── analytics/
│   │   └── presentation/          # Duration charts, consistency meters
│   ├── dashboard/
│   │   └── presentation/          # Dashboard & live session card
│   ├── history/
│   │   └── presentation/          # Session log & detail bottom sheet
│   ├── insights/
│   │   └── presentation/          # Explainable observations
│   ├── onboarding/
│   │   └── presentation/          # Multi-step goal & schedule wizard
│   ├── settings/
│   │   └── presentation/          # Goals, reminders, export, privacy
│   └── sleep_tracking/
│       └── presentation/          # Manual entry & wake-up sheet
├── shared/
│   ├── models/
│   │   ├── sleep_insight.dart     # Deterministic insight model
│   │   ├── sleep_session.dart     # SQLite sleep session model
│   │   ├── sleep_stats.dart       # Statistical aggregates
│   │   └── user_preferences.dart  # Persisted settings model
│   ├── providers/
│   │   ├── settings_provider.dart # Preference state & notifications
│   │   └── sleep_tracker_provider.dart # Session tracking & live ticker
│   ├── repositories/
│   │   ├── preferences_repository.dart
│   │   └── sleep_repository.dart
│   └── services/
│       ├── analytics_service.dart # Rollup calculations & averages
│       ├── database_service.dart  # SQLite tables & indexes
│       ├── export_service.dart    # RFC-4180 CSV & JSON exporters
│       ├── insight_engine.dart    # Rule-based observation generator
│       └── notification_service.dart # Local notification scheduling
└── main.dart                      # App entry point
```

---

## Database Schema & Data Model

### Table: `sleep_sessions`

| Column | Type | Constraints | Description |
|---|---|---|---|
| `id` | TEXT | PRIMARY KEY | Unique UUID or timestamp key |
| `start_timestamp` | INTEGER | NOT NULL | Sleep start in UTC milliseconds |
| `end_timestamp` | INTEGER | NULLABLE | Sleep end in UTC ms (NULL while active) |
| `quality_rating` | INTEGER | NULLABLE | Subjective rating from 1 to 5 |
| `notes` | TEXT | NULLABLE | Freeform tags and factors |
| `source` | TEXT | NOT NULL | `'timer'`, `'manual'`, or `'imported'` |
| `created_at` | INTEGER | NOT NULL | Record creation timestamp in UTC ms |
| `updated_at` | INTEGER | NOT NULL | Record last updated timestamp in UTC ms |

Indexes:
- `idx_sleep_sessions_start` on `start_timestamp DESC`
- `idx_sleep_sessions_end` on `end_timestamp DESC`

---

## Mathematical Engine & Algorithms

### 1. Circular Mean for Bedtime and Wake-Up Times
Direct arithmetic averaging of minutes around midnight fails dramatically (e.g. 23:30 = 1410 min, 00:30 = 30 min $\implies \frac{1410+30}{2} = 720 \text{ min} = 12:00 \text{ PM}$ noon).

SOMNA maps minute $m_i \in [0, 1440)$ to an angular coordinate:
$$\theta_i = \frac{2\pi m_i}{1440}$$
$$\bar{x} = \frac{1}{N} \sum_{i=1}^N \cos(\theta_i), \quad \bar{y} = \frac{1}{N} \sum_{i=1}^N \sin(\theta_i)$$
$$\bar{\theta} = \operatorname{atan2}(\bar{y}, \bar{x}) \pmod{2\pi}$$
$$\text{Average Minute} = \operatorname{round}\left(\frac{\bar{\theta} \times 1440}{2\pi}\right) \pmod{1440}$$

### 2. Circadian Consistency Score ($R$)
Using directional statistics, the mean resultant length $R \in [0, 1]$ is:
$$R = \sqrt{\bar{x}^2 + \bar{y}^2}$$
$$\text{Consistency Index} = \operatorname{round}(R \times 100)$$
- $R = 1.0 \implies 100\%$ consistency (identical bedtime every day).
- Lower values indicate high bedtime dispersion.

### 3. Session Overlap Detection
Two sessions $[S_A, E_A]$ and $[S_B, E_B]$ overlap if and only if:
$$S_A < E_B \quad \text{and} \quad E_A > S_B$$

---

## Prerequisites & Environment

- **Flutter SDK**: 3.47.8 or higher (`flutter --version`)
- **Dart SDK**: 3.13.7 or higher
- **Platforms**:
  - Android (API level 21+)
  - iOS (iOS 13+)
  - Web / Desktop (Windows, macOS, Linux)

---

## Installation & Running

1. **Clone or Extract the Project**:
   ```bash
   cd Sleep_Tracker
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Verify Static Analysis**:
   ```bash
   flutter analyze
   ```

4. **Run the Application**:
   ```bash
   # Run on connected Android / iOS device or emulator
   flutter run

   # Or run on Chrome / Web
   flutter run -d chrome
   ```

---

## Automated Testing

SOMNA includes 33 automated tests covering models, mathematical engines, SQLite persistence, RFC-4180 export, and widget user journeys:

```bash
flutter test
```

### Test Suite Inventory:
- `test/unit/time_calculator_test.dart`: Duration calculations, overnight sessions, multi-day intervals, circular bedtime averaging, consistency scoring, and validation rules.
- `test/unit/sleep_session_test.dart`: Active vs completed states, formatted durations, UTC serialization, and rating bounds.
- `test/unit/database_service_test.dart`: SQLite in-memory CRUD, active session recovery, and overlap queries.
- `test/unit/analytics_service_test.dart`: 7-day and 30-day summaries, goal completion rates, and period-over-period differences.
- `test/unit/insight_engine_test.dart`: Deterministic insight triggers and explanation strings.
- `test/unit/export_service_test.dart`: RFC-4180 CSV escaping for quotes, commas, and newlines; JSON schema validation.
- `test/widget/dashboard_test.dart`: Empty dashboard rendering and active timer activation.
- `test/widget/manual_entry_test.dart`: Form validation, scroll interactions, and session creation.
- `test/widget_test.dart`: Full app smoke test and bottom navigation rendering.

---

## Privacy & Security Charter

- **No Telemetry or Ads**: No Firebase Analytics, Mixpanel, or third-party trackers are integrated.
- **Local Database**: All notes, ratings, and timestamps remain on the user's physical device.
- **Data Export & Erasure**: Users can export their complete data to standard formats (CSV/JSON) or permanently wipe the SQLite database at any time.

---

## Health Platform Integration Points

SOMNA is architected with clear boundaries to support future synchronization with **Android Health Connect** and **Apple HealthKit** through the `SleepRepository` abstraction without altering the UI or analytical layers:

```dart
abstract class HealthPlatformSyncService {
  Future<bool> isPlatformAvailable();
  Future<bool> requestPermissions();
  Future<List<SleepSession>> fetchExternalSleepSessions(DateTime start, DateTime end);
  Future<void> exportSessionToPlatform(SleepSession session);
}
```

---

## Known Limitations & Future Roadmap

- **Automatic Sleep Detection**: Automatic physiological sleep staging (REM, Deep, Light) requires hardware polysomnography or wearable pulse oximetry. SOMNA clearly labels tracked durations as self-reported or timer-based rather than fabricating physiological sensor readings.
- **Exact Alarms Policy**: Android 12+ requires explicit system permission for exact alarms. SOMNA requests inexact scheduling by default to preserve battery life while honoring user notification preferences.

---

## License

MIT License. Designed and built with premium craftsmanship for SOMNA.
