/************************************************************************************************
    Kioo Media Player: A Player With Clear Crystal Sound, Extra Sharp Video, with a Beautiful Design.
    Copyright (C) 2017 - 2020 Kioo Media Player <support@kiooplayer.com>.
    Homepage: https://www.kiooplayer.com
    Developer: Godfrey E Laswai <sundayglee@gmail.com>
    All rights reserved.

    Use of this source code is governed by a BSD-3-Clause license that can be
    found in the BSD LICENSE file or see it here <https://opensource.org/licenses/BSD-3-Clause>.
*************************************************************************************************/

import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtMultimedia 5.9
import QtQuick.Window 2.0

RowLayout {
    property string playState : "playing"   
    property string plstState: "one"    // All -> one, One-> two, Shuffle -> three
     property string plbSpeed : "x1.0" // Playback Speed 0.25 -> 0.5 -> 0.75 -> 1.0 -> 1.25 -> 1.5 -> 1.75 -> 2 -> 0.25
    property string winState: "windowed"
    property var volumeValue: -1.0

    signal stop
    signal togglePlayback
    signal toggleFullScreen
    signal plstChanged
    signal plbsChanged
    signal shufflePlaylist
    signal fileOpen
    signal urlOpen
    signal skipNext
    signal skipPrevious
    signal openPlaylist
    signal openSettings
    signal volumeChanged(var vValue)
    signal postKSP

//    anchors.right: parent.right
//    anchors.left: parent.left
//    anchors.bottom: parent.bottom

    spacing: 0

    Row {
        Layout.alignment: Qt.AlignLeft
        ToolButton {
            implicitHeight: 40
            implicitWidth: 40

            hoverEnabled: true
            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.visible: hovered
            ToolTip.text: qsTr("Go to Settings")

            contentItem: Image {
                source: "/icon/menu.svg"

            }
            onClicked: {
                focus = true
                openSettings()
                focus = false
            }
        }
        
        ToolButton {
            implicitHeight: 40
            implicitWidth: 40

            hoverEnabled: true
            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.visible: hovered
            ToolTip.text: qsTr("Go to Playlist")

            contentItem:  Image {
                source: "/icon/playlist_play.svg"

            }
            onClicked: {
                focus = true
                openPlaylist()
                focus = false
            }
        }
    }
    
    
    // Media and Eject Block
    Row {
        Layout.alignment: Qt.AlignLeft

        ToolButton {
            implicitHeight: 40
            implicitWidth: 40

            hoverEnabled: true
            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.visible: hovered
            ToolTip.text: qsTr("Open Media File(s)")

            contentItem:  Image {
                source: "/icon/video_library.svg"

            }

            onClicked: {
                focus = false
                fileOpen()
            }
        }

        ToolButton {
            implicitHeight: 40
            implicitWidth: 40

            hoverEnabled: true
            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.visible: hovered
            ToolTip.text: qsTr("Play A Stream")

            contentItem:  Image {
                source: "/icon/online.svg"

            }
            onClicked: {
                focus = false
                urlOpen()
            }
        }

        ToolButton {
            implicitHeight: 40
            implicitWidth: 60
        }
    }
    
    Row {
        Layout.alignment: Qt.AlignCenter
        ToolButton {
            implicitHeight: 40
            implicitWidth: 40

            hoverEnabled: true
            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.visible: hovered
            ToolTip.text: qsTr("Play Previus Media File")

            contentItem:  Image {
                source: "/icon/skip_previous.svg"

            }
            onClicked: {
                focus = false
                skipPrevious()
            }
        }

        ToolButton {
            implicitHeight: 40
            implicitWidth: 40

            hoverEnabled: true
            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.visible: hovered
            ToolTip.text: qsTr("Pause Current Playing Media")


            contentItem:  Image {
                source: playState == "playing" ? "/icon/pause.svg" : "/icon/play.svg"

            }
            onClicked: {
                focus = false
                togglePlayback()
            }
        }

        ToolButton {
            implicitHeight: 40
            implicitWidth: 40

            hoverEnabled: true
            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.visible: hovered
            ToolTip.text: qsTr("Stop Current Playing Media")


            contentItem:  Image {
                source: "/icon/stop.svg"

            }
            onClicked: {
                focus = false
                stop()
            }
        }

        ToolButton {
            implicitHeight: 40
            implicitWidth: 40

            hoverEnabled: true
            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.visible: hovered
            ToolTip.text: qsTr("Change to Repeat, Repeat One or Shuffle")

            contentItem: Image {
                source: {
                    if(plstState === "one")
                        "/icon/repeat.svg"
                    else if(plstState ===  "two")
                        "/icon/repeat_one.svg"
                    else if(plstState === "three")
                        "/icon/shuffle.svg"
                }

            }
            onClicked: {
                focus = false
                plstChanged()
            }
        }

        ToolButton {
            implicitHeight: 40
            implicitWidth: 40

            hoverEnabled: true
            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.visible: hovered
            ToolTip.text: qsTr("Play Next Media File")

            contentItem:  Image {
                source: "/icon/skip_next.svg"

            }
            onClicked: {
                focus = false
                skipNext()
            }
        }

    }


    // Window Buttons
    Row {
        Layout.alignment: Qt.AlignLeft

        ToolButton {
            implicitHeight: 40
            implicitWidth: 60

            hoverEnabled: true
            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.visible: hovered
            ToolTip.text: qsTr("Change Playback Speed")

            contentItem: Label {
                text: plbSpeed
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                width: root.width
                wrapMode: Text.Wrap
                color: "white"

                font.bold: true
                font.pixelSize: 18
                anchors.fill: parent
            }
            onClicked: {
                focus = false
                plbsChanged()
            }
        }
    }

    // Window Buttons
    Row {
        Layout.alignment: Qt.AlignLeft


        ToolButton {
            implicitHeight: 40
            implicitWidth: 40

            hoverEnabled: true
            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.visible: hovered
            ToolTip.text: qsTr("Type And Publish New Comment")

            contentItem: Image {
                source: "/icon/comment.svg"

            }
            onClicked: {
                focus = false
                postKSP()
            }
        }
    }

    Row {
        Layout.alignment: Qt.AlignRight

        ToolButton {
            implicitHeight: 40
            implicitWidth: 40

            hoverEnabled: true
            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.visible: hovered
            ToolTip.text: qsTr("Change to Fullscreen or Window Mode")

            contentItem: Image {
                source: winState == "windowed" ?   "/icon/fullscreen.svg" : "/icon/fullscreen_exit.svg"

            }
            onClicked: {
                focus = false
                toggleFullScreen()
            }
        }

        Slider {
            id: volumeSlider
            implicitWidth: 80
            implicitHeight: 40

            hoverEnabled: true
            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.visible: hovered
            ToolTip.text: qsTr("Adjust Volume")

            Layout.alignment: Qt.AlignVCenter
            value: volumeValue/2.0

            onValueChanged: {
                focus = false
                volumeChanged(volumeSlider.value*2.0)
            }
        }
    }
}
