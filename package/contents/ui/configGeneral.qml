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

    TextField {
        id: titleField
        Kirigami.FormData.label: i18n("Title:")
        placeholderText: i18n("optional")
    }

    ComboBox {
        id: layoutCombo
        Kirigami.FormData.label: i18n("Layout:")
        model: ["Month", "Week", "Weekday", "Custom"]
    }

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

    SpinBox {
        id: daysPerRowSpin
        Kirigami.FormData.label: i18n("Days per row (Custom):")
        from: 1; to: 53; stepSize: 1
        value: 21
    }

    ComboBox {
        id: startDowCombo
        Kirigami.FormData.label: i18n("Week starts on:")
        model: [i18n("Sunday"), i18n("Monday")]
        currentIndex: 1
    }

    CheckBox {
        id: showLabelsCheck
        Kirigami.FormData.label: i18n("Row labels:")
        text: i18n("Show month/week names")
    }
}
