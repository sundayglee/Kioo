import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtMultimedia 5.9
import QtQuick.Window 2.0

RowLayout {
    property string playState : "playing"
    property string plstState: "one"    // All -> one, One-> two, Shuffle -> three
    property string winState: "windowed"
    property var volumeValue: -1

    signal stop
    signal togglePlayback
    signal toggleFullScreen
    signal plstChanged
    signal shufflePlaylist
    signal fileOpen
    signal skipNext
    signal skipPrevious
    signal openPlaylist
    signal openSettings
    signal volumeChanged(var vValue)

    anchors.right: parent.right
    anchors.left: parent.left
    anchors.bottom: parent.bottom

    spacing: 0

    Row {
        Layout.alignment: Qt.AlignLeft
        ToolButton {
            implicitHeight: 40
            implicitWidth: 40
            contentItem: Image {
                source: "/icon/menu.svg"
                opacity: 0.8
            }
            onClicked: {
                openSettings()
            }
        }
        
        ToolButton {
            implicitHeight: 40
            implicitWidth: 40
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
            implicitHeight: 40
            implicitWidth: 40
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
            implicitHeight: 40
            implicitWidth: 40
            contentItem:  Image {
                source: "/icon/skip_previous.svg"
                opacity: 0.8
            }
            onClicked: {
                skipPrevious()
            }
        }

        ToolButton {
            implicitHeight: 40
            implicitWidth: 40
            contentItem:  Image {
                source: playState == "playing" ? "/icon/pause.svg" : "/icon/play.svg"
                opacity: 0.8
            }
            onClicked: {
                togglePlayback()
            }
        }

        ToolButton {
            implicitHeight: 40
            implicitWidth: 40
            contentItem:  Image {
                source: "/icon/stop.svg"
                opacity: 0.8
            }
            onClicked: {
                stop()
            }
        }

        ToolButton {
            implicitHeight: 40
            implicitWidth: 40
            contentItem: Image {
                source: {
                    if(plstState === "one")
                        "/icon/repeat.svg"
                    else if(plstState ===  "two")
                        "/icon/repeat_one.svg"
                    else if(plstState === "three")
                        "/icon/shuffle.svg"
                }
                opacity: 0.8
            }
            onClicked: {
                plstChanged()
            }
        }

        ToolButton {
            implicitHeight: 40
            implicitWidth: 40
            contentItem:  Image {
                source: "/icon/skip_next.svg"
                opacity: 0.8
            }
            onClicked: {
                skipNext()
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
            implicitHeight: 40
            implicitWidth: 40
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
                volumeChanged(volumeSlider.value)
            }
        }
    }
}
