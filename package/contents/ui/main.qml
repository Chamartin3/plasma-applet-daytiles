import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.plasmoid 2.0

Item {
    id: root

    function parsedEvents() {
        try { return JSON.parse(plasmoid.configuration.eventsJson || "[]"); }
        catch (e) { return []; }
    }

    function parsedPalette() {
        try { return JSON.parse(plasmoid.configuration.paletteJson || "{}"); }
        catch (e) { return {}; }
    }

    function buildConfig() {
        return {
            layout:    plasmoid.configuration.layout,
            shape:     plasmoid.configuration.shape,
            startDate: plasmoid.configuration.startDate,
            endDate:   plasmoid.configuration.endDate,
            daySize:   plasmoid.configuration.daySize,
            gap:       plasmoid.configuration.gap,
            palette:   parsedPalette(),
        };
    }

    Plasmoid.compactRepresentation: CompactRepresentation {}

    Plasmoid.fullRepresentation: DaytilesView {
        id: view
        Layout.minimumWidth: 320
        Layout.minimumHeight: 240
        Layout.preferredWidth: 480
        Layout.preferredHeight: 320

        config: root.buildConfig()
        events: root.parsedEvents()

        Connections {
            target: plasmoid.configuration
            function onLayoutChanged()    { view.config = root.buildConfig(); view.apply(); }
            function onShapeChanged()     { view.config = root.buildConfig(); view.apply(); }
            function onStartDateChanged() { view.config = root.buildConfig(); view.apply(); }
            function onEndDateChanged()   { view.config = root.buildConfig(); view.apply(); }
            function onDaySizeChanged()   { view.config = root.buildConfig(); view.apply(); }
            function onGapChanged()       { view.config = root.buildConfig(); view.apply(); }
            function onPaletteJsonChanged(){ view.config = root.buildConfig(); view.apply(); }
            function onEventsJsonChanged(){ view.events = root.parsedEvents(); view.apply(); }
        }
    }
}
