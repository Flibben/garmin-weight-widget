import Toybox.Application;
import Toybox.Application.Storage;
import Toybox.Application.Properties;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.UserProfile;

(:glance, :background)
class WeightHistoryManager {

    public static const STORAGE_KEY_RECORDS = "weight_records";
    public static const PROP_KEY_GLANCE_PERIOD = "glancePeriod";
    public static const PROP_KEY_GRAPH_PERIOD = "graphPeriod";
    public static const MAX_RECORDS = 400;

    // Glance comparison periods: 0=1D, 1=1W, 2=1M, 3=3M, 4=6M, 5=1Y
    public static const GLANCE_PERIOD_DAYS = [1, 7, 30, 90, 180, 365] as Array<Number>;
    public static const GLANCE_PERIOD_LABELS = ["1D", "1W", "1M", "3M", "6M", "1Y"] as Array<String>;

    // Graph range periods: 0=1W, 1=1M, 2=3M, 3=6M, 4=1Y
    public static const GRAPH_PERIOD_DAYS = [7, 30, 90, 180, 365] as Array<Number>;
    public static const GRAPH_PERIOD_LABELS = ["1W", "1M", "3M", "6M", "1Y"] as Array<String>;

    //! Read current weight from UserProfile and record it if available
    public static function recordCurrentWeight() as Float? {
        var profile = UserProfile.getProfile();
        if (profile != null && profile.weight != null && profile.weight > 0) {
            var weightGrams = profile.weight.toFloat();
            var today = (Time.today().value() / 86400).toNumber();

            var records = getRecords();
            var count = records.size();
            var updated = false;

            if (count > 0) {
                var lastEntry = records[count - 1] as Dictionary;
                if ((lastEntry["d"] as Number) == today) {
                    lastEntry["w"] = weightGrams;
                    updated = true;
                }
            }

            if (!updated) {
                var newEntry = {
                    "d" => today,
                    "w" => weightGrams
                };
                records.add(newEntry);
            }

            // Cap storage size if exceeding MAX_RECORDS
            if (records.size() > MAX_RECORDS) {
                var trimmed = [] as Array<Dictionary>;
                var startIdx = records.size() - MAX_RECORDS;
                for (var i = startIdx; i < records.size(); i++) {
                    trimmed.add(records[i] as Dictionary);
                }
                records = trimmed;
            }

            try {
                Storage.setValue(STORAGE_KEY_RECORDS, records);
            } catch (e) {
                // Storage exception handling
            }

            return weightGrams;
        }

        return getLatestWeight();
    }

    //! Retrieve all recorded entries from Application.Storage
    public static function getRecords() as Array<Dictionary> {
        try {
            var raw = Storage.getValue(STORAGE_KEY_RECORDS);
            if (raw != null && raw instanceof Array) {
                return raw as Array<Dictionary>;
            }
        } catch (e) {
            // Storage read fallback
        }
        return [] as Array<Dictionary>;
    }

    //! Get the latest recorded weight in grams
    public static function getLatestWeight() as Float? {
        var profile = UserProfile.getProfile();
        if (profile != null && profile.weight != null && profile.weight > 0) {
            return profile.weight.toFloat();
        }

        var records = getRecords();
        if (records.size() > 0) {
            var last = records[records.size() - 1] as Dictionary;
            return (last["w"] as Numeric).toFloat();
        }

        return null;
    }

    //! Unit conversion: grams -> kg or lbs based on device system settings
    public static function toDisplayWeight(grams as Float or Number) as Float {
        var settings = System.getDeviceSettings();
        if (settings.weightUnits == System.UNIT_METRIC) {
            return grams.toFloat() / 1000.0;
        } else {
            return grams.toFloat() / 453.59237;
        }
    }

    //! Get system unit label ("kg" or "lbs")
    public static function getUnitString() as String {
        var settings = System.getDeviceSettings();
        return (settings.weightUnits == System.UNIT_METRIC) ? "kg" : "lbs";
    }

