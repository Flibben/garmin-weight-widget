import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;

class WeightTrackerView extends WatchUi.View {

    private var _graphPeriodIndex as Number = 0;

    public function initialize() {
        View.initialize();
        _graphPeriodIndex = WeightHistoryManager.getGraphPeriodIndex();
    }

    public function onShow() as Void {
        // Refresh latest weight whenever view opens
        WeightHistoryManager.recordCurrentWeight();
        _graphPeriodIndex = WeightHistoryManager.getGraphPeriodIndex();
    }

    //! Switch to next graph timeframe (1W -> 1M -> 3M -> 6M -> 1Y)
    public function nextPeriod() as Void {
        _graphPeriodIndex = (_graphPeriodIndex + 1) % WeightHistoryManager.GRAPH_PERIOD_DAYS.size();
        WeightHistoryManager.setGraphPeriodIndex(_graphPeriodIndex);
        WatchUi.requestUpdate();
    }

    //! Switch to previous graph timeframe
    public function previousPeriod() as Void {
        _graphPeriodIndex = (_graphPeriodIndex - 1 + WeightHistoryManager.GRAPH_PERIOD_DAYS.size()) % WeightHistoryManager.GRAPH_PERIOD_DAYS.size();
        WeightHistoryManager.setGraphPeriodIndex(_graphPeriodIndex);
        WatchUi.requestUpdate();
    }

    public function setPeriodIndex(idx as Number) as Void {
        if (idx >= 0 && idx < WeightHistoryManager.GRAPH_PERIOD_DAYS.size()) {
            _graphPeriodIndex = idx;
            WeightHistoryManager.setGraphPeriodIndex(_graphPeriodIndex);
            WatchUi.requestUpdate();
        }
    }

    public function getPeriodIndex() as Number {
        return _graphPeriodIndex;
    }

    public function onUpdate(dc as Graphics.Dc) as Void {
        if (dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;

        var latestWeight = WeightHistoryManager.getLatestWeight();
        var unit = WeightHistoryManager.getUnitString();
        var periodDays = WeightHistoryManager.GRAPH_PERIOD_DAYS[_graphPeriodIndex];
        var periodLabel = WeightHistoryManager.GRAPH_PERIOD_LABELS[_graphPeriodIndex];

        // -------------------------------------------------------------
        // 1. TOP HEADER: Current Weight & Unit
        // -------------------------------------------------------------
        var weightY = (height * 0.08).toNumber();
        if (latestWeight != null) {
            var weightStr = WeightHistoryManager.formatWeight(latestWeight) + " " + unit;
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                centerX,
                weightY,
                Graphics.FONT_MEDIUM,
                weightStr,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );
        } else {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                centerX,
                weightY,
                Graphics.FONT_MEDIUM,
                "--.- " + unit,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );
        }

        // -------------------------------------------------------------
        // 2. SUB-HEADER: Timeframe Selector & Stats
        // -------------------------------------------------------------
        // A. Interactive Timeframe Indicator with dynamically scaled vector arrows
        var timeframeY = (height * 0.185).toNumber();
        var labelDim = dc.getTextDimensions(periodLabel, Graphics.FONT_TINY);
        var halfLabelW = labelDim[0] / 2;

        // Draw period text centered vertically and horizontally
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            timeframeY,
            Graphics.FONT_TINY,
            periodLabel,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // Vector triangle arrows dynamically scaled to screen resolution
        var arrowW = (width > 300) ? 8 : 6;
        var arrowH = (width > 300) ? 6 : 4;
        var arrowGap = (width > 300) ? 9 : 6;

        var leftTipX = centerX - halfLabelW - arrowGap - arrowW;
        var leftBaseX = centerX - halfLabelW - arrowGap;
        var leftArrow = [
            [leftTipX, timeframeY],
            [leftBaseX, timeframeY - arrowH],
            [leftBaseX, timeframeY + arrowH]
        ];

        var rightTipX = centerX + halfLabelW + arrowGap + arrowW;
        var rightBaseX = centerX + halfLabelW + arrowGap;
        var rightArrow = [
            [rightTipX, timeframeY],
            [rightBaseX, timeframeY - arrowH],
            [rightBaseX, timeframeY + arrowH]
        ];

        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(leftArrow);
        dc.fillPolygon(rightArrow);

        // B. Period Stats (Average & Delta)
        var statsY = (height * 0.27).toNumber();
        var avgWeight = WeightHistoryManager.getAverageForPeriod(periodDays);
        var delta = WeightHistoryManager.getDeltaForPeriod(periodDays);

        var statsText = "";
        if (avgWeight != null) {
            statsText = "Avg " + WeightHistoryManager.formatWeight(avgWeight) + " " + unit;
        }
        if (delta != null) {
            if (statsText.length() > 0) {
                statsText += "  |  Δ " + WeightHistoryManager.formatDelta(delta);
            } else {
                statsText = "Δ " + WeightHistoryManager.formatDelta(delta);
            }
        }

