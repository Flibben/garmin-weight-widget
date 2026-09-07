import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class WeightTrackerMenuDelegate extends WatchUi.Menu2InputDelegate {

    private var _view as WeightTrackerView;

    public function initialize(view as WeightTrackerView) {
        Menu2InputDelegate.initialize();
        _view = view;
    }

    public function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId() as String;

        if (id.equals("menu_glance_range")) {
            pushGlanceRangeMenu();
        } else if (id.equals("menu_graph_range")) {
            pushGraphRangeMenu();
        } else {
            handleDebugActions(id);
        }
    }

    (:debug)
    private function handleDebugActions(id as String) as Void {
        if (id.equals("menu_demo_data")) {
            WeightHistoryManager.generateDemoData();
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            WatchUi.requestUpdate();
        } else if (id.equals("menu_clear_history")) {
            WeightHistoryManager.clearHistory();
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            WatchUi.requestUpdate();
        }
    }

    (:release)
    private function handleDebugActions(id as String) as Void {
        // No-op for release builds
    }

    public function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }

    //! Push sub-menu for choosing Glance Delta Range
    private function pushGlanceRangeMenu() as Void {
        var menu = new WatchUi.Menu2({:title => "Glance Range"});
        var currentIdx = WeightHistoryManager.getGlancePeriodIndex();
        var labels = ["1 Day", "1 Week", "1 Month", "3 Months", "6 Months", "1 Year"];

        for (var i = 0; i < labels.size(); i++) {
            var subLabel = (i == currentIdx) ? "Active" : null;
            menu.addItem(new WatchUi.MenuItem(labels[i], subLabel, "glance_" + i, null));
        }

        WatchUi.pushView(menu, new GlanceRangeMenuDelegate(), WatchUi.SLIDE_LEFT);
    }

    //! Push sub-menu for choosing Graph Range
    private function pushGraphRangeMenu() as Void {
        var menu = new WatchUi.Menu2({:title => "Graph Range"});
        var currentIdx = _view.getPeriodIndex();
        var labels = ["1 Week", "1 Month", "3 Months", "6 Months", "1 Year"];

        for (var i = 0; i < labels.size(); i++) {
            var subLabel = (i == currentIdx) ? "Active" : null;
            menu.addItem(new WatchUi.MenuItem(labels[i], subLabel, "graph_" + i, null));
        }

        WatchUi.pushView(menu, new GraphRangeMenuDelegate(_view), WatchUi.SLIDE_LEFT);
    }
}

class GlanceRangeMenuDelegate extends WatchUi.Menu2InputDelegate {

    public function initialize() {
        Menu2InputDelegate.initialize();
    }

    public function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId() as String;
        if (id.find("glance_") == 0) {
            var idxStr = id.substring(7, id.length());
            var idx = idxStr.toNumber();
            if (idx != null) {
                WeightHistoryManager.setGlancePeriodIndex(idx);
            }
        }
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }

    public function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}

class GraphRangeMenuDelegate extends WatchUi.Menu2InputDelegate {

    private var _view as WeightTrackerView;

    public function initialize(view as WeightTrackerView) {
        Menu2InputDelegate.initialize();
        _view = view;
    }

    public function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId() as String;
        if (id.find("graph_") == 0) {
            var idxStr = id.substring(6, id.length());
            var idx = idxStr.toNumber();
            if (idx != null) {
                _view.setPeriodIndex(idx);
            }
        }
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }

    public function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}