    //! Format weight with 1 decimal place
    public static function formatWeight(grams as Float or Number) as String {
        return toDisplayWeight(grams).format("%.1f");
    }

    //! Format weight delta (+/- X.X) with 1 decimal place
    public static function formatDelta(deltaGrams as Float or Number) as String {
        var delta = toDisplayWeight(deltaGrams);
        if (delta > 0.0) {
            return "+" + delta.format("%.1f");
        } else {
            return delta.format("%.1f");
        }
    }

    //! Get current glance comparison period index (0 to 5)
    public static function getGlancePeriodIndex() as Number {
        try {
            var val = Properties.getValue(PROP_KEY_GLANCE_PERIOD);
            if (val != null && val instanceof Number) {
                if (val >= 0 && val < GLANCE_PERIOD_DAYS.size()) {
                    return val;
                }
            }
        } catch (e) {
        }
        return 1; // Default: 1 Week
    }

    public static function setGlancePeriodIndex(idx as Number) as Void {
        try {
            Properties.setValue(PROP_KEY_GLANCE_PERIOD, idx);
        } catch (e) {
        }
    }

    //! Get current graph period index (0 to 4)
    public static function getGraphPeriodIndex() as Number {
        try {
            var val = Properties.getValue(PROP_KEY_GRAPH_PERIOD);
            if (val != null && val instanceof Number) {
                if (val >= 0 && val < GRAPH_PERIOD_DAYS.size()) {
                    return val;
                }
            }
        } catch (e) {
        }
        return 0; // Default: 1 Week
    }

    public static function setGraphPeriodIndex(idx as Number) as Void {
        try {
            Properties.setValue(PROP_KEY_GRAPH_PERIOD, idx);
        } catch (e) {
        }
    }

    //! Calculate weight delta for a given number of days in the past
    public static function getDeltaForPeriod(periodDays as Number) as Float? {
        var records = getRecords();
        if (records.size() < 2) {
            return null;
        }

        var today = (Time.today().value() / 86400).toNumber();
        var targetDay = today - periodDays;

        var latestRecord = records[records.size() - 1] as Dictionary;
        var latestWeight = (latestRecord["w"] as Numeric).toFloat();

        // Find the record closest to targetDay
        var closestRecord = null as Dictionary?;
        var minDiff = 1000000;

        for (var i = 0; i < records.size(); i++) {
            var entry = records[i] as Dictionary;
            var d = entry["d"] as Number;
            var diff = (d - targetDay).abs();
            if (diff <= minDiff) {
                minDiff = diff;
                closestRecord = entry;
            }
        }

        if (closestRecord != null && closestRecord != latestRecord) {
            var pastWeight = (closestRecord["w"] as Numeric).toFloat();
            return latestWeight - pastWeight;
        }

        return null;
    }

    //! Calculate average weight in grams for a given period window
    public static function getAverageForPeriod(periodDays as Number) as Float? {
        var records = getRecordsInPeriod(periodDays);
        if (records.size() == 0) {
            return null;
        }

        var sum = 0.0;
        for (var i = 0; i < records.size(); i++) {
            var entry = records[i] as Dictionary;
            sum += (entry["w"] as Numeric).toFloat();
        }

        return sum / records.size();
    }

    //! Get [minGrams, maxGrams] within period
    public static function getMinMaxForPeriod(periodDays as Number) as [Float, Float]? {
        var records = getRecordsInPeriod(periodDays);
        if (records.size() == 0) {
            return null;
        }

        var first = (records[0]["w"] as Numeric).toFloat();
        var minW = first;
        var maxW = first;

        for (var i = 1; i < records.size(); i++) {
            var w = (records[i]["w"] as Numeric).toFloat();
            if (w < minW) {
                minW = w;
            }
            if (w > maxW) {
                maxW = w;
            }
        }

        return [minW, maxW];
    }

