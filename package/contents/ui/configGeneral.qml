import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami
import "defaults.js" as Defaults

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
        value: Defaults.Layout.daysPerRow
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
        placeholderText: Defaults.Layout.dateFormat
        text: Defaults.Layout.dateFormat
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
        value: Defaults.Layout.daySize
    }

    SpinBox {
        id: gapSpin
        Kirigami.FormData.label: i18n("Gap (px):")
        from: 0; to: 20; stepSize: 1
        value: Defaults.Layout.gap
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

    RowLayout {
        Kirigami.FormData.label: i18n("Presets:")
        spacing: 4
        Button {
            text: i18n("This month")
            onClicked: form.applyPreset("month")
        }
        Button {
            text: i18n("This quarter")
            onClicked: form.applyPreset("quarter")
        }
        Button {
            text: i18n("This year")
            onClicked: form.applyPreset("year")
        }
        Button {
            text: i18n("Last 12 months")
            onClicked: form.applyPreset("rolling12")
        }
    }

    function _pad(n) { return n < 10 ? "0" + n : "" + n; }
    function _iso(d) { return d.getFullYear() + "-" + _pad(d.getMonth() + 1) + "-" + _pad(d.getDate()); }

    function applyPreset(kind) {
        const now = new Date();
        const y = now.getFullYear();
        const m = now.getMonth();
        let s, e;
        if (kind === "month") {
            s = new Date(y, m, 1);
            e = new Date(y, m + 1, 0);
        } else if (kind === "quarter") {
            const qStart = Math.floor(m / 3) * 3;
            s = new Date(y, qStart, 1);
            e = new Date(y, qStart + 3, 0);
        } else if (kind === "year") {
            s = new Date(y, 0, 1);
            e = new Date(y, 11, 31);
        } else if (kind === "rolling12") {
            e = new Date(y, m + 1, 0);
            s = new Date(y - 1, m + 1, 1);
        }
        if (s && e) {
            startField.text = _iso(s);
            endField.text   = _iso(e);
        }
    }
}
