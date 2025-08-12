import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3

RowLayout {
    id: root

    property alias text: field.text
    property alias placeholderText: field.placeholderText

    spacing: 4

    TextField {
        id: field
        Layout.fillWidth: true
        placeholderText: "#ff5577"
    }

    Rectangle {
        id: swatch
        Layout.preferredWidth: 24
        Layout.preferredHeight: 24
        radius: 4
        border.color: Qt.rgba(0, 0, 0, 0.4)
        border.width: 1
        color: /^#[0-9a-fA-F]{3,8}$/.test((field.text || "").trim()) ? field.text.trim() : "transparent"
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (swatch.color != "transparent") dialog.color = swatch.color;
                dialog.open();
            }
        }
    }

    Button {
        text: qsTr("Pick…")
        flat: true
        icon.name: "color-picker"
        onClicked: dialog.open()
    }

    ColorDialog {
        id: dialog
        title: qsTr("Choose color")
        showAlphaChannel: false
        onAccepted: {
            const c = dialog.color;
            const hex = function(v) {
                const h = Math.round(v * 255).toString(16);
                return h.length < 2 ? "0" + h : h;
            };
            field.text = "#" + hex(c.r) + hex(c.g) + hex(c.b);
        }
    }
}
