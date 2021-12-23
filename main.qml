import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtWebSockets
import Qt.labs.settings

import "qrc:/assets/MaterialDesign.js" as MD
import "qrc:/pages/emotesapi.js" as EmotesApi

ApplicationWindow {
    id: window
    width: 640
    height: 480
    visible: true
    property var emotes: []
    property var emoteDict: {}
    property var emoteSets: []
    property var emoteRegex
    property var historyBuffer: []
    property var historyIndex: 0
    property var tmpBuffer: ""
    property var displayServerSocket
    property var twitchAuthed: false
    property var placeholderInput: qsTr("Enter text here")
    property var eapi

    header: ToolBar {
        contentHeight: toolButton.implicitHeight
        
        RowLayout {
            anchors.fill: parent
            ToolButton {
                id: toolButton
                text: MD.icons.arrow_back
                font.pixelSize: Qt.application.font.pixelSize * 1.6
                onClicked: {
                    if (stackView.currentItem.title == "Settings") {
                        if (displayServerSocket) {
                            var payload = {};
                            payload["settingScreen"] = false;
                            displayServerSocket.sendTextMessage(JSON.stringify(payload));
                        }
                    }
                    if (stackView.depth > 1) {
                        stackView.pop()
                    }
                }
                visible: stackView.depth > 1 ? true : false
            }

            Label {
                text: stackView.currentItem.title
                padding: 8
                horizontalAlignment: Qt.AlignHLeft
                verticalAlignment: Qt.AlignVCenter
            }
            Item {
                Layout.fillWidth: true
            }
            Label {
                id: statusText
                text: ''
                padding: 8
                horizontalAlignment: Qt.AlignHLeft
                verticalAlignment: Qt.AlignVCenter
                onTextChanged: {
                    statusText.visible = true
                    statusTimer.start()
                }
                Timer{
                    id: statusTimer
                    interval: 5000
                    onTriggered: {
                        statusText.visible = false;
                        statusText.text = "";
                    }
                }
            }
            ToolButton {
                id: emotesButton
                text: MD.icons.tag_faces
                font.pixelSize: Qt.application.font.pixelSize * 1.6
                onClicked: {
                    if (stackView.depth === 1){
                        stackView.push("qrc:/pages/Emotes.qml")
                    }
                }
                activeFocusOnTab: false
                visible: stackView.depth > 1 ? false : true
            }
            ToolButton {
                id: settingsButton
                text: MD.icons.settings
                font.pixelSize: Qt.application.font.pixelSize * 1.6
                onClicked: {
                    if (stackView.depth === 1){
                        stackView.push("qrc:/pages/Settings.qml")
                    }
                    if (displayServerSocket) {
                        var payload = {};
                        payload["settingScreen"] = true;
                        displayServerSocket.sendTextMessage(JSON.stringify(payload));
                    }
                }
                activeFocusOnTab: false
                visible: stackView.depth > 1 ? false : true
            }
            Switch {
                id: settingSwitch
                text: settingSwitch.checked ? qsTr("3D display") : qsTr("2D display")            
                visible: stackView.currentItem.title == "Settings" ? true : false
            }
        }
    }

    StackView {
        id: stackView
        initialItem: "qrc:/pages/Feed.qml"
        anchors.fill: parent
    }

    Shortcut {
        sequence: "F5"
        context: Qt.ApplicationShortcut
        onActivated: {
            //console.log('f5 pressed');
            _leaveChannel();
            _joinChannel();
        }
    }

    Component.onCompleted: {
        // Attempt to connect to twitchsocket
        if ((settings.value("toastring") !== "") && (settings.value("twitchuser") !== "")) {
            twitchsocket.active = true
        } else {
            twitchsocket.active = false
        }
        window.eapi = new EmotesApi.EmotesApi(settings.toastring);
    }

    Component.onDestruction: {
        //console.log('destroyed')

    }

    Settings {
        id: settings

        property var toastring: ""
        property var twitchmirroring: "false"
        property var twitchuser: ""
        property var display2Dbackgroundcolor: "#000000FF"
        property var display2Dbackgroundborder: "2px solid #FFFFFFFF"
        property var display2Dfont: "Segoe UI Black"
        property var display2Dsoundname: "boop.mp3"
        property var display2Dsoundfile: appDirPath + "/displayserver/sounds/boop.mp3" 
        property var display2Dtypespeed: "25"
        property var display2Dfadeoutspeed: "1000"
    }

    WebSocketServer {
        id: socketserver
        port: 7778
        onClientConnected: webSocket => {
            displayServerSocket = webSocket;
            var cssPayload = {}
            cssPayload["cssSetting"] = {
                "background-color": settings.value("display2Dbackgroundcolor", ""),
                "border": settings.value("display2Dbackgroundborder", ""),
                "font-family": settings.value("display2Ddont", "") 
            };
            displayServerSocket.sendTextMessage(JSON.stringify(cssPayload))
            var jsPayload = {}
            jsPayload["jsSetting"] = {
                "typeit-speed": settings.value("display2Dtypespeed", "") ,
                "fadeout-speed": settings.value("display2Dfadeoutspeed", ""),
                "sound": settings.value("display2Dsoundname", "")
            };
            displayServerSocket.sendTextMessage(JSON.stringify(jsPayload));
        }
        listen: true
    }

    function _joinChannel() {
        twitchsocket.sendTextMessage("JOIN #" + settings.twitchuser);
    }

    function _leaveChannel() {
        twitchsocket.sendTextMessage("PART #" + settings.twitchuser);
    }

    WebSocket {
        id: twitchsocket
        url: "wss://irc-ws.chat.twitch.tv:443"
        onStatusChanged: if (twitchsocket.status == WebSocket.Error) {
            //console.log("Error: " + twitchsocket.errorString);
        } else if (twitchsocket.status == WebSocket.Open) {
            //console.log("twitchsocket open");
            twitchsocket.sendTextMessage("CAP REQ :twitch.tv/tags twitch.tv/commands twitch.tv/membership");
            twitchsocket.sendTextMessage("PASS oauth:" + settings.toastring);
            twitchsocket.sendTextMessage("NICK " + settings.twitchuser);
            _joinChannel();
            statusText.color = "green";
            statusText.text = "Successfully Authed to Twitch";
        } else if (twitchsocket.status == WebSocket.Closed) {
            //console.log("twitchsocket closed");
        }
        onTextMessageReceived: message => {
            //console.log(message)
            if (message.startsWith("PING")) {
                _pong();
            } else if (message.includes("PRIVMSG")) {
                //console.log(message);
            } else if (message.includes(" USERSTATE ")){
                _getEmotesSets(message);
            }
        }
        active: false

        function arraysEqual(a,b) {
            if (a === b) return true;
            if (a == null || b == null) return false;
            if (a.length !== b.length) return false;
            for (var i = 0; i < a.length; ++i) {
                if (a[i] !== b[i]) return false;
            }
            return true;
        }

        function _getEmotesSets(message) {
            var newEmoteSets = [];
            message.split(";").forEach((i) => {
                if (i.startsWith('emote-sets=')) {
                    newEmoteSets = i.substring(11).split(",");
                }
            });
            if (!arraysEqual(window.emoteSets, newEmoteSets)) {
                window.eapi.loadEmotes(newEmoteSets);
                window.emotes = window.eapi.orderedList;
                window.emoteDict = window.eapi.emotesList;
                var regstring = window.eapi.rankedList.map((v) => v.emoteName.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')).join("|");
                window.emoteRegex = new RegExp(regstring, "g")
                statusText.color = "green";
                statusText.text = "Emotes Refreshed";
                window.emoteSets = newEmoteSets;
            }
        }

        function _pong() {
            twitchsocket.sendTextMessage("PONG :tmi.twitch.tv");
        }
    }
}
