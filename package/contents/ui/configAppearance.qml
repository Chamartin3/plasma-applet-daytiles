import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

Kirigami.FormLayout {
    id: form

    property alias cfg_shape:       shapeCombo.currentText
    property alias cfg_daySize:     sizeSpin.value
    property alias cfg_gap:         gapSpin.value
    property alias cfg_paletteJson: paletteStore.text

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

    TextField {
        id: baseField
        Kirigami.FormData.label: i18n("Base color:")
        placeholderText: "#3a3a3a"
        onTextChanged: form.writePalette()
    }
    TextField {
        id: pastField
        Kirigami.FormData.label: i18n("Past color:")
        placeholderText: "#2a2a2a"
        onTextChanged: form.writePalette()
    }
    TextField {
        id: futureField
        Kirigami.FormData.label: i18n("Future color:")
        placeholderText: "#4a4a4a"
        onTextChanged: form.writePalette()
    }
    TextField {
        id: weekendField
        Kirigami.FormData.label: i18n("Weekend color:")
        placeholderText: i18n("optional")
        onTextChanged: form.writePalette()
    }

    function writePalette() {
        const obj = {};
        if (baseField.text)    obj.base    = baseField.text;
        if (pastField.text)    obj.past    = pastField.text;
        if (futureField.text)  obj.future  = futureField.text;
        if (weekendField.text) obj.weekend = weekendField.text;
        paletteStore.text = JSON.stringify(obj);
    }

    Component.onCompleted: {
        try {
            const p = JSON.parse(paletteStore.text || "{}");
            baseField.text    = p.base    || "";
            pastField.text    = p.past    || "";
            futureField.text  = p.future  || "";
            weekendField.text = p.weekend || "";
        } catch (e) {}
    }
}
