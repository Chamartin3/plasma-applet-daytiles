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

    function parsedTypeColors() {
        try { return JSON.parse(plasmoid.configuration.eventTypeColorsJson || "{}"); }
        catch (e) { return {}; }
    }

    function parsedHighlights() {
        try {
            const arr = JSON.parse(plasmoid.configuration.highlightsJson || "[]");
            return Array.isArray(arr) ? arr : [];
        } catch (e) { return []; }
    }

    function buildHighlight() {
        const out = { weekdays: {}, months: {} };
        const rules = parsedHighlights();
        for (const r of rules) {
            if (!r || !r.color) continue;
            if (r.kind === "weekday") out.weekdays[r.value] = r.color;
            else if (r.kind === "month") out.months[r.value] = r.color;
        }
        return out;
    }

    function _shapeToken(s) {
        const v = (s || "RoundedRect").toLowerCase();
        if (v === "rectangle")   return "rect";
        if (v === "roundedrect") return "roundedRect";
        return v;
    }

    function buildConfig() {
        const y = new Date().getFullYear();
        const c = plasmoid.configuration;
        const palette = parsedPalette();
        const altMode = (c.alternationMode || "month").toLowerCase();

        const colors = {
            current:           palette.current || "#FFD700",
            dayColor:          palette.base    || "#3a3a3a",
            defaultEventColor: palette.event   || "#ff5577",
            highlightCurrent:  c.highlightCurrent !== false,
            eventTypeColors:   parsedTypeColors(),
            highlight: root.buildHighlight(),
            alternation: {
                mode:  altMode,
                color: palette.alternation || "#d2f0fa",
                size:  c.alternationSize || 7,
            },
        };
        colors.pastFade   = (typeof c.pastFade   === "number") ? c.pastFade   : 1;
        colors.futureFade = (typeof c.futureFade === "number") ? c.futureFade : 1;
        if (c.heatmap === true) {
            colors.heatmap = true;
            if (typeof c.heatmapLow === "number")  colors.heatmapLow  = c.heatmapLow;
            if (typeof c.heatmapHigh === "number") colors.heatmapHigh = c.heatmapHigh;
        }

        return {
            layout:         (c.layout || "Month").toLowerCase(),
            shape:          root._shapeToken(c.shape),
            startDate:      c.startDate || (y + "-01-01"),
            endDate:        c.endDate   || (y + "-12-31"),
            year:           null,
            daySize:        c.daySize || 16,
            gap:            (c.gap != null) ? c.gap : 2,
            startDayOfWeek: (c.startDayOfWeek != null) ? c.startDayOfWeek : 1,
            daysPerRow:     c.daysPerRow || 21,
            showLabels:     c.showLabels === true,
            labelWidth:     56,
            events:         {},
            colors:         colors,
        };
    }

    function appendEvent(entry) {
        const arr = parsedEvents();
        arr.push(entry);
        plasmoid.configuration.eventsJson = JSON.stringify(arr);
    }

    function removeEvent(entry) {
        if (!entry) return;
        const arr = parsedEvents().filter(function(e) {
            return !(e.start === entry.start
                  && (e.end || "") === (entry.end || "")
                  && (e.note || "") === (entry.note || "")
                  && (e.color || "") === (entry.color || ""));
        });
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
            dateFormat: plasmoid.configuration.dateFormat || "yyyy-MM-dd"

            config: {
                plasmoid.configuration.layout;
                plasmoid.configuration.shape;
                plasmoid.configuration.startDate;
                plasmoid.configuration.endDate;
                plasmoid.configuration.daySize;
                plasmoid.configuration.gap;
                plasmoid.configuration.daysPerRow;
                plasmoid.configuration.startDayOfWeek;
                plasmoid.configuration.showLabels;
                plasmoid.configuration.pastFade;
                plasmoid.configuration.futureFade;
                plasmoid.configuration.highlightCurrent;
                plasmoid.configuration.heatmap;
                plasmoid.configuration.heatmapLow;
                plasmoid.configuration.heatmapHigh;
                plasmoid.configuration.alternationMode;
                plasmoid.configuration.alternationSize;
                plasmoid.configuration.paletteJson;
                plasmoid.configuration.highlightsJson;
                plasmoid.configuration.eventTypeColorsJson;
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
            onRemoveRequested: function(entry) {
                root.removeEvent(entry);
                const remaining = root.parsedEvents().filter(function(e) {
                    return e.start === forDate || (e.end && e.start <= forDate && forDate <= e.end);
                });
                if (remaining.length) entries = remaining;
                else visible = false;
            }
        }

        QuickAdd {
            id: quick
            Layout.fillWidth: true
            onSaved: function(entry) { root.appendEvent(entry); }
        }
    }
}
