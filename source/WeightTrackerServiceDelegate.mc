import Toybox.Background;
import Toybox.Lang;
import Toybox.System;

(:background)
class WeightTrackerServiceDelegate extends System.ServiceDelegate {

    public function initialize() {
        ServiceDelegate.initialize();
    }

    public function onTemporalEvent() as Void {
        // Record latest scale weight into storage
        WeightHistoryManager.recordCurrentWeight();

        // Schedule next daily check for tomorrow at 23:30
        var nextMoment = WeightHistoryManager.getNextScheduledMoment();
        try {
            Background.registerForTemporalEvent(nextMoment);
        } catch (e) {
        }

        Background.exit(true);
    }
}
