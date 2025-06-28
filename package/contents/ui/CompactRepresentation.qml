import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0

MouseArea {
    id: compact

    Layout.minimumWidth:  PlasmaCore.Units.iconSizes.small
    Layout.minimumHeight: PlasmaCore.Units.iconSizes.small

    onClicked: plasmoid.expanded = !plasmoid.expanded

    PlasmaCore.IconItem {
        anchors.fill: parent
        source: "view-calendar"
    }
}
