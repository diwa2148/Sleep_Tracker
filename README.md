# SOMNA — Smart Sleep Tracker & Circadian Companion

[![Flutter](https://img.shields.io/badge/Flutter-3.47.8-000000?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13.7-000000?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/license-MIT-000000?style=for-the-badge)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-000000?style=for-the-badge)](https://flutter.dev)
[![Tests](https://img.shields.io/badge/Tests-64%20Passing%20(100%25)-000000?style=for-the-badge)](test/)

> **Live Web Application**: [https://sleeptracker-diwa2148s-projects.vercel.app](https://sleeptracker-diwa2148s-projects.vercel.app)

A privacy-first, offline-first sleep companion designed to help users track, understand, and master their sleep cycles and circadian regularity without sacrificing privacy or requiring cloud accounts. Built with a high-contrast **solid monochrome retro hi-fi aesthetic** inspired by Braun, Teenage Engineering, and vintage laboratory instruments.

---

## Table of Contents

- [Live Deployment](#live-deployment)
- [Overview & Philosophy](#overview--philosophy)
- [Comprehensive Feature Suite](#comprehensive-feature-suite)
- [Design System & Aesthetics](#design-system--aesthetics)
- [Architecture & Tech Stack](#architecture--tech-stack)
- [Directory Structure](#directory-structure)
- [Database Schema & Data Model](#database-schema--data-model)
- [Mathematical Engine & Algorithms](#mathematical-engine--algorithms)
- [Audio & Procedural Sound Engine](#audio--procedural-sound-engine)
- [Automated Testing Suite](#automated-testing-suite)
- [Installation & Local Running](#installation--local-running)
- [Privacy & Security Charter](#privacy--security-charter)
- [License](#license)

---

## Live Deployment

SOMNA is continuously built and deployed to production via Vercel:
- **Production URL**: [https://sleeptracker-diwa2148s-projects.vercel.app](https://sleeptracker-diwa2148s-projects.vercel.app)
- **Local SQLite / IndexedDB**: Sessions and preferences persist across web page reloads via `sqflite_common_ffi_web`.
- **Hardware Audio Integration**: Utilizes the modern HTML5 Web Audio API `AudioContext` with zero external audio assets required.

---

## Overview & Philosophy

Commercial sleep tracking applications frequently impose intrusive trade-offs: wearable sensor lock-ins, subscription paywalls, and mandatory cloud synchronization that monetizes intimate biometric records.

**SOMNA** (*Latin for dreams/sleep*) operates on a strict **local-first, deterministic philosophy**:
- **Zero Mandatory Accounts**: No sign-up, email, phone number, or passwords required.
- **100% Offline-First**: All session logs, ratings, and preferences reside strictly within local SQLite tables on your device.
- **Rigorous Circular Time Mathematics**: Solves circular time averaging around midnight using directional trigonometry ($R$ vector and angular atan2 averaging).
- **Explainable Insights**: Transparent observations with mathematically verifiable calculations rather than black-box fabricated sleep stages.
- **Pure Solid Monochrome Design**: Black and white typography, razor-sharp 0px borders, and physical tactile feel.

---

## Comprehensive Feature Suite

### 1. Onboarding & Circadian Personalization
- Multi-step introductory flow establishing privacy commitments.
- Sleep duration target slider (4h to 12h, default: 8h).
- Target bedtime and wake-up time selectors.
- Persistent onboarding completion state with skip capabilities.

### 2. Home Dashboard & Live Session Command Center
- Dynamic time-aware greeting and formatted system date.
- Circular sleep summary progress ring contrasting actual sleep against personal targets.
- **Circadian Window Card**: Real-time sleep gate visualization highlighting optimal sleep onset times.
- Last night's bedtime and wake-up recap with qualitative badges.
- Weekly average duration and circular circadian consistency gauge ($R$).
- 7-day mini trend preview bar chart with target threshold line.
- Quick navigation shortcuts to Sound Machine, Breath Pacer, Cycle Calculator, and Badges.

### 3. Active Sleep Tracker & Wake-Up Flow
- **Authoritative Elapsed Clock**: Timer derived from authoritative start timestamps (`DateTime.now().difference(start)`), immune to background process suspends and OS reboots.
- **Instant Persistence**: Active state stored in SQLite (`end_timestamp IS NULL`).
- **Wake Up Modal**: 5-star rating selector, factor tagging chips, and freeform notes.
- Safety cancellation safeguards with dual-action confirmation modals.

### 4. Sleep History Log & In-Place Session Editor
- Chronological session feed grouped into daily cards.
- Quick filters: **All Time**, **This Week**, **Last Week**, and **This Month**.
- **In-Place Detail Editor Sheet** (`SessionDetailSheet`):
  - **In-Place Time Adjustments**: Direct tapping on Bedtime and Wake-Up cards launches native time pickers with overnight validation and instant duration recalculation.
  - **Interactive Star Rating**: Tap to adjust rating (1–5 stars) with qualitative descriptions (`Poor` to `Excellent`).
  - **Factor Tagging Wrap**: 8 monochrome lifestyle toggle chips (☕ Caffeine, 🏃 Workout, 📱 Late Screen, 📖 Reading, 🧘 Meditated, ❄️ Cool Room, 🍷 Alcohol, ⚡ Stress) with active count indicator.
  - **Inline Notes Observation Editor**: Edit custom session notes in-place without overwriting lifestyle tags.
  - **RepaintBoundary Optimization**: High-efficiency repaint isolation for smooth 60fps keyboard and scroll interactions.

### 5. Advanced Sleep Analytics & Sleep Debt Ledger
- **Rolling Period Selector**: Switch seamlessly between 7-day and 30-day analytics.
- **Canvas Bar Chart**: Daily durations with goal threshold dashed line.
- **Circular Bedtime & Wake-Up Averages**: Trigonometric circular mean preventing midnight distortion.
- **Goal Completion Rate**: Accurate percentage of sessions meeting or exceeding target duration.
- **Circadian Regularity Score**: Directional vector length ($R \times 100\%$).
- **Habit Impact Correlations Card** (`HabitImpactCard`): Quantifies duration impact for each lifestyle tag (e.g. `+42m when Reading`, `-38m when Late Screen`).
- **Retro Sleep Debt Ledger & Bank** (`SleepDebtLedgerCard`):
  - 80s mechanical dot-matrix banking ledger card.
  - **Net Reserve Balance**: Explicit surplus (`+`) or deficit (`-`) in minutes and hours.
  - **Solvency Index**: Percentage score evaluating total actual sleep vs total expected target sleep over the rolling window.
  - **Recovery Run-Rate Guidance**: Realistic catch-up recommendations (e.g. `+30m over 4 nights`).
  - **Mechanical Daily Tallies Table**: Daily breakdown showing `DATE`, `ACTUAL`, `TARGET`, and `NET TALLY`.

### 6. Sleep Stages Hypnogram Visualizer
- Canvas-rendered sleep architecture graph mapping sessions into 90-minute sleep cycles.
- Color-coded stage breakdown: **Awake**, **REM**, **Light Sleep**, and **Deep Sleep**.
- Detailed interactive modal (`SleepStagesDetailModal`) breaking down cycle counts, stage percentages, and sleep quality benchmarks.

### 7. Procedural Ambient Sound Machine
- Native Web Audio synthesizer (`somna_audio_synth.js`) producing procedural soundscapes:
  - **White Noise**: Crisp flat-spectrum acoustic masking.
  - **Pink Noise**: Deep $1/f$ natural pink noise.
  - **Brownian Noise**: Low-frequency rumble ($1/f^2$).
  - **Gentle Rain**: Bandpass-filtered procedural rainfall.
  - **Ocean Waves**: Slow LFO-modulated surf swells.
  - **Forest Stream**: Dynamic babbling water resonance.
- Master volume slider and sleep timer countdown presets (15m, 30m, 45m, 60m).

### 8. Retro Synthesizer Alarm Deck
- Standalone hardware-inspired alarm card (`RetroAlarmDeckCard`).
- 4 procedurally generated 8-bit alarm tones:
  - `8bit_dawn`: Nostalgic ascending chip arp.
  - `classic_beep`: Resonant 880Hz laboratory pulse.
  - `cyber_pulse`: Syncopated sci-fi waking rhythm.
  - `soft_marimba`: Warm melodic wooden mallet chime.
- **Gentle Ramp**: 30-second smooth acoustic fade-in.
- **Interactive Alarm Modal**: Real-time snooze button (9m) and one-tap stop.

### 9. 4-7-8 Rhythmic Breathing Pacer
- Modal breathing trainer based on Dr. Andrew Weil's 4-7-8 parasympathetic calming technique.
- Geometric pulsating guide:
  - **Inhale**: 4 seconds smooth expansion.
  - **Hold**: 7 seconds steady pause.
  - **Exhale**: 8 seconds smooth contraction.
- Cycle counter and real-time phase indicators.

### 10. Thermal Sleep Receipt Slip Modal
- Japanese convenience store / 80s register slip aesthetic (`SleepReceiptSlip`).
- Monospace dot-matrix layout with session breakdown, sleep debt tally, quality ratings, and factor breakdown.
- Dynamic ASCII barcode generator and share/save capabilities.

### 11. Retro Achievement Badges & Awards Deck
- Milestone evaluation engine (`BadgeEngine`) rewarding consistent sleep hygiene:
  - 🌙 **First Drift**: First recorded sleep session.
  - 🔥 **Circadian Master**: 7 consecutive days meeting sleep target.
  - 🧘 **Zen Sleeper**: 5 sessions logged with meditation or reading tags.
  - 🦉 **Night Owl**: 3 sessions logged starting after midnight.
  - 🌅 **Early Bird**: 5 sessions with wake times before 07:00 AM.
  - 🛡️ **Iron Rhythm**: Circadian consistency score above 90%.
- Interactive badge inspection dialog with unlock timestamps and criteria.

### 12. Sleep Cycle Calculator & Smart Wake Window
- 90-minute ultradian cycle planner (`SleepCycleCard`).
- Calculates optimal wake times from current time or planned bedtime, incorporating a 15-minute average sleep latency.
- Calculates ideal bedtimes to wake up refreshed at a specific target time.

### 13. Data Management & Export
- **RFC-4180 CSV Export**: Standard comma-separated export with robust escaping for commas, quotes, and newlines.
- **JSON Backup**: Complete machine-readable data dump for backup and migration.
- System share sheet integration via `share_plus`.
- Factory reset utility with destructive confirmation safeguards.

---

## Design System & Aesthetics

SOMNA employs a bespoke **Solid Monochrome Retro Hi-Fi** design language:
- **Pure High-Contrast Palette**:
  - Pure Black: `#000000`
  - Pure White: `#FFFFFF`
  - High-Contrast Inverted Surfaces: Solid filled badges and tags with 0px corner radii.
  - No hatching, stippling, or blurry gradients; clean solid fills and sharp strokes.
- **Typography**: Clean modern sans-serif (**Poppins**) paired with monospace figures (`RobotoMono` / system monospace) for tabular clock timers and financial-style ledgers.
- **CRT Scanline Overlay**: Optional subtle retro cathode-ray tube horizontal scanline effect (`CrtScanlineOverlay`).
- **Haptic Feedback**: Tactile click feedback on button presses, rating adjustments, and tag toggles.

---

## Architecture & Tech Stack

```
                     ┌───────────────────────────────┐
                     │          Presentation         │
                     │  (Screens, Widgets, Sheets)   │
                     └───────────────┬───────────────┘
                                     │
                     ┌───────────────▼───────────────┐
                     │        State Management       │
                     │  (Provider / ChangeNotifiers) │
                     └───────────────┬───────────────┘
                                     │
                     ┌───────────────▼───────────────┐
                     │       Service / Domain        │
                     │ (Analytics, Synth, Badges)    │
                     └───────────────┬───────────────┘
                                     │
                     ┌───────────────▼───────────────┐
                     │       Repository Layer        │
                     │ (SleepRepository, Preferences)│
                     └───────────────┬───────────────┘
                                     │
                     ┌───────────────▼───────────────┐
                     │        Local Database         │
                     │   (SQLite / sqflite_common)   │
                     └───────────────────────────────┘
```

- **Framework**: Flutter (Channel Stable 3.47.8)
- **Language**: Dart (3.13.7) with sound null safety
- **State Management**: `provider: ^6.1.2`
- **Database**: `sqflite: ^2.4.1` + `sqflite_common_ffi: ^2.3.4+4` + `sqflite_common_ffi_web: ^0.4.5`
- **Preferences**: `shared_preferences: ^2.3.3`
- **Notifications**: `flutter_local_notifications: ^18.0.1`
- **Export & Sharing**: `share_plus: ^10.1.2` + `path_provider: ^2.1.5`
- **Date & Time Formatting**: `intl: ^0.20.3`
- **Audio Synthesis**: Native HTML5 Web Audio API (`AudioContext`, `BiquadFilterNode`, `OscillatorNode`, `GainNode`)

---

## Directory Structure

```
lib/
├── app/
│   ├── app.dart                   # MultiProvider & MaterialApp configuration
│   ├── app_config.dart            # Global configurations & constants
│   ├── main_screen.dart           # 5-tab root scaffold & retro nav bar
│   └── theme/
│       ├── app_colors.dart        # Pure monochrome black & white palette
│       ├── app_theme.dart         # Material 3 ThemeData configurations
│       └── app_typography.dart    # Poppins & monospace typographic scale
├── core/
│   ├── utils/
│   │   ├── date_time_formatter.dart # Date/time/duration formatting helpers
│   │   └── time_calculator.dart     # Circular math, overlap collision detection
│   └── widgets/
│       ├── crt_scanline_overlay.dart # Retro CRT monitor scanlines
│       ├── somna_button.dart        # Sharp high-contrast button with haptics
│       ├── somna_card.dart          # 0px bordered monochrome card container
│       ├── somna_stat_badge.dart    # Metric display block
│       └── star_rating_bar.dart     # Interactive 5-star rating bar
├── features/
│   ├── achievements/              # BadgeEngine & Retro Badges Deck Modal
│   ├── alarm/                     # RetroAlarmDeckCard & Tone Synthesizer
│   ├── analytics/
│   │   ├── presentation/          # Analytics screen & charts
│   │   └── widgets/
│   │       ├── duration_bar_chart.dart
│   │       ├── habit_impact_card.dart
│   │       └── sleep_debt_ledger_card.dart # 80s Dot-Matrix Sleep Debt Ledger
│   ├── dashboard/
│   │   └── presentation/widgets/
│   │       ├── active_session_card.dart
│   │       ├── circadian_window_card.dart
│   │       ├── sleep_stages_card.dart      # Hypnogram architecture preview
│   │       └── sleep_summary_ring.dart
│   ├── history/
│   │   └── presentation/
│   │       ├── history_screen.dart
│   │       └── session_detail_sheet.dart  # In-place time, factor & note editor
│   ├── insights/
│   │   └── presentation/          # Deterministic explainable observations
│   ├── onboarding/
│   │   └── presentation/          # Personalization & privacy wizard
│   ├── receipt/                   # Thermal Sleep Receipt Slip modal
│   ├── settings/
│   │   └── presentation/          # Preferences, audio toggles, CSV export
│   ├── sleep_cycle/               # Ultradian 90-min cycle calculator
│   ├── sleep_tracking/
│   │   └── presentation/          # Manual entry & live wake-up modal
│   ├── sound_machine/             # Ambient noise synthesizer & presets
│   └── wind_down/                 # 4-7-8 Breathing Pacer modal
├── shared/
│   ├── models/
│   │   ├── sleep_factor.dart      # Lifestyle factor tags & icons
│   │   ├── sleep_insight.dart     # Deterministic insight structure
│   │   ├── sleep_session.dart     # SQLite session model with tags parser
│   │   ├── sleep_stats.dart       # Statistical aggregates
│   │   └── user_preferences.dart  # Persisted settings model
│   ├── providers/
│   │   ├── alarm_provider.dart
│   │   ├── settings_provider.dart
│   │   ├── sleep_tracker_provider.dart
│   │   └── sound_machine_provider.dart
│   ├── repositories/
│   │   ├── preferences_repository.dart
│   │   └── sleep_repository.dart
│   └── services/
│       ├── analytics_service.dart # Rollups, circular averages, habit correlations
│       ├── database_service.dart  # SQLite tables & indexes
│       ├── export_service.dart    # RFC-4180 CSV & JSON exporters
│       └── insight_engine.dart    # Deterministic observation engine
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
| `notes` | TEXT | NULLABLE | Freeform tags, lifestyle chips, and notes |
| `source` | TEXT | NOT NULL | `'timer'`, `'manual'`, or `'imported'` |
| `created_at` | INTEGER | NOT NULL | Record creation timestamp in UTC ms |
| `updated_at` | INTEGER | NOT NULL | Record last updated timestamp in UTC ms |

Indexes:
- `idx_sleep_sessions_start` on `start_timestamp DESC`
- `idx_sleep_sessions_end` on `end_timestamp DESC`

---

## Mathematical Engine & Algorithms

### 1. Directional Circular Mean for Bedtime and Wake-Up Times
Direct arithmetic averaging of clock times around midnight produces disastrous artifacts (e.g. 23:30 and 00:30 averaging to 12:00 noon).

SOMNA maps minute $m_i \in [0, 1440)$ to angular coordinates on the unit circle:
$$\theta_i = \frac{2\pi m_i}{1440}$$
$$\bar{x} = \frac{1}{N} \sum_{i=1}^N \cos(\theta_i), \quad \bar{y} = \frac{1}{N} \sum_{i=1}^N \sin(\theta_i)$$
$$\bar{\theta} = \operatorname{atan2}(\bar{y}, \bar{x}) \pmod{2\pi}$$
$$\text{Average Minute} = \operatorname{round}\left(\frac{\bar{\theta} \times 1440}{2\pi}\right) \pmod{1440}$$

### 2. Circadian Consistency Score ($R$)
Directional statistics provide the mean resultant vector length $R \in [0, 1]$:
$$R = \sqrt{\bar{x}^2 + \bar{y}^2}$$
$$\text{Consistency Index} = \operatorname{round}(R \times 100)$$
- $R = 1.0 \implies 100\%$ consistency (identical bedtime every day).
- $R < 0.6 \implies$ irregular sleep onset indicating social jetlag.

### 3. Net Sleep Debt & Solvency Index
In the **Sleep Debt Ledger**:
$$\text{Net Balance} = \sum_{i=1}^N (\text{Actual Duration}_i - \text{Goal Duration}_i)$$
$$\text{Solvency Index} = \operatorname{clamp}\left(0, 100, \operatorname{round}\left(\frac{\sum \text{Actual}}{\sum \text{Goal}} \times 100\right)\right)$$

### 4. Session Overlap Collision Detection
Two sessions $[S_A, E_A]$ and $[S_B, E_B]$ overlap if and only if:
$$S_A < E_B \quad \text{and} \quad E_A > S_B$$

---

## Audio & Procedural Sound Engine

SOMNA incorporates a procedural synthesizer (`web/somna_audio_synth.js`) operating directly via the HTML5 Web Audio API:
- **Zero MP3/WAV Assets**: No external audio network requests or file overhead.
- **Pink & Brownian Noise Generators**: Employs mathematical Paul Kellet white-to-pink multi-pole filter algorithms and Brownian integration ($y_n = y_{n-1} + 0.02x$).
- **Dual Biquad Filtering**: Resonant low-pass and band-pass modulation to simulate natural rain and ocean surf rhythmicity.
- **4 Custom Synthesizer Alarm Patches**:
  - `8bit_dawn`: Fast arpeggiated major triad square wave.
  - `classic_beep`: High-Q band-limited 880Hz square pulse.
  - `cyber_pulse`: Dotted eighth frequency-modulated chirp.
  - `soft_marimba`: Sine oscillator with exponential decay envelope simulating wooden physical resonance.

---

## Automated Testing Suite

SOMNA boasts an automated test suite with **64 passing tests** across unit, widget, and end-to-end integration flows:

```bash
flutter test
```

### Test Coverage Highlights:
- **Unit Tests (49 tests)**:
  - `test/unit/time_calculator_test.dart`: Circular bedtime math, 24h validations, multi-day intervals, and overlap algorithms.
  - `test/unit/database_service_test.dart`: In-memory SQLite CRUD, active session recovery, and collision queries.
  - `test/unit/analytics_service_test.dart`: Rolling averages, duration deltas, and goal completion rates.
  - `test/unit/sleep_factor_test.dart`: Tag extraction, note parsing, and habit impact correlation calculations.
  - `test/unit/badge_engine_test.dart`: Evaluation logic for all 6 retro achievement badges.
  - `test/unit/sleep_receipt_test.dart`: ASCII register ticket and barcode generation.
  - `test/unit/sound_machine_test.dart`: Track selection, volume clamping, and timer updates.
  - `test/unit/alarm_tone_test.dart`: Alarm tone presets, gentle volume ramp, and preview toggling.
  - `test/unit/sleep_cycle_calculator_test.dart`: 90-minute ultradian wake and bedtime projections.
  - `test/unit/export_service_test.dart`: RFC-4180 CSV escaping for quotes, commas, and newlines; JSON schema fidelity.
  - `test/unit/insight_engine_test.dart`: Deterministic rule evaluations and explanation strings.
- **Widget & E2E Tests (15 tests)**:
  - `test/widget/session_detail_sheet_test.dart`: In-place factor toggling, inline note editing, and interactive rating upgrade.
  - `test/widget/sleep_debt_ledger_test.dart`: Solvency score and net debt tally table rendering.
  - `test/widget/dashboard_test.dart`: Empty dashboard rendering and active timer activation.
  - `test/widget/manual_entry_test.dart`: Form validation, scroll interactions, and session creation.
  - `test/widget/e2e_journey_test.dart`: Comprehensive user journey verifying Onboarding, Timer Start, Wake-Up, History in-place editing, Settings, and Insights.
  - `test/widget_test.dart`: App smoke test and 5-tab root navigation.

---

## Installation & Local Running

### Prerequisites
- **Flutter SDK**: 3.47.8 or higher (`flutter --version`)
- **Dart SDK**: 3.13.7 or higher

### Steps
1. **Clone the repository**:
   ```bash
   git clone https://github.com/diwa2148/Sleep_Tracker.git
   cd Sleep_Tracker
   ```

2. **Install Flutter packages**:
   ```bash
   flutter pub get
   ```

3. **Verify static analysis**:
   ```bash
   flutter analyze
   ```

4. **Run test suite**:
   ```bash
   flutter test
   ```

5. **Run application**:
   ```bash
   # Run on Chrome Web
   flutter run -d chrome

   # Or run on Android / iOS connected device
   flutter run
   ```

---

## Privacy & Security Charter

- **No Third-Party Telemetry**: Zero analytics SDKs (No Firebase, Mixpanel, Google Analytics, or Sentry).
- **Zero Cloud Storage**: All notes, lifestyle tags, ratings, and timestamps remain exclusively inside local device storage.
- **Full Data Sovereignty**: Immediate one-click CSV/JSON export or permanent factory wipe at any time.

---

## License

MIT License. Designed and built with pride for **SOMNA**.
