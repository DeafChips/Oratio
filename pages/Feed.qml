import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Universal

import "qrc:/assets/MaterialDesign.js" as MD

Page {
    title: qsTr("Oratio")

    StackView.onActivated: {
        input.forceActiveFocus()
    }

    Text {
        id: backgroundicon
        text: MD.icons.mic_off
        anchors.fill: parent
        font.pointSize: 120
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        opacity: 0.1
        color: "white"
    }

    ScrollView {
        id: feedScrollView
        anchors.top: parent.top
        height: parent.height - input.height
        width: parent.width
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.interactive: true
        clip: true
        ListView {
            id: feed
            anchors.fill: parent
            delegate: Item {
                width: feed.width
                height: t.contentHeight + t.padding * 2
                Rectangle {
                    anchors.fill: parent
                    color: '#444'
                    border.color: 'white'
                    border.width: 1
                    opacity: 0.5
                }
                Label {
                    id: t
                    padding: 8
                    text: model.message
                    color: 'white'
                    width: parent.width
                    wrapMode: Text.Wrap
                }
            }
            model: ListModel {}
        }
    }

    TextArea {
        id: input
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        placeholderText: window.placeholderInput
        selectByMouse: true
        focus: true
        wrapMode: Text.Wrap
        property var wasTab: false
        property var emoteOpts: []
        property var emoteIndex: 0
        property var startPhrase: ""
        property var endPhrase: ""
        Keys.onUpPressed: {
            if (historyBuffer.length > 0 && window.historyIndex > 0) {
                if (window.historyIndex === historyBuffer.length) {
                    window.tmpBuffer = input.text;
                }
                window.historyIndex -= 1;
                input.text = historyBuffer[window.historyIndex];
                input.cursorPosition = historyBuffer[window.historyIndex].length;
            }
        }
        Keys.onDownPressed: {
            if (historyBuffer.length > 0) {
                window.historyIndex += 1;
                if (window.historyIndex > historyBuffer.length) {
                    window.historyIndex = historyBuffer.length;
                }
                if (window.historyIndex === historyBuffer.length) {
                    input.text = window.tmpBuffer;
                } else {
                    input.text = historyBuffer[window.historyIndex];
                    input.cursorPosition = historyBuffer[window.historyIndex].length;
                }
            }
        }
        Keys.onPressed: event => {
            if (event.key !== Qt.Key_Shift) {
                input.wasTab = false;
                input.emoteIndex = 0;
            }
        }
        Keys.onBacktabPressed: {
            if (input.emoteIndex > 0) {
                input.emoteIndex -= 1;
            } else {
                input.emoteIndex = input.emoteOpts.length - 1;
            }
            input.text = input.startPhrase + input.emoteOpts[input.emoteIndex].emoteName + " " + input.endPhrase;
            input.cursorPosition = (input.startPhrase + input.emoteOpts[input.emoteIndex].emoteName + " ").length;
        }
        Keys.onTabPressed: {
            var start = input.text.substring(0, input.cursorPosition).lastIndexOf(" ")+1
            var predicate = input.text.substring(start, input.cursorPosition)
            if (input.wasTab) {
                if (input.emoteIndex < input.emoteOpts.length - 1) {
                    input.emoteIndex += 1;
                } else {
                    input.emoteIndex = 0;
                }
                input.text = input.startPhrase + input.emoteOpts[input.emoteIndex].emoteName + " " + input.endPhrase;
                input.cursorPosition = (input.startPhrase + input.emoteOpts[input.emoteIndex].emoteName + " ").length;
            } else if (predicate.length > 1) {
                input.startPhrase = input.text.substring(0, start)
                input.endPhrase = input.text.substring(input.cursorPosition, input.text.length)
                var opts = window.emotes.filter((e) => {
                    return predicate.toLowerCase() == e.emoteName.toLowerCase().substring(0, predicate.length) 
                });
                input.emoteOpts = opts;

                if (opts.length > 0) {
                    input.text = input.startPhrase + opts[input.emoteIndex].emoteName + " " + input.endPhrase;
                    input.cursorPosition = (input.startPhrase + opts[input.emoteIndex].emoteName + " ").length;
                }
                input.wasTab = true;        
            }
        }
        Keys.onEnterPressed: {
            _onSubmit(input.text)
        }
        Keys.onReturnPressed: {
            _onSubmit(input.text)
        }
        function _onSubmit(t) {
            if (t !== '') {
                if (t === historyBuffer[historyBuffer.length-1]) {
                    // Don't append to history if same as last message
                } else {
                    historyBuffer.push(t)
                }
                if (displayServerSocket) {
                    var payload = {}
                    var displayText = t;
                    displayText = displayText.replace(window.emoteRegex, (key) => '<img style="height:' + settings.value("display2Dfontsize", "") + '" src="' + window.emoteDict[key].emotePath + '">');
                    payload["message"] = displayText;
                    displayServerSocket.sendTextMessage(JSON.stringify(payload))
                }
                feed.model.append({message: t})
                if (settings.value("twitchmirroring") === "true" && twitchsocket.active) {
                    twitchsocket.sendTextMessage("PRIVMSG #" + settings.value('twitchuser') + " :" + t);
                }
                input.text = ''
                feedScrollView.ScrollBar.vertical.position = 1
                if (feed.model.count > 25) {
                    feed.model.remove(0);
                }
                if (historyBuffer.length > 25) {
                    historyBuffer.shift();
                }
                window.historyIndex = historyBuffer.length;
                window.tmpBuffer = "";
            }
        }
    }
}

