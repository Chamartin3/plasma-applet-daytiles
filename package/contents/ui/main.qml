import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import "defaults.js" as Defaults
import "panels"

PlasmoidItem {
    id: root

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    function parsedEvents() {
        try { return JSON.parse(Plasmoid.configuration.eventsJson || "[]"); }
        catch (e) { return []; }
    }

    function parsedPalette() {
        try { return JSON.parse(Plasmoid.configuration.paletteJson || "{}"); }
        catch (e) { return {}; }
    }

    function parsedTypeColors() {
        try { return JSON.parse(Plasmoid.configuration.eventTypeColorsJson || "{}"); }
        catch (e) { return {}; }
    }

    function parsedHighlights() {
        try {
            const arr = JSON.parse(Plasmoid.configuration.highlightsJson || "[]");
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

    function buildConfig() {
        const c = Plasmoid.configuration;
        const dflt = Defaults.defaultRange();
        const palette = parsedPalette();
        const altMode = (c.alternationMode || Defaults.Alternation.mode).toLowerCase();

        const colors = {
            current:           palette.current || Defaults.Colors.current,
            dayColor:          palette.base    || Defaults.Colors.day,
            defaultEventColor: palette.event   || Defaults.Colors.event,
            highlightCurrent:  c.highlightCurrent !== false,
            eventTypeColors:   parsedTypeColors(),
            highlight: root.buildHighlight(),
            alternation: {
                mode:  altMode,
                color: palette.alternation || Defaults.Colors.alternation,
                size:  c.alternationSize || Defaults.Alternation.size,
            },
        };
        colors.pastFade   = (typeof c.pastFade   === "number") ? c.pastFade   : Defaults.Fade.past;
        colors.futureFade = (typeof c.futureFade === "number") ? c.futureFade : Defaults.Fade.future;
        if (c.heatmap === true) {
            colors.heatmap = true;
            if (typeof c.heatmapLow === "number")  colors.heatmapLow  = c.heatmapLow;
            if (typeof c.heatmapHigh === "number") colors.heatmapHigh = c.heatmapHigh;
        }

        return {
            layout:         (c.layout || Defaults.Layout.mode).toLowerCase(),
            shape:          Defaults.shapeToken(c.shape),
            startDate:      c.startDate || dflt.start,
            endDate:        c.endDate   || dflt.end,
            year:           null,
            daySize:        c.daySize || Defaults.Layout.daySize,
            gap:            (c.gap != null) ? c.gap : Defaults.Layout.gap,
            startDayOfWeek: (c.startDayOfWeek != null) ? c.startDayOfWeek : Defaults.Layout.startDayOfWeek,
            daysPerRow:     c.daysPerRow || Defaults.Layout.daysPerRow,
            showLabels:     c.showLabels === true,
            labelWidth:     Defaults.Layout.labelWidth,
            labelFontSize:   c.labelFontSize || 0,
            labelFontFamily: c.labelFontFamily || "",
            labelColor:      c.labelColor || "",
            events:         {},
            colors:         colors,
        };
    }

    function appendEvent(entry) {
        const arr = parsedEvents();
        arr.push(entry);
        Plasmoid.configuration.eventsJson = JSON.stringify(arr);
    }

    function removeEvent(entry) {
        if (!entry) return;
        const arr = parsedEvents().filter(function(e) {
            return !(e.start === entry.start
                  && (e.end || "") === (entry.end || "")
                  && (e.note || "") === (entry.note || "")
                  && (e.color || "") === (entry.color || ""));
        });
        Plasmoid.configuration.eventsJson = JSON.stringify(arr);
    }

    compactRepresentation: CompactRepresentation {
        onClicked: root.expanded = !root.expanded
    }

    fullRepresentation: ColumnLayout {
        Layout.minimumWidth: 120
        Layout.minimumHeight: 80
        Layout.preferredWidth: 820
        Layout.preferredHeight: 600
        spacing: 4

        Label {
            Layout.fillWidth: true
            text: Plasmoid.configuration.title || ""
            visible: text.length > 0
            font.pixelSize: Plasmoid.configuration.titleFontSize || 18
            font.family: Plasmoid.configuration.titleFontFamily || font.family
            font.bold: true
            color: Plasmoid.configuration.titleColor || Kirigami.Theme.textColor
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }

        DaytilesView {
            id: view
            Layout.fillWidth: true
            Layout.fillHeight: true
            dateFormat: Plasmoid.configuration.dateFormat || Defaults.Layout.dateFormat

            config: {
                Plasmoid.configuration.layout;
                Plasmoid.configuration.shape;
                Plasmoid.configuration.startDate;
                Plasmoid.configuration.endDate;
                Plasmoid.configuration.daySize;
                Plasmoid.configuration.gap;
                Plasmoid.configuration.daysPerRow;
                Plasmoid.configuration.startDayOfWeek;
                Plasmoid.configuration.showLabels;
                Plasmoid.configuration.labelFontSize;
                Plasmoid.configuration.labelFontFamily;
                Plasmoid.configuration.labelColor;
                Plasmoid.configuration.pastFade;
                Plasmoid.configuration.futureFade;
                Plasmoid.configuration.highlightCurrent;
                Plasmoid.configuration.heatmap;
                Plasmoid.configuration.heatmapLow;
                Plasmoid.configuration.heatmapHigh;
                Plasmoid.configuration.alternationMode;
                Plasmoid.configuration.alternationSize;
                Plasmoid.configuration.paletteJson;
                Plasmoid.configuration.highlightsJson;
                Plasmoid.configuration.eventTypeColorsJson;
                return root.buildConfig();
            }
            events: {
                Plasmoid.configuration.eventsJson;
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
