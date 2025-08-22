import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

Kirigami.FormLayout {
    id: form

    property alias cfg_title:          titleField.text
    property alias cfg_layout:         layoutCombo.currentText
    property alias cfg_startDate:      startField.text
    property alias cfg_endDate:        endField.text
    property alias cfg_daysPerRow:     daysPerRowSpin.value
    property alias cfg_startDayOfWeek: startDowCombo.currentIndex
    property alias cfg_showLabels:     showLabelsCheck.checked
    property alias cfg_dateFormat:     dateFormatField.text
    property alias cfg_shape:          shapeCombo.currentText
    property alias cfg_daySize:        sizeSpin.value
    property alias cfg_gap:            gapSpin.value

    TextField {
        id: titleField
        Kirigami.FormData.label: i18n("Title:")
        placeholderText: i18n("optional")
    }

    Item { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Layout") }

    ComboBox {
        id: layoutCombo
        Kirigami.FormData.label: i18n("Mode:")
        model: ["Month", "Week", "Weekday", "Custom"]
    }

    SpinBox {
        id: daysPerRowSpin
        Kirigami.FormData.label: i18n("Days per row (Custom):")
        from: 1; to: 60; stepSize: 1
        value: 21
    }

    ComboBox {
        id: startDowCombo
        Kirigami.FormData.label: i18n("Week starts on:")
        model: [i18n("Sunday"), i18n("Monday"), i18n("Tuesday"), i18n("Wednesday"),
                i18n("Thursday"), i18n("Friday"), i18n("Saturday")]
        currentIndex: 1
    }

    CheckBox {
        id: showLabelsCheck
        Kirigami.FormData.label: i18n("Row labels:")
        text: i18n("Show month/week names")
    }

    TextField {
        id: dateFormatField
        Kirigami.FormData.label: i18n("Tooltip date format:")
        placeholderText: "yyyy-MM-dd"
        text: "yyyy-MM-dd"
        ToolTip.visible: hovered
        ToolTip.delay: 400
        ToolTip.text: i18n("Qt format tokens: yyyy yy MM M dd d ddd dddd MMM MMMM")
    }

    Item { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Tiles") }

    ComboBox {
        id: shapeCombo
        Kirigami.FormData.label: i18n("Shape:")
        model: ["Rectangle", "RoundedRect", "Circle", "Diamond"]
    }

    SpinBox {
        id: sizeSpin
        Kirigami.FormData.label: i18n("Day size (px):")
        from: 4; to: 64; stepSize: 1
        value: 16
    }

    SpinBox {
        id: gapSpin
        Kirigami.FormData.label: i18n("Gap (px):")
        from: 0; to: 20; stepSize: 1
        value: 2
    }

    Item { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Range") }

    DateField {
        id: startField
        Kirigami.FormData.label: i18n("Start date:")
        placeholderText: "2025-01-01"
    }

    DateField {
        id: endField
        Kirigami.FormData.label: i18n("End date:")
        placeholderText: "2025-12-31"
    }
}
