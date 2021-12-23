import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Universal
import Qt.labs.folderlistmodel

Page {
    title: qsTr("Settings")

    TabBar {
        id: tbar
        width: parent.width
        TabButton {
            text: qsTr("Display Server")
        }
        TabButton {
            text: qsTr("Twitch")
        }
    }

    StackLayout {
        width: parent.width
        height: parent.height - tbar.height
        anchors.top: tbar.bottom
        currentIndex: tbar.currentIndex            
        ColumnLayout {
            spacing: 0
            width: parent.width
            ScrollView {
                Layout.fillHeight: true
                Layout.fillWidth: true
                contentWidth: parent.width
                clip: true
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                ScrollBar.vertical.interactive: true 
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8
                    Label {
                        Layout.fillWidth: true
                        Layout.margins: 8
                        text: !settingSwitch.checked ? qsTr("Display server running at <i>http://localhost:7777/2d/</i> (copy this url to your OBS browser source)") : qsTr("Display server running at <i>http://localhost:7777/3d/</i> (copy this url to your OBS browser source)")
                        wrapMode: Text.Wrap
                    }
                    Label {
                        Layout.fillWidth: true
                        Layout.margins: 8
                        Layout.alignment: Qt.AlignTop
                        text: qsTr("While on the settings page. Example text will be sent to the display server for you to visualize updates")
                        wrapMode: Text.Wrap
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: '#444'
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.margins: 8
                        spacing: 8
                        visible: !settingSwitch.checked
                        Label {
                            id: display2DbackgroundcolorText
                            text: qsTr("Background Color (#RRGGBBAA): ")
                            wrapMode: Text.Wrap
                        }
                        TextField {
                            id: display2Dbackgroundcolor
                            Layout.fillWidth: true
                            placeholderText: qsTr("Default: #000000FF")
                            text: settings.value("display2Dbackgroundcolor", "")
                            selectByMouse: true
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.margins: 8
                        spacing: 8
                        visible: !settingSwitch.checked
                        Label {
                            id: display2DbackgroundborderText
                            text: qsTr("Border (width type color): ")
                            wrapMode: Text.Wrap
                        }
                        TextField {
                            id: display2Dbackgroundborder
                            Layout.fillWidth: true
                            placeholderText: qsTr("Default: 2px solid #FFFFFFFF")
                            text: settings.value("display2Dbackgroundborder", "")
                            selectByMouse: true
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.margins: 8
                        spacing: 8
                        visible: !settingSwitch.checked
                        Label {
                            id: display2DfontText
                            text: qsTr("Font: ")
                            wrapMode: Text.Wrap
                        }
                        ComboBox {
                            id: display2Dfont
                            Layout.fillWidth: true
                            model: Qt.fontFamilies()
                            delegate: ItemDelegate {
                                width: display2Dfont.width
                                contentItem: Text {
                                    text: modelData
                                    font.family: modelData
                                    color: 'white'
                                    font.pixelSize: 14
                                    elide: Text.ElideRight
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                            Component.onCompleted: {
                                display2Dfont.model.forEach((x, ind) => {
                                    if (x == settings.value("display2Dfont", "")) {
                                        display2Dfont.currentIndex = ind
                                    }
                                });
                            }
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.margins: 8
                        spacing: 8
                        visible: !settingSwitch.checked
                        Label {
                            id: display2DsoundText
                            text: qsTr("Sound: ")
                            wrapMode: Text.Wrap
                        }
                        ComboBox {
                            Layout.fillWidth: true
                            id: display2Dsound
                            model: FolderListModel {
                                id: soundFiles
                                folder: appDirPath + "/displayserver/sounds"
                                showDirs: false
                                onStatusChanged: {
                                    if (soundFiles.status == FolderListModel.Ready) {
                                        display2Dsound.currentIndex = soundFiles.indexOf(settings.value("display2Dsoundfile", ""))
                                    }
                                }
                            }
                            delegate: ItemDelegate {
                                width: display2Dfont.width 
                                contentItem: Text {
                                    text: model.fileName
                                    color: 'white'
                                    font.pixelSize: 14
                                    elide: Text.ElideRight
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                            textRole: "fileName"
                            valueRole: "fileUrl"
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.margins: 8
                        spacing: 8
                        visible: !settingSwitch.checked
                        Label {
                            id: display2DtypespeedText
                            text: qsTr("Typing speed (in milliseconds; smaller is faster): ")
                            wrapMode: Text.Wrap
                        }
                        TextField {
                            id: display2Dtypespeed
                            Layout.fillWidth: true
                            placeholderText: qsTr("Default: 25")
                            text: settings.value("display2Dtypespeed", "")
                            selectByMouse: true
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.margins: 8
                        spacing: 8
                        visible: !settingSwitch.checked
                        Label {
                            id: display2DfadeoutspeedText
                            text: qsTr("Fade out speed (in milliseconds; smaller is faster): ")
                            wrapMode: Text.Wrap
                        }
                        TextField {
                            id: display2Dfadeoutspeed
                            Layout.fillWidth: true
                            placeholderText: qsTr("Default: 1000")
                            text: settings.value("display2Dfadeoutspeed", "")
                            selectByMouse: true
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.margins: 8
                        spacing: 8
                        visible: settingSwitch.checked
                        Label{
                            width: parent.width
                            text: qsTr("Coming soon")
                        }
                    }
                    Item { Layout.fillHeight: true }
                }
            }

            Rectangle {
                Layout.alignment: Qt.AlignBottom
                Layout.fillWidth: true
                height: 2
                color: '#444'
            }

            Button {
                id: displaySave
                Layout.alignment: Qt.AlignHCenter | Qt.AlignBaseline
                Layout.margins: 8
                text: qsTr("Save")
                onClicked: {
                    if (displayServerSocket) {
                        var cssPayload = {}
                        cssPayload["cssSetting"] = {
                            "background-color": display2Dbackgroundcolor.text,
                            "border": display2Dbackgroundborder.text,
                            "font-family": display2Dfont.currentText 
                        };
                        displayServerSocket.sendTextMessage(JSON.stringify(cssPayload))
                        var jsPayload = {}
                        jsPayload["jsSetting"] = {
                            "typeit-speed": display2Dtypespeed.text,
                            "fadeout-speed": display2Dfadeoutspeed.text,
                            "sound": display2Dsound.currentText
                        };
                        displayServerSocket.sendTextMessage(JSON.stringify(jsPayload));
                        statusText.color = "green";
                        statusText.text = "Display Settings Saved";
                    } else {
                        statusText.color = "yellow";
                        statusText.text = "Settings saved but display server not active";
                    }

                    settings.setValue('display2Dbackgroundcolor', display2Dbackgroundcolor.text)
                    settings.setValue('display2Dbackgroundborder', display2Dbackgroundborder.text)
                    settings.setValue('display2Dfont', display2Dfont.currentText)
                    settings.setValue('display2Dsoundfile', display2Dsound.currentValue.toString())
                    settings.setValue('display2Dsoundname', display2Dsound.currentText)
                    settings.setValue('display2Dtypespeed', display2Dtypespeed.text)
                    settings.setValue('display2Dfadeoutspeed', display2Dfadeoutspeed.text)
                }
            }
        }
        ColumnLayout {
            spacing: 0
            Label {
                Layout.fillWidth: true
                Layout.margins: 8
                id: twitchHeader
                text: qsTr("Login to <a href=\"http://localhost:7777/twitch\">Generate OAuth Token</a> and provide username and token below:")
                wrapMode: Text.Wrap
                onLinkActivated: link => {
                    Qt.openUrlExternally(Qt.resolvedUrl(link))
                }
                linkColor: hoveredLink ? 'white' : Universal.accent
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
                    cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                }
            }
            TextField {
                id: twitchUser
                Layout.fillWidth: true
                Layout.margins: 8
                placeholderText: qsTr("Enter twitch username")
                text: settings.value("twitchuser", "")
                selectByMouse: true
            }
            TextField {
                id: twitchSecret
                Layout.fillWidth: true
                Layout.margins: 8
                placeholderText: qsTr("Enter OAuth code here")
                text: settings.value("toastring", "")
                echoMode: TextInput.Password
                selectByMouse: true
            }
            CheckBox {
                id: chatMirroringEnabled
                Layout.fillWidth: true
                Layout.margins: 8
                checked: settings.value("twitchmirroring", "false") === "true"
                text: qsTr("Enable Twitch chat mirroring (messages you send will appear in chat)")
            }
            TextField {
                id: emotechannels
                Layout.fillWidth: true
                Layout.margins: 8
                text: settings.value("emotechannels", "")
                placeholderText: qsTr("Comma separated twitch channels to get additional emotes:")
                selectByMouse: true
                visible: false
            }
            Button {
                id: twitchSave
                Layout.alignment: Qt.AlignHCenter
                Layout.margins: 8
                text: qsTr("Save")
                onClicked: {
                    settings.setValue('twitchuser', twitchUser.text)
                    settings.setValue('toastring', twitchSecret.text)
                    settings.setValue('twitchmirroring', chatMirroringEnabled.checked)

                    if ((settings.value("toastring") !== "") && (settings.value("twitchuser") !== "")) {
                        twitchsocket.active = true
                    } else {
                        twitchsocket.active = false
                    }

                    if (settings.value("twitchmirroring") === "true") {
                        window.placeholderInput = qsTr("Send message as " + settings.value("twitchuser"))
                    } else {
                        window.placeholderInput = qsTr("Enter text here")
                    }

                    statusText.color = "green";
                    statusText.text = "Twitch Settings Saved";
                }
            }
            Item { Layout.fillHeight: true }
        }
    }

    Rectangle {
        anchors.top: tbar.bottom
        width: parent.width
        height: 5
        color: '#444'
    }
}
