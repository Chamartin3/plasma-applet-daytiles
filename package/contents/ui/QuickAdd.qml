import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

Frame {
    id: panel
    visible: false

    property string presetDate: ""

    signal saved(var entry)
    signal dismissed()

    function open(date) {
        startField.text = date || presetDate || "";
        endField.text = "";
        colorField.text = "";
        noteField.text = "";
        visible = true;
        startField.forceActiveFocus();
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Kirigami.Units.smallSpacing

        Kirigami.FormLayout {
            Layout.fillWidth: true

            TextField {
                id: startField
                Kirigami.FormData.label: qsTr("Start:")
                placeholderText: "YYYY-MM-DD"
                validator: RegExpValidator { regExp: /^\d{4}-\d{2}-\d{2}$/ }
            }
            TextField {
                id: endField
                Kirigami.FormData.label: qsTr("End:")
                placeholderText: qsTr("optional")
            }
            TextField {
                id: colorField
                Kirigami.FormData.label: qsTr("Color:")
                placeholderText: "#ff5577"
            }
            TextField { id: noteField;  Kirigami.FormData.label: qsTr("Note:") }
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            Button {
                text: qsTr("Cancel")
                onClicked: { panel.visible = false; panel.dismissed(); }
            }
            Button {
                text: qsTr("Save")
                enabled: startField.text.length > 0
                onClicked: {
                    const obj = { start: startField.text };
                    if (endField.text)   obj.end   = endField.text;
                    if (colorField.text) obj.color = colorField.text;
                    if (noteField.text)  obj.note  = noteField.text;
                    panel.saved(obj);
                    panel.visible = false;
                }
            }
        }
    }
}
