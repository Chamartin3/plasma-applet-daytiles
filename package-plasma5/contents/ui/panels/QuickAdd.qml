import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami
import "../fields"

Frame {
    id: panel
    visible: false

    property string presetDate: ""

    signal saved(var entry)
    signal dismissed()

    function open(date) {
        startField.text = date || presetDate || "";
        endField.text = "";
        typeField.text = "";
        noteField.text = "";
        visible = true;
        startField.forceActiveFocus();
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Kirigami.Units.smallSpacing

        Kirigami.FormLayout {
            Layout.fillWidth: true

            DateField {
                id: startField
                Kirigami.FormData.label: qsTr("Start:")
            }
            DateField {
                id: endField
                Kirigami.FormData.label: qsTr("End:")
                placeholderText: qsTr("optional")
                invalid: !!(startField.text && text && text < startField.text)
            }
            TextField { id: typeField; Kirigami.FormData.label: qsTr("Type:"); placeholderText: qsTr("optional") }
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
                enabled: startField.text.length > 0 && !endField.invalid
                onClicked: {
                    const obj = { start: startField.text };
                    if (endField.text)   obj.end   = endField.text;
                    if (typeField.text)  obj.type  = typeField.text;
                    if (noteField.text)  obj.note  = noteField.text;
                    panel.saved(obj);
                    panel.visible = false;
                }
            }
        }
    }
}
