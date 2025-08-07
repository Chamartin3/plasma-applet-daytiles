import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0

Item {
    id: root

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    function parsedEvents() {
        try { return JSON.parse(plasmoid.configuration.eventsJson || "[]"); }
        catch (e) { return []; }
    }

    function parsedPalette() {
        try { return JSON.parse(plasmoid.configuration.paletteJson || "{}"); }
        catch (e) { return {}; }
    }

    function buildConfig() {
        const y = new Date().getFullYear();
        const start = plasmoid.configuration.startDate || (y + "-01-01");
        const end   = plasmoid.configuration.endDate   || (y + "-12-31");
        return {
            layout:    plasmoid.configuration.layout || "Month",
            shape:     plasmoid.configuration.shape  || "RoundedRect",
            startDate: start,
            endDate:   end,
            daySize:   plasmoid.configuration.daySize || 16,
            gap:       plasmoid.configuration.gap || 2,
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
        Layout.minimumWidth: 480
        Layout.minimumHeight: 320
        Layout.preferredWidth: 820
        Layout.preferredHeight: 600
        spacing: 4

        Label {
            Layout.fillWidth: true
            text: plasmoid.configuration.title || ""
            visible: text.length > 0
            font.pixelSize: 18
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }

        DaytilesView {
            id: view
            Layout.fillWidth: true
            Layout.fillHeight: true

            config: {
                plasmoid.configuration.layout;
                plasmoid.configuration.shape;
                plasmoid.configuration.startDate;
                plasmoid.configuration.endDate;
                plasmoid.configuration.daySize;
                plasmoid.configuration.gap;
                plasmoid.configuration.paletteJson;
                return root.buildConfig();
            }
            events: {
                plasmoid.configuration.eventsJson;
                return root.parsedEvents();
            }

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
        }

        RowLayout {
            Layout.fillWidth: true
            Label {
                text: qsTr("Click a tile to add an event")
                opacity: 0.6
            }
            Item { Layout.fillWidth: true }
            Button {
                text: qsTr("Configure")
                icon.name: "configure"
                onClicked: plasmoid.action("configure").trigger()
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
