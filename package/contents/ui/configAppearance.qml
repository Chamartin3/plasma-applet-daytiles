import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

Kirigami.FormLayout {
    id: form

    property alias cfg_shape:            shapeCombo.currentText
    property alias cfg_daySize:          sizeSpin.value
    property alias cfg_gap:              gapSpin.value
    property alias cfg_paletteJson:      paletteStore.text
    property alias cfg_highlightCurrent: highlightTodayCheck.checked
    property alias cfg_heatmap:          heatmapCheck.checked
    property double cfg_pastFade:   1.0
    property double cfg_futureFade: 1.0

    ComboBox {
        id: shapeCombo
        Kirigami.FormData.label: i18n("Tile shape:")
        model: ["Rectangle", "RoundedRect", "Circle", "Diamond"]
    }

    SpinBox {
        id: sizeSpin
        Kirigami.FormData.label: i18n("Tile size (px):")
        from: 4; to: 64; stepSize: 1
        value: 16
    }

    SpinBox {
        id: gapSpin
        Kirigami.FormData.label: i18n("Gap (px):")
        from: 0; to: 16; stepSize: 1
        value: 2
    }

    TextField { id: paletteStore; visible: false }

    ColorField {
        id: baseField
        Kirigami.FormData.label: i18n("Day color:")
        placeholderText: "#3a3a3a"
        onTextChanged: form.writePalette()
    }
    ColorField {
        id: currentField
        Kirigami.FormData.label: i18n("Today color:")
        placeholderText: "#FFD700"
        onTextChanged: form.writePalette()
    }
    ColorField {
        id: eventField
        Kirigami.FormData.label: i18n("Default event color:")
        placeholderText: "#ff5577"
        onTextChanged: form.writePalette()
    }
    ColorField {
        id: weekendField
        Kirigami.FormData.label: i18n("Weekend color:")
        placeholderText: i18n("optional")
        onTextChanged: form.writePalette()
    }
    ColorField {
        id: alternationField
        Kirigami.FormData.label: i18n("Alternation color:")
        placeholderText: i18n("optional")
        onTextChanged: form.writePalette()
    }

    CheckBox {
        id: highlightTodayCheck
        Kirigami.FormData.label: i18n("Today:")
        text: i18n("Highlight today's tile")
        checked: true
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Past fade:")
        Slider {
            id: pastFadeSlider
            from: 0.2; to: 1.0; stepSize: 0.05
            value: form.cfg_pastFade
            onValueChanged: form.cfg_pastFade = value
            Layout.preferredWidth: 160
        }
        Label { text: pastFadeSlider.value.toFixed(2) }
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Future fade:")
        Slider {
            id: futureFadeSlider
            from: 0.2; to: 1.0; stepSize: 0.05
            value: form.cfg_futureFade
            onValueChanged: form.cfg_futureFade = value
            Layout.preferredWidth: 160
        }
        Label { text: futureFadeSlider.value.toFixed(2) }
    }

    CheckBox {
        id: heatmapCheck
        Kirigami.FormData.label: i18n("Heatmap mode:")
        text: i18n("Tint tiles by event count")
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
    }
}
