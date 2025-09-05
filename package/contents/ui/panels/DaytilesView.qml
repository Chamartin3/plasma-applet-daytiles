import QtQuick 2.15
import QtQuick.Controls 2.15
import org.kde.plasma.core 2.0 as PlasmaCore
import "../daytilesRunner.js" as Runner

Item {
    id: view

    property var config: ({})
    property var events: []
    property var tiles: []
    property int svgW: 0
    property int svgH: 0
    property string dateFormat: "yyyy-MM-dd"

    signal tileClicked(var info)

    function _parseIso(s) {
        const m = /^(\d{4})-(\d{2})-(\d{2})$/.exec(s || "");
        if (!m) return null;
        return new Date(parseInt(m[1]), parseInt(m[2]) - 1, parseInt(m[3]));
    }

    function _formatDate(iso) {
        const d = _parseIso(iso);
        if (!d) return iso || "";
        return Qt.formatDate(d, view.dateFormat || "yyyy-MM-dd");
    }

    function tooltipFor(iso) {
        if (!iso) return "";
        const header = _formatDate(iso);
        const matches = (events || []).filter(function(e) {
            return e.start === iso || (e.end && e.start <= iso && iso <= e.end);
        });
        if (!matches.length) return header;
        const lines = matches.map(function(e) {
            const tag = e.type ? "[" + e.type + "] " : "";
            return tag + (e.note || "(" + (e.start || iso) + ")");
        });
        return header + "\n" + lines.join("\n");
    }

    function apply() {
        const cfgWithTheme = Object.assign({}, config, {
            themeFg: PlasmaCore.Theme.textColor.toString(),
            themeBg: PlasmaCore.Theme.backgroundColor.toString(),
        });
        try {
            const r = Runner.renderToSvgWithTiles(cfgWithTheme, events);
            if (!r || !r.svg) {
                image.source = "";
                view.tiles = [];
                return;
            }
            view.svgW = r.width;
            view.svgH = r.height;
            image.sourceSize.width = r.width;
            image.sourceSize.height = r.height;
            image.source = "data:image/svg+xml;utf8," + encodeURIComponent(r.svg);
            view.tiles = r.tiles;
        } catch (err) {
            console.warn("daytiles render failed:", err);
            image.source = "";
            view.tiles = [];
        }
    }

    onConfigChanged: apply()
    onEventsChanged: apply()
    Component.onCompleted: apply()

    Flickable {
        id: scroll
        anchors.fill: parent
        contentWidth: image.width
        contentHeight: image.height
        clip: true

        Image {
            id: image
            fillMode: Image.Pad
            smooth: true
            asynchronous: false
            width: sourceSize.width
            height: sourceSize.height

            Repeater {
                model: view.tiles
                delegate: MouseArea {
                    x: modelData.x
                    y: modelData.y
                    width: modelData.w
                    height: modelData.h
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: view.tileClicked({ date: modelData.date, note: modelData.note })

                    ToolTip.visible: containsMouse
                    ToolTip.delay: 200
                    ToolTip.text: {
                        view.dateFormat;
                        view.events;
                        return view.tooltipFor(modelData.date);
                    }
                }
            }
        }
    }
}
