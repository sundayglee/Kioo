import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtMultimedia 5.9
import QtQuick.Window 2.0

RowLayout {
    property string playState : "playing"
    property string winState: "windowed"
    property var volumeValue: 0.5

    signal stop
    signal togglePlayback
    signal toggleFullScreen
    signal fileOpen
    signal skipNext
    signal skipPrevious
    signal openPlaylist
    signal openSettings
    signal volumeChanged

    function setVolume(value) {
        volumeSlider.value = value
    }

    anchors.right: parent.right
    anchors.left: parent.left
    spacing: 0

    Row {
        Layout.alignment: Qt.AlignLeft
        ToolButton {
            implicitHeight: 46
            implicitWidth: 46
            contentItem: Image {
                source: "/icon/menu.svg"
                opacity: 0.8
            }
            onClicked: {
                openSettings()
            }
        }
        
        ToolButton {
            implicitHeight: 48
            implicitWidth: 48
            contentItem:  Image {
                source: "/icon/playlist_play.svg"
                opacity: 0.8
            }
            onClicked: {
                openPlaylist()
            }
        }
    }
    
    
    // Media and Eject Block
    Row {
        Layout.alignment: Qt.AlignLeft
        ToolButton {
            implicitHeight: 44
            implicitWidth: 44
            contentItem:  Image {
                source: "/icon/video_library.svg"
                opacity: 0.8
            }
            onClicked: {
                fileOpen()
            }
        }        
    }
    
    Row {
        Layout.alignment: Qt.AlignCenter
        ToolButton {
            implicitHeight: 48
            implicitWidth: 48
            contentItem:  Image {
                source: "/icon/skip_previous.svg"
                opacity: 0.8
            }
            onClicked: {
                skipPrevious()
            }
        }

        ToolButton {
            implicitHeight: 48
            implicitWidth: 48
            contentItem:  Image {
                source: playState == "playing" ? "/icon/pause.svg" : "/icon/play.svg"
                opacity: 0.8
            }
            onClicked: {
                togglePlayback()
            }
        }

        ToolButton {
            implicitHeight: 48
            implicitWidth: 48
            contentItem:  Image {
                source: "/icon/stop.svg"
                opacity: 0.8
            }
            onClicked: {
                stop()
            }
        }

        ToolButton {
            implicitHeight: 48
            implicitWidth: 48
            contentItem:  Image {
                source: "/icon/skip_next.svg"
                opacity: 0.8
            }
            onClicked: {
                skipNext()
            }
        }

        ToolButton {
            implicitHeight: 48
            implicitWidth: 48
            contentItem: Image {
                source: "/icon/repeat.svg"
                opacity: 0.8
            }
        }

        ToolButton {
            implicitHeight: 48
            implicitWidth: 48
            contentItem:  Image {
                source: "/icon/shuffle.svg"
                opacity: 0.8
            }
        }
    }

    
    // Window Buttons
    Row {
        Layout.alignment: Qt.AlignLeft
    }
    
    Row {
        Layout.alignment: Qt.AlignRight

        ToolButton {
            implicitHeight: 48
            implicitWidth: 48
            contentItem: Image {
                source: winState == "windowed" ?   "/icon/fullscreen.svg" : "/icon/fullscreen_exit.svg"
                opacity: 0.8
            }
            onClicked: {
                toggleFullScreen()
            }
        }

        Slider {
            id: volumeSlider
            implicitWidth: 80

            value: volumeValue

            onValueChanged: {
                console.log("volume value is: "+value)
                volumeChanged()
            }

        }
    }
}