    //! Filter records falling within [today - periodDays, today]
    public static function getRecordsInPeriod(periodDays as Number) as Array<Dictionary> {
        var records = getRecords();
        var result = [] as Array<Dictionary>;
        if (records.size() == 0) {
            return result;
        }

        var today = (Time.today().value() / 86400).toNumber();
        var cutoff = today - periodDays;

        for (var i = 0; i < records.size(); i++) {
            var entry = records[i] as Dictionary;
            if ((entry["d"] as Number) >= cutoff) {
                result.add(entry);
            }
        }

        return result;
    }

    //! Testing tool: Generate 90 days of realistic synthetic history
    //! Strictly bounded to 0.1 - 0.4 kg day-to-day changes, anchored to current weight
    public static function generateDemoData() as Void {
        var today = (Time.today().value() / 86400).toNumber();
        var demoRecords = [] as Array<Dictionary>;

        // Anchor to user's actual current weight if available, otherwise default to 68.0 kg
        var currentWeight = getLatestWeight();
        if (currentWeight == null || currentWeight <= 0) {
            currentWeight = 68000.0;
        }

        var count = 91; // 90 days history + today
        var weights = new [count] as Array<Float>;
        weights[count - 1] = currentWeight;

        // Work backwards from today to day -90
        // Daily delta is strictly between -0.4 kg and +0.4 kg (typically 0.1 - 0.3 kg)
        var w = currentWeight;
        for (var i = count - 2; i >= 0; i--) {
            // Cyclical wave component (period of ~8 days for natural water weight cycles)
            var cycle = Math.sin((i * 0.78).toFloat()) * 120.0;
            // High frequency micro noise
            var noise = Math.cos((i * 2.3).toFloat()) * 90.0;
            // Very gentle long-term drift (starts ~1.6 kg higher 90 days ago)
            var progress = (90 - i).toFloat() / 90.0;
            var drift = progress * 1600.0;

            var target = currentWeight + drift + cycle + noise;

            // Enforce strict day-to-day delta limit: maximum 0.35 kg (350 grams) per day
            var delta = target - w;
            if (delta > 350.0) {
                delta = 350.0;
            } else if (delta < -350.0) {
                delta = -350.0;
            }

            // Round delta to nearest 100 grams for realistic scale precision (0.1 kg increments)
            var deltaSteps = (delta / 100.0).toNumber();
            var stepGrams = deltaSteps.toFloat() * 100.0;

            w = w + stepGrams;
            weights[i] = w;
        }

        for (var i = 0; i < count; i++) {
            var day = today - (count - 1 - i);
            demoRecords.add({
                "d" => day,
                "w" => weights[i]
            });
        }

        try {
            Storage.setValue(STORAGE_KEY_RECORDS, demoRecords);
        } catch (e) {
        }
    }

    //! Testing tool: Clear historical records, keeping only today's current weight
    public static function clearHistory() as Void {
        var latestWeight = getLatestWeight();
        var resetRecords = [] as Array<Dictionary>;
        if (latestWeight != null) {
            var today = (Time.today().value() / 86400).toNumber();
            resetRecords.add({
                "d" => today,
                "w" => latestWeight
            });
        }
        try {
            Storage.setValue(STORAGE_KEY_RECORDS, resetRecords);
        } catch (e) {
        }
    }

    //! Compute next 23:30 local moment for background logging
    public static function getNextScheduledMoment() as Time.Moment {
        var now = Time.now();
        var info = Gregorian.info(now, Time.FORMAT_SHORT);

        var targetOptions = {
            :year   => info.year,
            :month  => info.month,
            :day    => info.day,
            :hour   => 23,
            :minute => 30,
            :second => 0
        };

        var targetMoment = Gregorian.moment(targetOptions);

        // Ensure target is at least 5 minutes in the future to respect Garmin background limits
        if (targetMoment.value() <= (now.value() + 300)) {
            targetMoment = targetMoment.add(new Time.Duration(86400));
        }

        return targetMoment;
    }
}
