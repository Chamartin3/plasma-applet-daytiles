import QtQuick 2.15
import QtQuick.Controls 2.15
import org.kde.plasma.core 2.0 as PlasmaCore
import "daytilesRunner.js" as Runner

Item {
    id: view

    property var config: ({})
    property var events: []
    property var tiles: []
    property int svgW: 0
    property int svgH: 0

    signal tileClicked(var info)

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
                    ToolTip.text: modelData.note
                        ? modelData.date + "\n" + modelData.note
                        : (modelData.date || "?")
                }
            }
        }
    }
}
