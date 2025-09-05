import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami
import "../fields"

Item {
    id: form
    Layout.fillWidth: true
    Layout.fillHeight: true

    property alias cfg_eventsJson:           store.text
    property alias cfg_eventTypeColorsJson:  typesStore.text

    function rangeInvalid(start, end) {
        return !!(start && end && end < start);
    }

    function parseEvents() {
        try { return JSON.parse(store.text || "[]"); } catch (e) { return []; }
    }
    function writeEvents(arr) { store.text = JSON.stringify(arr); }

    function parseTypes() {
        try { return JSON.parse(typesStore.text || "{}"); } catch (e) { return {}; }
    }
    function writeTypes() {
        const obj = {};
        for (let i = 0; i < types.count; ++i) {
            const t = types.get(i);
            if (t.name) obj[t.name] = t.color || "";
        }
        typesStore.text = JSON.stringify(obj);
    }

    TextField { id: store;      visible: false }
    TextField { id: typesStore; visible: false }

    ScrollView {
        id: scroll
        anchors.fill: parent
        anchors.leftMargin: Kirigami.Units.largeSpacing
        anchors.topMargin: Kirigami.Units.largeSpacing
        anchors.bottomMargin: Kirigami.Units.largeSpacing
        anchors.rightMargin: 0
        clip: true
        contentWidth: availableWidth
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

    ColumnLayout {
        width: scroll.availableWidth - Kirigami.Units.smallSpacing
        spacing: Kirigami.Units.largeSpacing

        Label { text: i18n("Events"); font.bold: true }

        Frame {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(280, Math.max(60, events.count * 48 + 16))

            ListView {
                id: list
                anchors.fill: parent
                clip: true
                spacing: 4
                model: ListModel { id: events }
                delegate: RowLayout {
                    width: list.width
                    spacing: 4
                    DateField {
                        Layout.preferredWidth: 150
                        text: model.start
                        onTextChanged: if (text !== model.start) { events.setProperty(index, "start", text); persist(); }
                    }
                    DateField {
                        Layout.preferredWidth: 150
                        text: model.end
                        placeholderText: i18n("end")
                        invalid: form.rangeInvalid(model.start, text)
                        onTextChanged: if (text !== model.end) { events.setProperty(index, "end", text); persist(); }
                    }
                    ComboBox {
                        Layout.preferredWidth: 140
                        editable: true
                        model: typeNames
                        currentIndex: -1
                        Component.onCompleted: editText = events.get(index).type || ""
                        onEditTextChanged: if (editText !== events.get(index).type) { events.setProperty(index, "type", editText); persist(); }
                    }
                    TextField {
                        Layout.fillWidth: true
                        text: model.note
                        placeholderText: i18n("note")
                        onTextChanged: if (text !== model.note) { events.setProperty(index, "note", text); persist(); }
                    }
                    Button {
                        flat: true
                        icon.name: "edit-delete"
                        onClicked: { events.remove(index); persist(); }
                    }
                }
            }
        }

        Kirigami.FormLayout {
            Layout.fillWidth: true

            DateField { id: addStart; Kirigami.FormData.label: i18n("Start:") }
            DateField {
                id: addEnd
                Kirigami.FormData.label: i18n("End:")
                placeholderText: i18n("optional")
                invalid: form.rangeInvalid(addStart.text, text)
            }
            ComboBox {
                id: addType
                Kirigami.FormData.label: i18n("Type:")
                editable: true
                model: typeNames
                currentIndex: -1
                displayText: ""
                Component.onCompleted: editText = ""
            }
            TextField { id: addNote; Kirigami.FormData.label: i18n("Note:") }

            Button {
                text: i18n("Add event")
                enabled: addStart.text.length > 0 && !form.rangeInvalid(addStart.text, addEnd.text)
                onClicked: {
                    events.append({
                        start: addStart.text,
                        end:   addEnd.text   || "",
                        color: "",
                        type:  addType.editText || "",
                        note:  addNote.text  || "",
                    });
                    addStart.text = ""; addEnd.text = "";
                    addType.currentIndex = -1; addType.editText = ""; addNote.text = "";
                    persist();
                }
            }
        }

        Kirigami.Separator { Layout.fillWidth: true }

        Label { text: i18n("Event types"); font.bold: true }

        ListModel { id: typeNames }

        Frame {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(180, Math.max(60, types.count * 40 + 16))

            ListView {
                id: typesList
                anchors.fill: parent
                clip: true
                model: ListModel { id: types }
                delegate: RowLayout {
                    width: typesList.width
                    spacing: 6
                    TextField {
                        Layout.preferredWidth: 120
                        text: model.name
                        placeholderText: i18n("name")
                        onEditingFinished: { types.setProperty(index, "name", text); refreshTypeNames(); writeTypes(); }
                    }
                    ColorField {
                        Layout.fillWidth: true
                        text: model.color
                        onTextChanged: { if (text !== model.color) { types.setProperty(index, "color", text); writeTypes(); } }
                    }
                    Button {
                        text: i18n("Remove")
                        flat: true
                        icon.name: "edit-delete"
                        onClicked: { types.remove(index); refreshTypeNames(); writeTypes(); }
                    }
                }
            }
        }

        Button {
            text: i18n("Add type")
            icon.name: "list-add"
            onClicked: { types.append({ name: "", color: "" }); }
        }

        Kirigami.Separator { Layout.fillWidth: true }

        RowLayout {
            Layout.fillWidth: true

            Button {
                text: i18n("Export…")
                onClicked: exportArea.visible = !exportArea.visible
            }
            Button {
                text: i18n("Import")
                enabled: importArea.text.length > 0
                onClicked: form.importJson(importArea.text)
            }
        }

        TextArea {
            id: exportArea
            Layout.fillWidth: true
            Layout.preferredHeight: 100
            visible: false
            readOnly: true
            text: store.text
        }

        TextArea {
            id: importArea
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            placeholderText: i18n("Paste events JSON to import…")
        }
    }
    }

    function importJson(raw) {
        try {
            const arr = JSON.parse(raw);
            if (!Array.isArray(arr)) return;
            for (const e of arr) {
                if (!e || typeof e.start !== "string") continue;
                events.append({
                    start: e.start,
                    end:   e.end   || "",
                    color: e.color || "",
                    type:  e.type  || "",
                    note:  e.note  || "",
                });
            }
            persist();
            importArea.text = "";
        } catch (e) {}
    }

    function persist() {
        const arr = [];
        for (let i = 0; i < events.count; ++i) {
            const e = events.get(i);
            const obj = { start: e.start };
            if (e.end)   obj.end   = e.end;
            if (e.color) obj.color = e.color;
            if (e.type)  obj.type  = e.type;
            if (e.note)  obj.note  = e.note;
            arr.push(obj);
        }
        writeEvents(arr);
    }

    function refreshTypeNames() {
        typeNames.clear();
        for (let i = 0; i < types.count; ++i) {
            const n = types.get(i).name;
            if (n) typeNames.append({ text: n });
        }
    }

    Component.onCompleted: {
        const arr = parseEvents();
        for (const e of arr) events.append({
            start: e.start || "",
            end:   e.end   || "",
            color: e.color || "",
            type:  e.type  || "",
            note:  e.note  || "",
        });
        const t = parseTypes();
        for (const k in t) {
            if (Object.prototype.hasOwnProperty.call(t, k))
                types.append({ name: k, color: t[k] || "" });
        }
        refreshTypeNames();
    }
}
