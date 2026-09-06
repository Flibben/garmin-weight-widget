# Garmin Weight Tracker Widget (Fenix 7 / 7S Pro / 7X)

A native Garmin Connect IQ Glance Widget built for the **Garmin Fenix 7 series** (Fenix 7, 7S, 7X, and Pro editions). It automatically captures your daily scale weigh-ins from `UserProfile.getProfile().weight`, logs history locally on watch flash storage (`Application.Storage`), and renders an interactive auto-scaling line graph with rolling averages and deltas across multiple timeframes.

![Fenix 7S Pro](https://img.shields.io/badge/Device-f%C4%93nix%C2%AE%207S%20Pro-blue)
![Connect IQ](https://img.shields.io/badge/Connect%20IQ-System%207%20%7C%20CIQ%205.x-orange)
![License](https://img.shields.io/badge/License-MIT-green)

---

## Features

* **Glance Loop Preview:** Shows current weight, system unit (`kg` or `lbs`), and comparison delta (e.g. `68.0 kg  -0.3 kg (1W)`).
* **Interactive Full-Screen Graph:**
  * Auto-scaled Y-axis with top/bottom padding to prevent bezel clipping.
  * Dashed reference line for the **Period Average**.
  * High-precision vector curve connecting daily points with anti-aliasing.
  * Dot marker on the latest weigh-in point.
* **5 Switchable Timeframes:**
  * `1W` (1 Week)
  * `1M` (1 Month)
  * `3M` (3 Months)
  * `6M` (6 Months)
  * `1Y` (1 Year)
* **Bezel-Safe Navigation:**
  * Clean 5-dot page indicator at the bottom curve (`● ○ ○ ○ ○`).
  * Switch ranges via physical buttons (`UP`/`DOWN`), touch swipes (left/right), or tapping arrows (`◀ 1W ▶`).
* **Canonical Gram Storage & Flawless Unit Switching:**
  * All historical records are stored strictly in raw **Grams** (`weight_records`), mirroring Garmin scale precision.
  * Dynamic presentation conversion based on `System.getDeviceSettings().weightUnits`. Switching units between `kg` and `lbs` months later causes zero conversion loss.
* **Background Daily Sync at 23:30:**
  * Uses `Toybox.Background` temporal events scheduled for 23:30 daily (compatible with 12h and 24h clocks) to capture your scale's latest weigh-in before midnight.
  * Real-time daytime glance and app opens also update today's record automatically.
* **On-Device Menu & Testing Tools:**
  * Long-press `UP` or press `START` in the app to configure comparison ranges.
  * Includes a **"Generate Demo Data"** tool (generates 90 days of realistic 0.1–0.4 kg daily fluctuations) and **"Clear History"** tool.

---

## Project Structure

```
├── .vscode/
│   └── launch.json                # 1-click debugging configuration in VS Code
├── resources/
│   ├── bitmaps.xml                # Launcher icon resource definition
│   ├── images/launcher_icon.png   # 40x40 launcher icon
│   ├── settings/
│   │   ├── properties.xml         # Persistent properties defaults
│   │   └── settings.xml           # Mobile app settings schema (Garmin Connect)
│   └── strings/strings.xml        # Localization and UI strings
├── source/
│   ├── WeightHistoryManager.mc    # Data model, unit conversion, storage, statistics
│   ├── WeightTrackerApp.mc        # Main App entry point & background lifecycle
│   ├── WeightTrackerGlanceView.mc # Glance loop renderer
│   ├── WeightTrackerView.mc       # Full-screen vector graph & stats view
│   ├── WeightTrackerDelegate.mc   # Button & touch input delegate
│   ├── WeightTrackerMenuDelegate.mc # On-device Settings2 menu handler
│   ├── WeightTrackerServiceDelegate.mc # 23:30 background sync service
│   └── WeightTrackerTests.mc      # Automated unit tests
├── build_and_run.ps1              # PowerShell helper script to compile & launch simulator
├── manifest.xml                   # Connect IQ manifest
└── monkey.jungle                  # Jungle build configuration
```

---

## Getting Started

### Prerequisites
* [Garmin Connect IQ SDK Manager](https://developer.garmin.com/connect-iq/sdk/) (System 7 / SDK 7.x or later)
* Java JDK 11 or later
* VS Code with the official `garmin.monkey-c` extension
* A Garmin Developer Key (`developer_key.der`)

### Building from Command Line
```powershell
# Run the included build script:
.\build_and_run.ps1
```

Or manually with `monkeyc`:
```powershell
monkeyc -f monkey.jungle -d fenix7spro -o bin\WeightTracker.prg -y path\to\developer_key -w
```

### Running in VS Code
1. Open the repository folder in VS Code.
2. Press **`F5`** to build and launch directly in the Garmin Connect IQ Simulator.

### Installing on Physical Watch
1. Connect your Fenix 7S Pro (or compatible Fenix 7) via USB.
2. Copy `bin/WeightTracker.prg` to `This PC\[Your Watch]\Primary\GARMIN\APPS\`.
3. Disconnect your watch; the widget will appear in your glance loop.

---

## License
MIT License
