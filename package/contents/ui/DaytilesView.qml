import QtQuick 2.15
import QtWebEngine 1.10

WebEngineView {
    id: view

    property var config: ({})
    property var events: []

    backgroundColor: "transparent"
    url: Qt.resolvedUrl("../web/index.html")

    settings.localContentCanAccessFileUrls: true
    settings.localContentCanAccessRemoteUrls: false
    settings.javascriptEnabled: true

    function apply() {
        const payload = JSON.stringify({ cfg: config, events: events });
        runJavaScript("window.daytilesBridge && window.daytilesBridge.applyConfig("
                      + "(" + payload + ").cfg, (" + payload + ").events)");
    }

    onLoadingChanged: function(info) {
        if (info.status === WebEngineView.LoadSucceededStatus) apply();
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
