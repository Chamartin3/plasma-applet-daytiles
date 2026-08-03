import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

MouseArea {
    id: compact

    Layout.minimumWidth:  Kirigami.Units.iconSizes.small
    Layout.minimumHeight: Kirigami.Units.iconSizes.small

    Kirigami.Icon {
        anchors.fill: parent
        source: "view-calendar"
    }

    PlasmaCore.ToolTipArea {
        anchors.fill: parent
        mainText: i18n("Daytiles")
        subText: Qt.formatDate(new Date(), "dddd, MMMM d, yyyy")
    }
}
