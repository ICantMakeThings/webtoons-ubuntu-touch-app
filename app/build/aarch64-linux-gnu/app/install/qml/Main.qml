import QtQuick 2.12
import Ubuntu.Components 1.3
import QtQuick.Window 2.2
import QtWebEngine 1.10

MainView {
    id: window
    applicationName: "webtoons.icmt"
    backgroundColor: "#323232"

    function isEpisode(url) {
        return url.toString().indexOf("/viewer?") !== -1
    }

    //
    // PROFILES
    //
    WebEngineProfile {
        id: mobileProfile
        storageName: "mobileProfile"
        persistentCookiesPolicy: WebEngineProfile.ForcePersistentCookies
        httpUserAgent: "Mozilla/5.0 (Linux; Android 8.0.0; Pixel) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.98 Mobile Safari/537.36"
    }

    WebEngineProfile {
        id: readerProfile
        storageName: "readerProfile"
        persistentCookiesPolicy: WebEngineProfile.ForcePersistentCookies
        httpUserAgent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3396.99 Safari/537.36"
    }

    //
    // MOBILE WEBVIEW (DEFAULT)
    //
    WebEngineView {
        id: mobileView
        anchors.fill: parent
        profile: mobileProfile
        visible: true
        zoomFactor: 1.0
        url: "https://m.webtoons.com/"

        settings {
            javascriptEnabled: true
            showScrollBars: false
        }

        onUrlChanged: {
            if (isEpisode(url)) {
                readerView.url = url
                readerView.visible = true
                mobileView.visible = false
            }
        }
    }

    //
    // READER WEBVIEW (DESKTOP MODE)
    //
    WebEngineView {
        id: readerView
        anchors.fill: parent
        profile: readerProfile
        visible: false
        zoomFactor: 0.45

        settings {
            javascriptEnabled: true
            showScrollBars: false
        }

        onUrlChanged: {
            if (!isEpisode(url)) {
                mobileView.url = url
                mobileView.visible = true
                readerView.visible = false
            }
        }

        userScripts: [
            WebEngineScript {
                name: "readerCSS"
                injectionPoint: WebEngineScript.DocumentReady
                worldId: WebEngineScript.MainWorld
                sourceCode: readerCss
            }
        ]
    }

    //
    // CSS INJECTION FOR READER
    //
    property string readerCss: "
        (function() {
            var style = document.createElement('style');
            style.innerHTML = `
                html, body {
                    margin: 0 !important;
                    padding: 0 !important;
                    overflow-x: hidden !important;
                    background: #000 !important;
                }

                img {
                    max-width: 100% !important;
                    height: auto !important;
                    display: block !important;
                    margin: 0 auto !important;
                }

                #viewerContainer,
                .viewer,
                .viewer_container {
                    max-width: 800px !important;
                    margin-left: auto !important;
                    margin-right: auto !important;
                }
            `;
            document.head.appendChild(style);
        })();
    "
}