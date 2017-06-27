import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtMultimedia 5.9

ApplicationWindow {
    id: win
    visible: true
    width: 640
    height: 480
    title: qsTr("Kioo Media Player")

    Video {
        id: video
        width: win.width
        height: win.height
        source: "C:/Qt/sample.avi"

        MouseArea {
            anchors.fill: parent
            onClicked: {
                video.play()
            }
        }
        focus: true
    }

    footer: ColumnLayout {
        spacing: 0

            Rectangle {
                Layout.alignment: Qt.AlignRight
                color: "green"
                Layout.preferredWidth: parent.width
                Layout.preferredHeight: 40

                RowLayout {
                    anchors.fill: parent
                        spacing: 6

                        Button {
                            text: "Button"
                        }

                        Rectangle {
                            color: 'teal'
                            Layout.fillWidth: true
                            Layout.minimumWidth: 50
                            Layout.preferredWidth: 100
                            Layout.maximumWidth: 300
                            Layout.minimumHeight: 150
                            Text {
                                anchors.centerIn: parent
                                text: parent.width + 'x' + parent.height
                            }
                        }
                        Rectangle {
                            color: 'plum'
                            Layout.fillWidth: true
                            Layout.minimumWidth: 100
                            Layout.preferredWidth: 200
                            Layout.preferredHeight: 100
                            Text {
                                anchors.centerIn: parent
                                text: parent.width + 'x' + parent.height
                            }
                        }

                }
            }
    }

}
