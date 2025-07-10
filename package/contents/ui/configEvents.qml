import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

Item {
    id: form
    Layout.fillWidth: true
    Layout.fillHeight: true

    property alias cfg_eventsJson: store.text

    function parseEvents() {
        try { return JSON.parse(store.text || "[]"); } catch (e) { return []; }
    }
    function writeEvents(arr) { store.text = JSON.stringify(arr); }

    TextField { id: store; visible: false }

    ColumnLayout {
        anchors.fill: parent
        spacing: Kirigami.Units.smallSpacing

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true

        ListView {
            id: list
            anchors.fill: parent
            clip: true
            model: ListModel { id: events }
            delegate: RowLayout {
                width: list.width
                Label {
                    Layout.fillWidth: true
                    text: model.start + (model.end ? "  →  " + model.end : "")
                          + (model.note ? "   " + model.note : "")
                }
                Button {
                    text: i18n("Remove")
                    onClicked: { events.remove(index); persist(); }
                }
            }
        }
        }

        Kirigami.FormLayout {
            Layout.fillWidth: true

            TextField { id: addStart; Kirigami.FormData.label: i18n("Start:"); placeholderText: "YYYY-MM-DD" }
            TextField { id: addEnd;   Kirigami.FormData.label: i18n("End:");   placeholderText: i18n("optional") }
            TextField { id: addColor; Kirigami.FormData.label: i18n("Color:"); placeholderText: "#ff5577" }
            TextField { id: addNote;  Kirigami.FormData.label: i18n("Note:") }

            Button {
                text: i18n("Add event")
                enabled: addStart.text.length > 0
                onClicked: {
                    events.append({
                        start: addStart.text,
                        end:   addEnd.text || "",
                        color: addColor.text || "",
                        note:  addNote.text  || "",
                    });
                    addStart.text = ""; addEnd.text = ""; addColor.text = ""; addNote.text = "";
                    persist();
                }
            }
        }
    }

    function persist() {
        const arr = [];
        for (let i = 0; i < events.count; ++i) {
            const e = events.get(i);
            const obj = { start: e.start };
            if (e.end)   obj.end   = e.end;
            if (e.color) obj.color = e.color;
            if (e.note)  obj.note  = e.note;
            arr.push(obj);
        }
        writeEvents(arr);
    }

    Component.onCompleted: {
        const arr = parseEvents();
        for (const e of arr) events.append(e);
    }
}
