import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

Kirigami.FormLayout {
    id: form

    property alias cfg_shape:   shapeCombo.currentText
    property alias cfg_daySize: sizeSpin.value
    property alias cfg_gap:     gapSpin.value

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
}
