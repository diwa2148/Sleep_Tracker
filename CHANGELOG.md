# Changelog

All notable changes to the SOMNA — Smart Sleep Tracker application are documented in this file.

## [1.0.0] - 2026-10-26

### Initial Release
- **Module A: Onboarding & Personalization**
  - Added welcome presentation highlighting local-first privacy.
  - Implemented sleep goal slider (4h–12h, default: 8h).
  - Implemented target bedtime and wake schedule pickers.
  - Added optional bedtime reminder configuration.
  - Implemented persistent onboarding completion state in SharedPreferences.

- **Module B: Home Dashboard**
  - Implemented dynamic greeting, date, and goal badge.
  - Added circular progress ring displaying sleep progress against goal.
  - Added today's/last night's sleep summary card with bedtime, wake time, and rating.
  - Added 7-day mini trend preview bar chart with goal threshold line.
  - Added active session pulsing card with live elapsed timer.
  - Added consistency score and weekly average duration stat badges.
  - Added quick actions for "Start Sleep" and "Log Past".

- **Module C: Sleep Session Tracking**
  - Implemented live sleep timer with immediate SQLite persistence surviving app termination.
  - Built wake-up flow with interactive 5-star subjective quality rating and note input.
  - Implemented comprehensive manual entry & edit screen with native date/time pickers.
  - Added overnight session handling and multi-day validation.
  - Implemented overlap collision detection.

- **Module D: Sleep History**
  - Added chronological session feed grouped by day.
  - Added filter chips: All Time, This Week, Last Week, This Month.
  - Implemented swipe-to-delete with confirmation modal.
  - Implemented session detail modal sheet with full duration, times, quality stars, and notes.

- **Module E: Advanced Sleep Analytics**
  - Implemented 7-day and 30-day view switcher.
  - Built custom interactive canvas bar charts for daily sleep duration.
  - Implemented directional circular mathematics for bedtimes and wake times clustering around midnight.
  - Added circular bedtime consistency index (0–100%).
  - Added week-over-week duration difference tracking ($\pm$ minutes).
  - Added duration variability (standard deviation) and extremes (shortest/longest sessions).

- **Module F: Deterministic Sleep Insights**
  - Implemented transparent, explainable insight engine with zero hallucinated sleep stages.
  - Added goal streak, goal deficit, bedtime stability, and quality correlation observations.
  - Added calculation explanations attached to every insight.
  - Added foundational sleep hygiene guidance tips.

- **Module G: Bedtime & Wake-Up Reminders**
  - Implemented local notifications with independent toggles.
  - Configured Android permissions and broadcast receivers.

- **Module H & I: Settings & Personalization**
  - Added sleep goal and schedule customization.
  - Added theme switching: System Default, Dark Mode, and Light Mode.
  - Added haptic feedback toggle.
  - Implemented factory reset with double confirmation.

- **Module J: Data Management & Privacy**
  - Implemented RFC-4180 compliant CSV export with proper escaping for quotes, commas, and newlines.
  - Implemented structured JSON export with share sheet integration.
  - Created Privacy Policy Charter modal.

- **Automated Verification**
  - Added 33 unit and widget tests covering models, mathematical engines, SQLite persistence, and UI journeys.
  - Clean static analysis with 0 errors, 0 warnings, and 0 lints.
