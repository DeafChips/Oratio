import QtQuick
import QtQuick.Controls

Page {
    title: qsTr("Emotes")

    ScrollView {
        id: emotesScrollView
        anchors.fill: parent
        ScrollBar.horizontal: ScrollBar {
            policy: ScrollBar.AlwaysOff
        }
        ScrollBar.vertical.interactive: true
        GridView {
            id: gridView
            model: ListModel {}
            Component.onCompleted: {
                window.emotes.forEach((v) => {
                    model.append({"name": v.emoteName, "url": v.emotePath, "cat": v.emoteCategory});
                })
            }
            delegate: Item {
                Column {
                    padding: 8
                    AnimatedImage {
                        anchors.horizontalCenter: parent.horizontalCenter
                        height: 32
                        width: 32
                        fillMode: Image.PreserveAspectFit
                        source: model.url
                    }
                    Label {
                        text: model.name
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: 'white'
                    }
                    Label {
                        text: model.cat
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: 'white'
                    }
                    spacing: 2
                }
            }
            cellHeight: 100
        }
    }
}