        if (statsText.length() > 0) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                centerX,
                statsY,
                Graphics.FONT_XTINY,
                statsText,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );
        }

        // -------------------------------------------------------------
        // 3. CENTER: Time-Series Line Graph
        // -------------------------------------------------------------
        var graphLeft = (width * 0.12).toNumber();
        var graphRight = (width * 0.88).toNumber();
        var graphTop = (height * 0.32).toNumber();
        var graphBottom = (height * 0.82).toNumber();
        var graphW = graphRight - graphLeft;
        var graphH = graphBottom - graphTop;

        var records = WeightHistoryManager.getRecordsInPeriod(periodDays);

        if (records.size() >= 2) {
            var minMax = WeightHistoryManager.getMinMaxForPeriod(periodDays);
            if (minMax != null) {
                var minW = minMax[0];
                var maxW = minMax[1];

                // Ensure at least 1.0 kg (or 1000 grams) scale span for visual aesthetics
                var span = maxW - minW;
                if (span < 1000.0) {
                    var mid = (maxW + minW) / 2.0;
                    minW = mid - 500.0;
                    maxW = mid + 500.0;
                    span = 1000.0;
                } else {
                    // Add 10% padding top and bottom
                    var pad = span * 0.1;
                    minW -= pad;
                    maxW += pad;
                    span = maxW - minW;
                }

                // A. Background Grid Lines (Top, Mid, Bottom)
                dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
                dc.setPenWidth(1);
                dc.drawLine(graphLeft, graphTop, graphRight, graphTop);
                dc.drawLine(graphLeft, graphBottom, graphRight, graphBottom);

                // B. Min / Max Scale Labels
                dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
                var maxStr = WeightHistoryManager.formatWeight(maxW);
                var minStr = WeightHistoryManager.formatWeight(minW);
                dc.drawText(graphRight - 2, graphTop - 2, Graphics.FONT_XTINY, maxStr, Graphics.TEXT_JUSTIFY_RIGHT);
                dc.drawText(graphRight - 2, graphBottom - 12, Graphics.FONT_XTINY, minStr, Graphics.TEXT_JUSTIFY_RIGHT);

                // C. Average Reference Line (Dashed)
                if (avgWeight != null) {
                    var avgY = graphBottom - (((avgWeight - minW) / span) * graphH).toNumber();
                    if (avgY >= graphTop && avgY <= graphBottom) {
                        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
                        // Draw dashed line
                        var dashStep = (width > 300) ? 8 : 6;
                        for (var x = graphLeft; x < graphRight; x += (dashStep * 2)) {
                            var xEnd = x + dashStep;
                            if (xEnd > graphRight) {
                                xEnd = graphRight;
                            }
                            dc.drawLine(x, avgY, xEnd, avgY);
                        }
                    }
                }

                // D. Plot Data Points and Connecting Vector Lines
                var today = (Time.today().value() / 86400).toNumber();
                var startDay = today - periodDays;

                var lineWidth = (width > 300) ? 4 : 3;
                dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
                dc.setPenWidth(lineWidth);

                var prevX = -1;
                var prevY = -1;

                for (var i = 0; i < records.size(); i++) {
                    var entry = records[i] as Dictionary;
                    var d = entry["d"] as Number;
                    var wVal = (entry["w"] as Numeric).toFloat();

                    // Map X: chronological position along timeframe
                    var xFrac = (d - startDay).toFloat() / periodDays.toFloat();
                    if (xFrac < 0.0) { xFrac = 0.0; }
                    if (xFrac > 1.0) { xFrac = 1.0; }
                    var ptX = graphLeft + (xFrac * graphW).toNumber();

                    // Map Y: inverted coordinate system
                    var yFrac = (wVal - minW) / span;
                    if (yFrac < 0.0) { yFrac = 0.0; }
                    if (yFrac > 1.0) { yFrac = 1.0; }
                    var ptY = graphBottom - (yFrac * graphH).toNumber();

                    if (prevX >= 0) {
                        dc.drawLine(prevX, prevY, ptX, ptY);
                    }

                    prevX = ptX;
                    prevY = ptY;
                }

                // E. Highlight Latest Point
                if (prevX >= 0) {
                    var outerR = (width > 300) ? 6 : 4;
                    var innerR = (width > 300) ? 3 : 2;
                    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                    dc.fillCircle(prevX, prevY, outerR);
                    dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
                    dc.fillCircle(prevX, prevY, innerR);
                }
            }
        } else if (records.size() == 1) {
            // Single data point message
            var msgY = (height * 0.48).toNumber();
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                centerX,
                msgY,
                Graphics.FONT_SMALL,
                "1 Day Recorded",
                Graphics.TEXT_JUSTIFY_CENTER
            );
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                centerX,
                msgY + 25,
                Graphics.FONT_XTINY,
                "Weigh in daily to see graph",
                Graphics.TEXT_JUSTIFY_CENTER
            );
        } else {
            // No data message
            var msgY = (height * 0.48).toNumber();
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                centerX,
                msgY,
                Graphics.FONT_SMALL,
                "No History Yet",
                Graphics.TEXT_JUSTIFY_CENTER
            );
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                centerX,
                msgY + 25,
                Graphics.FONT_XTINY,
                "Sync scale with Garmin",
                Graphics.TEXT_JUSTIFY_CENTER
            );
        }

        // -------------------------------------------------------------
        // 4. BOTTOM INDICATOR: 5-Dot Page Indicator (Zero Bezel Clipping)
        // -------------------------------------------------------------
        var dotY = (height * 0.90).toNumber();
        var dotCount = WeightHistoryManager.GRAPH_PERIOD_DAYS.size();
        var dotSpacing = (width * 0.042).toNumber();
        if (dotSpacing < 8) {
            dotSpacing = 8;
        }
        var startDotX = centerX - ((dotCount - 1) * dotSpacing) / 2;
        var activeR = (width > 300) ? 4 : 3;
        var inactiveR = (width > 300) ? 3 : 2;

        for (var i = 0; i < dotCount; i++) {
            var dotX = startDotX + (i * dotSpacing);
            if (i == _graphPeriodIndex) {
                // Active timeframe dot
                dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(dotX, dotY, activeR);
            } else {
                // Inactive dot
                dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(dotX, dotY, inactiveR);
            }
        }
    }
}
