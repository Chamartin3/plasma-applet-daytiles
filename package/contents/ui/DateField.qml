import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

RowLayout {
    id: root

    property alias text: field.text
    property alias placeholderText: field.placeholderText
    property bool invalid: false

    spacing: 4

    function _pad(n) { return n < 10 ? "0" + n : "" + n; }
    function _format(d) {
        return d.getFullYear() + "-" + _pad(d.getMonth() + 1) + "-" + _pad(d.getDate());
    }
    function _parseOrToday(s) {
        const m = /^(\d{4})-(\d{2})-(\d{2})$/.exec(s || "");
        if (!m) return new Date();
        return new Date(parseInt(m[1]), parseInt(m[2]) - 1, parseInt(m[3]));
    }
    function _daysInMonth(y, m) { return new Date(y, m + 1, 0).getDate(); }

    TextField {
        id: field
        Layout.fillWidth: true
        placeholderText: "YYYY-MM-DD"
        validator: RegExpValidator { regExp: /^(\d{4}-\d{2}-\d{2})?$/ }
        color: root.invalid ? "#d04040" : palette.text
        ToolTip.visible: root.invalid && hovered
        ToolTip.delay: 200
        ToolTip.text: qsTr("End date must be on or after start date")
    }

    Button {
        icon.name: "view-calendar"
        flat: true
        onClicked: {
            const d = root._parseOrToday(field.text);
            picker.curMonth = d.getMonth();
            picker.curYear = d.getFullYear();
            popup.open();
        }
    }

    Popup {
        id: popup
        parent: Overlay.overlay
        modal: true
        focus: true
        padding: 8
        x: {
            if (!Overlay.overlay) return 0;
            const p = root.mapToItem(Overlay.overlay, root.width, root.height);
            return Math.max(4, Math.min(p.x - width, Overlay.overlay.width - width - 4));
        }
        y: {
            if (!Overlay.overlay) return 0;
            const p = root.mapToItem(Overlay.overlay, 0, root.height);
            return Math.max(4, Math.min(p.y, Overlay.overlay.height - height - 4));
        }

        ColumnLayout {
            id: picker
            spacing: 6

            property int curMonth: new Date().getMonth()
            property int curYear: new Date().getFullYear()

            function offset() {
                // Monday = 0
                const first = new Date(curYear, curMonth, 1).getDay();
                return (first + 6) % 7;
            }

            RowLayout {
                Layout.fillWidth: true
                Button {
                    text: "<"
                    flat: true
                    onClicked: {
                        if (picker.curMonth === 0) { picker.curMonth = 11; picker.curYear -= 1; }
                        else { picker.curMonth -= 1; }
                    }
                }
                Label {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: Qt.locale().monthName(picker.curMonth) + " " + picker.curYear
                }
                Button {
                    text: ">"
                    flat: true
                    onClicked: {
                        if (picker.curMonth === 11) { picker.curMonth = 0; picker.curYear += 1; }
                        else { picker.curMonth += 1; }
                    }
                }
            }

            GridLayout {
                columns: 7
                columnSpacing: 2
                rowSpacing: 2

                Repeater {
                    model: ["Mo","Tu","We","Th","Fr","Sa","Su"]
                    Label {
                        text: modelData
                        horizontalAlignment: Text.AlignHCenter
                        Layout.preferredWidth: 32
                        opacity: 0.7
                    }
                }

                Repeater {
                    model: 42
                    delegate: Item {
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 28
                        property int dayNum: index - picker.offset() + 1
                        property bool valid: dayNum >= 1 && dayNum <= root._daysInMonth(picker.curYear, picker.curMonth)
                        Button {
                            anchors.fill: parent
                            visible: parent.valid
                            flat: true
                            text: parent.dayNum
                            onClicked: {
                                field.text = root._format(new Date(picker.curYear, picker.curMonth, parent.dayNum));
                                popup.close();
                            }
                        }
                    }
                }
            }
        }
    }
}
