import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

Kirigami.FormLayout {
    id: form

    property alias cfg_paletteJson:      paletteStore.text
    property alias cfg_highlightCurrent: highlightTodayCheck.checked
    property alias cfg_heatmap:          heatmapCheck.checked
    property alias cfg_pastFade:         pastFadeSlider.value
    property alias cfg_futureFade:       futureFadeSlider.value
    property alias cfg_heatmapLow:       heatmapLowSlider.value
    property alias cfg_heatmapHigh:      heatmapHighSlider.value
    property alias cfg_alternationMode:  altModeCombo.currentValue
    property alias cfg_alternationSize:  altSizeSpin.value

    TextField { id: paletteStore; visible: false }

    Item { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Colors") }

    ColorField {
        id: baseField
        Kirigami.FormData.label: i18n("Day:")
        placeholderText: "#3a3a3a"
        onTextChanged: form.writePalette()
    }
    ColorField {
        id: currentField
        Kirigami.FormData.label: i18n("Today:")
        placeholderText: "#FFD700"
        onTextChanged: form.writePalette()
    }
    ColorField {
        id: eventField
        Kirigami.FormData.label: i18n("Default event:")
        placeholderText: "#ff5577"
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
        currentIndex: 3
    }

    SpinBox {
        id: altSizeSpin
        Kirigami.FormData.label: i18n("Alternation size:")
        from: 1; to: 365; stepSize: 1
        value: 7
        enabled: altModeCombo.currentValue === "custom"
    }

    ColorField {
        id: alternationField
        Kirigami.FormData.label: i18n("Alternation color:")
        placeholderText: i18n("optional")
        onTextChanged: form.writePalette()
    }

    ColorField {
        id: weekendField
        Kirigami.FormData.label: i18n("Weekend color:")
        placeholderText: i18n("optional")
        onTextChanged: form.writePalette()
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
        if (weekendField.text)     obj.weekend     = weekendField.text;
        if (alternationField.text) obj.alternation = alternationField.text;
        paletteStore.text = JSON.stringify(obj);
    }

    Component.onCompleted: {
        try {
            const p = JSON.parse(paletteStore.text || "{}");
            baseField.text        = p.base        || "";
            currentField.text     = p.current     || "";
            eventField.text       = p.event       || "";
            weekendField.text     = p.weekend     || "";
            alternationField.text = p.alternation || "";
        } catch (e) {}
        for (let i = 0; i < altModeCombo.model.length; ++i) {
            if (altModeCombo.model[i].value === altModeCombo.currentValue) { altModeCombo.currentIndex = i; break; }
        }
    }
}
