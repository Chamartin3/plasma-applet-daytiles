import QtQuick 2.15
import QtWebEngine 1.10
import org.kde.plasma.core 2.0 as PlasmaCore

WebEngineView {
    id: view

    property var config: ({})
    property var events: []

    backgroundColor: "transparent"
    url: Qt.resolvedUrl("../web/index.html")

    settings.localContentCanAccessFileUrls: true
    settings.localContentCanAccessRemoteUrls: false
    settings.javascriptEnabled: true
    settings.webGLEnabled: false
    settings.errorPageEnabled: false
    settings.spatialNavigationEnabled: false

    function apply() {
        const cfgWithTheme = Object.assign({}, config, {
            themeFg: PlasmaCore.Theme.textColor.toString(),
            themeBg: PlasmaCore.Theme.backgroundColor.toString(),
        });
        const payload = JSON.stringify({ cfg: cfgWithTheme, events: events });
        runJavaScript("window.daytilesBridge && window.daytilesBridge.applyConfig("
                      + "(" + payload + ").cfg, (" + payload + ").events)");
    }

    onLoadingChanged: function(info) {
        if (info.status === WebEngineView.LoadSucceededStatus) apply();
        else if (info.status === WebEngineView.LoadFailedStatus) {
            console.warn("daytiles: page failed to load:", info.errorString);
        }
    }

    onJavaScriptConsoleMessage: function(level, message, lineNumber, sourceID) {
        if (message.indexOf("DAYTILES_CLICK ") === 0) {
            try {
                const data = JSON.parse(message.slice("DAYTILES_CLICK ".length));
                view.tileClicked(data);
            } catch (e) {
                console.warn("daytiles bridge: bad click payload", message);
            }
        }
    }

    signal tileClicked(var info)
}
