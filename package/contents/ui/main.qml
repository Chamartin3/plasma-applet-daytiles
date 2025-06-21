import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 3.0 as PlasmaComponents

Item {
    id: root

    Plasmoid.fullRepresentation: PlasmaComponents.Label {
        text: "daytiles"
    }
}
