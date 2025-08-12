import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

Frame {
    id: panel
    visible: false

    property string forDate: ""
    property var entries: []

    signal addRequested(string date)
    signal removeRequested(var entry)

    function open(date, list) {
        forDate = date;
        entries = list || [];
        visible = true;
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Kirigami.Units.smallSpacing

        Label {
            text: panel.forDate
            font.bold: true
        }

        Repeater {
            model: panel.entries
            delegate: RowLayout {
                Layout.fillWidth: true
                Label {
                    Layout.fillWidth: true
                    text: (modelData.note || qsTr("(no note)")) + (modelData.color ? "  (" + modelData.color + ")" : "")
                    wrapMode: Text.WordWrap
                }
                Button {
                    text: qsTr("Delete")
                    icon.name: "edit-delete"
                    flat: true
                    onClicked: panel.removeRequested(modelData)
                }
            }
        }

        RowLayout {
            Button {
                text: qsTr("Add here")
                onClicked: { panel.addRequested(panel.forDate); panel.visible = false; }
            }
            Button {
                text: qsTr("Close")
                onClicked: panel.visible = false
            }
        }
    }
}
