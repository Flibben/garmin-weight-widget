import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class WeightTrackerDelegate extends WatchUi.BehaviorDelegate {

    private var _view as WeightTrackerView;

    public function initialize(view as WeightTrackerView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    public function onKey(keyEvent as WatchUi.KeyEvent) as Boolean {
        var key = keyEvent.getKey();

        if (key == WatchUi.KEY_UP) {
            _view.previousPeriod();
            return true;
        } else if (key == WatchUi.KEY_DOWN) {
            _view.nextPeriod();
            return true;
        } else if (key == WatchUi.KEY_ENTER || key == WatchUi.KEY_START) {
            pushSettingsMenu();
            return true;
        }

        return false;
    }

    public function onMenu() as Boolean {
        pushSettingsMenu();
        return true;
    }

    public function onSelect() as Boolean {
        pushSettingsMenu();
        return true;
    }

    public function onSwipe(swipeEvent as WatchUi.SwipeEvent) as Boolean {
        var direction = swipeEvent.getDirection();
        if (direction == WatchUi.SWIPE_LEFT) {
            _view.nextPeriod();
            return true;
        } else if (direction == WatchUi.SWIPE_RIGHT) {
            _view.previousPeriod();
            return true;
        }
        return false;
    }

    public function onTap(clickEvent as WatchUi.ClickEvent) as Boolean {
        var coords = clickEvent.getCoordinates();
        var x = coords[0];
        var y = coords[1];

        var devSettings = System.getDeviceSettings();
        var width = devSettings.screenWidth;
        var height = devSettings.screenHeight;
        var centerX = width / 2;

        // 1. Tapping near the timeframe switcher arrows (y between 10% and 25% of height)
        var tfMinY = (height * 0.10).toNumber();
        var tfMaxY = (height * 0.25).toNumber();
        if (y >= tfMinY && y <= tfMaxY) {
            if (x < centerX - 10) {
                _view.previousPeriod();
                return true;
            } else if (x > centerX + 10) {
                _view.nextPeriod();
                return true;
            }
        }

        // 2. Tapping near the bottom dots (y > 85% of height)
        if (y > (height * 0.85).toNumber()) {
            if (x < centerX) {
                _view.previousPeriod();
            } else {
                _view.nextPeriod();
            }
            return true;
        }

        // 3. Tapping anywhere else on the graph opens settings menu
        pushSettingsMenu();
        return true;
    }

    public function onBack() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }

    private function pushSettingsMenu() as Void {
        var menu = new WatchUi.Menu2({:title => "Weight Settings"});

        var glanceIdx = WeightHistoryManager.getGlancePeriodIndex();
        var glanceLabel = WeightHistoryManager.GLANCE_PERIOD_LABELS[glanceIdx];
        menu.addItem(new WatchUi.MenuItem("Glance Range", glanceLabel, "menu_glance_range", null));

        var graphIdx = _view.getPeriodIndex();
        var graphLabel = WeightHistoryManager.GRAPH_PERIOD_LABELS[graphIdx];
        menu.addItem(new WatchUi.MenuItem("Graph Range", graphLabel, "menu_graph_range", null));

        addDebugMenuItems(menu);

        WatchUi.pushView(menu, new WeightTrackerMenuDelegate(_view), WatchUi.SLIDE_UP);
    }

    (:debug)
    private function addDebugMenuItems(menu as WatchUi.Menu2) as Void {
        menu.addItem(new WatchUi.MenuItem("Generate Demo Data", "Load 90-day test data", "menu_demo_data", null));
        menu.addItem(new WatchUi.MenuItem("Clear History", "Reset to today", "menu_clear_history", null));
    }

    (:release)
    private function addDebugMenuItems(menu as WatchUi.Menu2) as Void {
        // No debug items in production release builds
    }
}
