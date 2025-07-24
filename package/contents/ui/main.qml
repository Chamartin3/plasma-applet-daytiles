import QtQuick 2.15
import QtQuick.Controls 2.15
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

    function appendEvent(entry) {
        const arr = parsedEvents();
        arr.push(entry);
        plasmoid.configuration.eventsJson = JSON.stringify(arr);
    }

    Plasmoid.compactRepresentation: CompactRepresentation {}

    Plasmoid.fullRepresentation: ColumnLayout {
        Layout.minimumWidth: 320
        Layout.minimumHeight: 240
        Layout.preferredWidth: 480
        Layout.preferredHeight: 360
        spacing: 0

        DaytilesView {
            id: view
            Layout.fillWidth: true
            Layout.fillHeight: true

            config: root.buildConfig()
            events: root.parsedEvents()

            onTileClicked: function(info) {
                const date = info && info.date ? info.date : "";
                const matching = root.parsedEvents().filter(function(e) {
                    return e.start === date || (e.end && e.start <= date && date <= e.end);
                });
                if (matching.length) {
                    dayList.open(date, matching);
                } else {
                    quick.presetDate = date;
                    quick.open(date);
                }
            }

            Connections {
                target: plasmoid.configuration
                function onLayoutChanged()      { view.config = root.buildConfig(); view.apply(); }
                function onShapeChanged()       { view.config = root.buildConfig(); view.apply(); }
                function onStartDateChanged()   { view.config = root.buildConfig(); view.apply(); }
                function onEndDateChanged()    { view.config = root.buildConfig(); view.apply(); }
                function onDaySizeChanged()     { view.config = root.buildConfig(); view.apply(); }
                function onGapChanged()         { view.config = root.buildConfig(); view.apply(); }
                function onPaletteJsonChanged() { view.config = root.buildConfig(); view.apply(); }
                function onEventsJsonChanged()  { view.events = root.parsedEvents(); view.apply(); }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Button {
                text: qsTr("Add event")
                icon.name: "list-add"
                onClicked: quick.open("")
            }
            Item { Layout.fillWidth: true }
            Label {
                text: qsTr("%1 events").arg(root.parsedEvents().length)
                opacity: 0.7
            }
        }

        EventListPanel {
            id: dayList
            Layout.fillWidth: true
            onAddRequested: function(date) { quick.open(date); }
        }

        QuickAdd {
            id: quick
            Layout.fillWidth: true
            onSaved: function(entry) { root.appendEvent(entry); }
        }
    }
}
