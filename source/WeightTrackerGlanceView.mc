import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

(:glance)
class WeightTrackerGlanceView extends WatchUi.GlanceView {

    public function initialize() {
        GlanceView.initialize();
    }

    public function onUpdate(dc as Graphics.Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        // Update / record weight if available on this glance pass
        var currentWeight = WeightHistoryManager.recordCurrentWeight();
        var unit = WeightHistoryManager.getUnitString();

        var width = dc.getWidth();
        var height = dc.getHeight();

        // 1. Top Title
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            0,
            2,
            Graphics.FONT_GLANCE,
            "WEIGHT",
            Graphics.TEXT_JUSTIFY_LEFT
        );

        if (currentWeight != null) {
            var weightStr = WeightHistoryManager.formatWeight(currentWeight);
            var periodIdx = WeightHistoryManager.getGlancePeriodIndex();
            var periodDays = WeightHistoryManager.GLANCE_PERIOD_DAYS[periodIdx];
            var periodLabel = WeightHistoryManager.GLANCE_PERIOD_LABELS[periodIdx];
            var delta = WeightHistoryManager.getDeltaForPeriod(periodDays);

            // 2. Weight Number
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                0,
                height / 2 - 2,
                Graphics.FONT_GLANCE_NUMBER,
                weightStr,
                Graphics.TEXT_JUSTIFY_LEFT
            );

            // Calculate offset for unit string
            var numDim = dc.getTextDimensions(weightStr, Graphics.FONT_GLANCE_NUMBER);
            var xOffset = numDim[0] + 4;

            // 3. Unit Label
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                xOffset,
                height / 2 + 2,
                Graphics.FONT_GLANCE,
                unit,
                Graphics.TEXT_JUSTIFY_LEFT
            );

            // 4. Delta String
            if (delta != null) {
                var deltaStr = WeightHistoryManager.formatDelta(delta) + " (" + periodLabel + ")";
                var deltaColor = Graphics.COLOR_LT_GRAY;

                if (delta < -0.05) {
                    deltaColor = Graphics.COLOR_GREEN;
                } else if (delta > 0.05) {
                    deltaColor = Graphics.COLOR_ORANGE;
                }

                dc.setColor(deltaColor, Graphics.COLOR_TRANSPARENT);
                var unitDim = dc.getTextDimensions(unit, Graphics.FONT_GLANCE);
                var deltaX = xOffset + unitDim[0] + 8;

                if (deltaX < width - 10) {
                    dc.drawText(
                        deltaX,
                        height / 2 + 2,
                        Graphics.FONT_GLANCE,
                        deltaStr,
                        Graphics.TEXT_JUSTIFY_LEFT
                    );
                }
            }
        } else {
            // No weight recorded yet
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                0,
                height / 2 - 2,
                Graphics.FONT_GLANCE_NUMBER,
                "--.-",
                Graphics.TEXT_JUSTIFY_LEFT
            );
            dc.drawText(
                55,
                height / 2 + 2,
                Graphics.FONT_GLANCE,
                "Sync scale",
                Graphics.TEXT_JUSTIFY_LEFT
            );
        }
    }
}
