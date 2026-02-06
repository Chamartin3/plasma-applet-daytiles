import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami
import "../defaults.js" as Defaults
import "../fields"

Kirigami.FormLayout {
    id: form

    property alias cfg_paletteJson:      paletteStore.text
    property alias cfg_highlightsJson:   highlightsStore.text
    property alias cfg_highlightCurrent: highlightTodayCheck.checked
    property alias cfg_heatmap:          heatmapCheck.checked
    property alias cfg_pastFade:         pastFadeSlider.value
    property alias cfg_futureFade:       futureFadeSlider.value
    property alias cfg_heatmapLow:       heatmapLowSlider.value
    property alias cfg_heatmapHigh:      heatmapHighSlider.value
    property alias cfg_alternationMode:  altModeHolder.text
    property alias cfg_alternationSize:  altSizeSpin.value

    TextField { id: paletteStore;    visible: false }
    TextField { id: highlightsStore; visible: false }
    TextField { id: altModeHolder;   visible: false }

    Item { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Colors") }

    ColorField {
        id: baseField
        Kirigami.FormData.label: i18n("Day:")
        placeholderText: Defaults.Colors.day
        onTextChanged: form.writePalette()
    }
    ColorField {
        id: currentField
        Kirigami.FormData.label: i18n("Today:")
        placeholderText: Defaults.Colors.current
        onTextChanged: form.writePalette()
    }
    ColorField {
        id: eventField
        Kirigami.FormData.label: i18n("Default event:")
        placeholderText: Defaults.Colors.event
        onTextChanged: form.writePalette()
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Past fade:")
        Slider {
            id: pastFadeSlider
            from: 0.2; to: 1.0; stepSize: 0.05
            value: 1.0
            Layout.preferredWidth: 160
        }
        Label { text: pastFadeSlider.value.toFixed(2) }
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Future fade:")
        Slider {
            id: futureFadeSlider
            from: 0.2; to: 1.0; stepSize: 0.05
            value: 1.0
            Layout.preferredWidth: 160
        }
        Label { text: futureFadeSlider.value.toFixed(2) }
    }

    CheckBox {
        id: highlightTodayCheck
        Kirigami.FormData.label: i18n("Today:")
        text: i18n("Highlight today's tile")
        checked: true
    }

    Item { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Highlights") }

    ComboBox {
        id: altModeCombo
        Kirigami.FormData.label: i18n("Alternation mode:")
        textRole: "label"
        valueRole: "value"
        model: [
            { label: i18n("None"),       value: "none"   },
            { label: i18n("Per day"),    value: "day"    },
            { label: i18n("Per week"),   value: "week"   },
            { label: i18n("Per month"),  value: "month"  },
            { label: i18n("Per year"),   value: "year"   },
            { label: i18n("Custom"),     value: "custom" },
        ]
        onActivated: altModeHolder.text = model[currentIndex].value
    }

    SpinBox {
        id: altSizeSpin
        Kirigami.FormData.label: i18n("Alternation size:")
        from: 1; to: 365; stepSize: 1
        enabled: altModeHolder.text === "custom"
    }

    ColorField {
        id: alternationField
        Kirigami.FormData.label: i18n("Alternation color:")
        placeholderText: i18n("optional")
        onTextChanged: form.writePalette()
    }

    ListModel { id: highlights }

    readonly property var kindOptions: [
        { label: i18n("Weekday"), value: "weekday" },
        { label: i18n("Month"),   value: "month"   },
    ]
    readonly property var weekdayOptions: [
        { label: i18n("Sunday"),    value: 0 },
        { label: i18n("Monday"),    value: 1 },
        { label: i18n("Tuesday"),   value: 2 },
        { label: i18n("Wednesday"), value: 3 },
        { label: i18n("Thursday"),  value: 4 },
        { label: i18n("Friday"),    value: 5 },
        { label: i18n("Saturday"),  value: 6 },
    ]
    readonly property var monthOptions: [
        { label: i18n("January"),   value: 1  },
        { label: i18n("February"),  value: 2  },
        { label: i18n("March"),     value: 3  },
        { label: i18n("April"),     value: 4  },
        { label: i18n("May"),       value: 5  },
        { label: i18n("June"),      value: 6  },
        { label: i18n("July"),      value: 7  },
        { label: i18n("August"),    value: 8  },
        { label: i18n("September"), value: 9  },
        { label: i18n("October"),   value: 10 },
        { label: i18n("November"),  value: 11 },
        { label: i18n("December"),  value: 12 },
    ]

    function _labelFor(opts, val) {
        for (let i = 0; i < opts.length; ++i) if (opts[i].value === val) return opts[i].label;
        return "";
    }

    ColumnLayout {
        Kirigami.FormData.label: i18n("Highlight rules:")
        Layout.preferredWidth: 380
        spacing: 4

        Repeater {
            model: highlights
            delegate: RowLayout {
                id: row
                property int rowIndex: index
                property string rowKind: kind
                property int rowValue: value
                property string rowColor: color
                Layout.fillWidth: true
                spacing: 6

                ComboBox {
                    Layout.preferredWidth: 110
                    model: form.kindOptions.map(function(o) { return o.label; })
                    currentIndex: row.rowKind === "month" ? 1 : 0
                    onActivated: {
                        const k = form.kindOptions[currentIndex].value;
                        highlights.setProperty(row.rowIndex, "kind", k);
                        highlights.setProperty(row.rowIndex, "value", k === "weekday" ? 0 : 1);
                        form.writeHighlights();
                    }
                }
                ComboBox {
                    Layout.fillWidth: true
                    property var opts: row.rowKind === "month" ? form.monthOptions : form.weekdayOptions
                    model: opts.map(function(o) { return o.label; })
                    currentIndex: {
                        for (let i = 0; i < opts.length; ++i) if (opts[i].value === row.rowValue) return i;
                        return 0;
                    }
                    onActivated: {
                        highlights.setProperty(row.rowIndex, "value", opts[currentIndex].value);
                        form.writeHighlights();
                    }
                }
                ColorField {
                    Layout.preferredWidth: 110
                    text: row.rowColor
                    onTextChanged: if (text !== row.rowColor) { highlights.setProperty(row.rowIndex, "color", text); form.writeHighlights(); }
                }
                Button {
                    flat: true
                    icon.name: "edit-delete"
                    onClicked: { highlights.remove(row.rowIndex); form.writeHighlights(); }
                }
            }
        }

        Button {
            text: i18n("Add highlight")
            icon.name: "list-add"
            onClicked: { highlights.append({ kind: "weekday", value: 0, color: Defaults.Colors.weekend }); form.writeHighlights(); }
        }
    }

    Item { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Heatmap") }

    CheckBox {
        id: heatmapCheck
        Kirigami.FormData.label: i18n("Heatmap mode:")
        text: i18n("Tint tiles by event count")
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Low fade:")
        enabled: heatmapCheck.checked
        Slider {
            id: heatmapLowSlider
            from: 0.0; to: 1.0; stepSize: 0.05
            value: 0.2
            Layout.preferredWidth: 160
        }
        Label { text: heatmapLowSlider.value.toFixed(2) }
    }

    RowLayout {
        Kirigami.FormData.label: i18n("High fade:")
        enabled: heatmapCheck.checked
        Slider {
            id: heatmapHighSlider
            from: 0.0; to: 1.0; stepSize: 0.05
            value: 0.35
            Layout.preferredWidth: 160
        }
        Label { text: heatmapHighSlider.value.toFixed(2) }
    }

    function writePalette() {
        const obj = {};
        if (baseField.text)        obj.base        = baseField.text;
        if (currentField.text)     obj.current     = currentField.text;
        if (eventField.text)       obj.event       = eventField.text;
        if (alternationField.text) obj.alternation = alternationField.text;
        paletteStore.text = JSON.stringify(obj);
    }

    function writeHighlights() {
        const arr = [];
        for (let i = 0; i < highlights.count; ++i) {
            const h = highlights.get(i);
            if (!h.color) continue;
            arr.push({ kind: h.kind, value: h.value, color: h.color });
        }
        highlightsStore.text = JSON.stringify(arr);
    }

    Component.onCompleted: {
        try {
            const p = JSON.parse(paletteStore.text || "{}");
            baseField.text        = p.base        || "";
            currentField.text     = p.current     || "";
            eventField.text       = p.event       || "";
            alternationField.text = p.alternation || "";
        } catch (e) {}
        try {
            const hl = JSON.parse(highlightsStore.text || "[]");
            if (Array.isArray(hl)) for (const h of hl) {
                if (!h || !h.kind) continue;
                highlights.append({ kind: h.kind, value: h.value || 0, color: h.color || "" });
            }
        } catch (e) {}
        for (let i = 0; i < altModeCombo.model.length; ++i) {
            if (altModeCombo.model[i].value === altModeHolder.text) { altModeCombo.currentIndex = i; break; }
        }
        if (!altModeHolder.text && altModeCombo.model.length > 0) {
            altModeHolder.text = altModeCombo.model[altModeCombo.currentIndex].value;
        }
    }
}
