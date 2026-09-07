# Garmin Connect IQ Store Listing Assets & Guide

Use this document to quickly publish **Weight Tracker & Trends** to the Garmin Connect IQ Store.

---

## 1. App Metadata

### Application Name
**Weight Tracker & Trends**

### Short Description (Tagline)
Automated daily weight tracking from your Garmin scale with glance widgets and interactive multi-timeframe trend graphs.

### Category
- **Primary:** Health & Fitness
- **Secondary:** Utilities

---

## 2. Full Description (Markdown for Store Listing)

```markdown
**Weight Tracker & Trends** brings seamless, automatic weight history and interactive trend analysis right to your Garmin watch.

Whether you weigh in with a Garmin Index / Index S2 smart scale or sync your weight from Garmin Connect, this widget keeps your latest weight, period deltas, and long-term trends right at your fingertips in your daily glance loop.

### 🌟 Key Features
- **Effortless & Automated:** Reads directly from your Garmin profile daily at 23:30. No manual entry or companion app required.
- **Glance Carousel Overview:** View your latest weight, units, and customizable comparison delta (e.g. -0.4 kg over 1W) without opening the full widget.
- **Interactive Full-Screen Graph:**
  - Dynamic anti-aliased vector trend line auto-scaled to your data.
  - Dashed reference line showing your **Period Average**.
  - 5 Selectable Timeframes: **1 Week, 1 Month, 3 Months, 6 Months, and 1 Year**.
- **Intuitive Controls:**
  - Swipe left/right or tap arrows / bottom dots to change timeframes.
  - Full button support: UP/DOWN cycles timeframes; START/ENTER opens settings.
- **Smart Unit Support:** Automatically respects your watch profile settings (kg or lbs) and seamlessly recalculates all statistics and graphs if you switch units.
- **Privacy-First & Battery Efficient:** 100% on-device storage. Never drains battery in the background and zero personal health data leaves your watch.

---

### ⚙️ How to Configure
1. Add **Weight Tracker** to your watch's Widget / Glance loop.
2. Select the glance to open the full trend graph.
3. Press **START** or long-press **UP** (or tap anywhere on the graph) to open **Weight Settings**:
   - **Glance Range:** Choose the comparison timeframe displayed on the glance (1 Day, 1 Week, 1 Month, 3 Months, 6 Months, 1 Year).
   - **Graph Range:** Set your default graph zoom level.
```

---

## 3. Privacy Policy Declaration

```text
Privacy Policy for Weight Tracker & Trends

Weight Tracker & Trends is committed to total user privacy:
1. Data Storage: All weigh-in data is cached exclusively on your local Garmin device using Connect IQ secure Application.Storage.
2. Zero Data Transmission: The application contains no internet permissions and transmits zero telemetry, personal data, or health records to any third-party server or developer backend.
3. Profile Access: Weight data is read strictly from Garmin's standard UserProfile API.
```

---

## 4. Visual Assets

| Asset | Location | Specifications |
| :--- | :--- | :--- |
| **Store App Icon** | `resources/images/store_icon_512.png` | 512×512 PNG, dark theme with scale & cyan trend line |
| **Export Package** | `bin/WeightTracker.iq` | Signed 60-device universal archive (CIQ 4.0+) |

---

## 5. How to Upload to Garmin Connect IQ

1. Log in to the [Garmin Connect IQ Developer Dashboard](https://apps.garmin.com/developer/dashboard).
2. Click **"Upload an App"**.
3. Select the file: `bin/WeightTracker.iq`.
4. Upload the store icon: `resources/images/store_icon_512.png`.
5. Paste the Title, Short Description, and Full Description above.
6. (Optional) In the Connect IQ Simulator, open the app, press `Ctrl+S` to capture 1-2 screenshots of the graph, and upload them under "Screenshots".
7. Click **Submit for Review**.
