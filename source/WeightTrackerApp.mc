import Toybox.Application;
import Toybox.Background;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

(:background)
class WeightTrackerApp extends Application.AppBase {

    public function initialize() {
        AppBase.initialize();
    }

    public function onStart(state as Dictionary?) as Void {
        // Record current weight upon app start
        WeightHistoryManager.recordCurrentWeight();

        // Ensure 23:30 temporal event is registered
        try {
            var nextMoment = WeightHistoryManager.getNextScheduledMoment();
            Background.registerForTemporalEvent(nextMoment);
        } catch (e) {
        }
    }

    public function onStop(state as Dictionary?) as Void {
        // Ensure background event is scheduled before shutdown
        try {
            var nextMoment = WeightHistoryManager.getNextScheduledMoment();
            Background.registerForTemporalEvent(nextMoment);
        } catch (e) {
        }
    }

    (:glance)
    public function getGlanceView() {
        return [ new WeightTrackerGlanceView() ];
    }

    public function getInitialView() as [WatchUi.Views] or [WatchUi.Views, WatchUi.InputDelegates] {
        var view = new WeightTrackerView();
        return [ view, new WeightTrackerDelegate(view) ];
    }

    public function getServiceDelegate() as [System.ServiceDelegate] {
        return [ new WeightTrackerServiceDelegate() ];
    }

    public function onSettingsChanged() as Void {
        WatchUi.requestUpdate();
    }

    public function onBackgroundData(data as Application.PersistableType) as Void {
        WatchUi.requestUpdate();
    }
}

function getApp() as WeightTrackerApp {
    return Application.getApp() as WeightTrackerApp;
}
