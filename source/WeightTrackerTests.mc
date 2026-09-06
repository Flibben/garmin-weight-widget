import Toybox.Lang;
import Toybox.Test;

(:test)
function testMetricConversion(logger as Test.Logger) as Boolean {
    var grams = 75400.0;
    var kg = grams / 1000.0;
    logger.debug("75400g to kg = " + kg);
    return (kg > 75.39 && kg < 75.41);
}

(:test)
function testImperialConversion(logger as Test.Logger) as Boolean {
    var grams = 75000.0;
    var lbs = grams / 453.59237;
    logger.debug("75000g to lbs = " + lbs);
    return (lbs > 165.3 && lbs < 165.4);
}

(:test)
function testDeltaFormatting(logger as Test.Logger) as Boolean {
    var posDeltaGrams = 400.0;
    var posDeltaKg = posDeltaGrams / 1000.0;
    var posStr = "+" + posDeltaKg.format("%.1f");
    logger.debug("Positive delta string: " + posStr);

    var negDeltaGrams = -600.0;
    var negDeltaKg = negDeltaGrams / 1000.0;
    var negStr = negDeltaKg.format("%.1f");
    logger.debug("Negative delta string: " + negStr);

    return (posStr.equals("+0.4") && negStr.equals("-0.6"));
}

(:test)
function testPeriodsArray(logger as Test.Logger) as Boolean {
    var glancePeriods = WeightHistoryManager.GLANCE_PERIOD_DAYS;
    logger.debug("Glance periods count: " + glancePeriods.size());
    if (glancePeriods.size() != 6) {
        return false;
    }

    var graphPeriods = WeightHistoryManager.GRAPH_PERIOD_DAYS;
    logger.debug("Graph periods count: " + graphPeriods.size());
    return (graphPeriods.size() == 5);
}

(:test)
function testDemoDataBoundedChanges(logger as Test.Logger) as Boolean {
    WeightHistoryManager.generateDemoData();
    var records = WeightHistoryManager.getRecords();

    if (records.size() < 90) {
        logger.error("Expected at least 90 demo records, got " + records.size());
        return false;
    }

    for (var i = 1; i < records.size(); i++) {
        var prev = (records[i - 1]["w"] as Numeric).toFloat();
        var curr = (records[i]["w"] as Numeric).toFloat();
        var diff = (curr - prev).abs();

        // Must never exceed 0.5 kg (500 grams) in a single day
        if (diff > 500.0) {
            logger.error("Day " + i + " has jump of " + diff + "g, exceeding 500g threshold");
            return false;
        }
    }

    logger.debug("All 90 demo days strictly bounded within 0.5 kg daily change limit.");
    return true;
}
