import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.plasmoid 2.0

Item {
    id: root

    Plasmoid.fullRepresentation: DaytilesView {
        id: view
        Layout.minimumWidth: 320
        Layout.minimumHeight: 240
        Layout.preferredWidth: 480
        Layout.preferredHeight: 320

        config: ({
            layout:    "Month",
            shape:     "RoundedRect",
            startDate: "2025-01-01",
            endDate:   "2025-12-31",
            daySize:   16,
            gap:       2,
        })
        events: []
    }
}
