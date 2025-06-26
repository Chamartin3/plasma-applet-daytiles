import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

Kirigami.FormLayout {
    id: form

    property alias cfg_layout:    layoutCombo.currentText
    property alias cfg_startDate: startField.text
    property alias cfg_endDate:   endField.text

    ComboBox {
        id: layoutCombo
        Kirigami.FormData.label: i18n("Layout:")
        model: ["Month", "Week", "Weekday", "Custom"]
    }

    TextField {
        id: startField
        Kirigami.FormData.label: i18n("Start date (YYYY-MM-DD):")
        placeholderText: "2025-01-01"
    }

    TextField {
        id: endField
        Kirigami.FormData.label: i18n("End date (YYYY-MM-DD):")
        placeholderText: "2025-12-31"
    }
}
