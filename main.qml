import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Window 2.0
import QtAV 1.5
import "Utils.js" as Utils
import QtQuick.Dialogs 1.2
import QtQuick.LocalStorage 2.0

ApplicationWindow {
    id: root
    visible: true
    width: 720
    height: 480
    color: "black"
    title: Utils.fileName(fileName)
   // visibility: Window.FullScreen
   // flags: Qt.Window | Qt.FramelessWindowHint

    property string fileName: "C:/Qt/sample.avi" // "file:///home/sglee/Downloads/114090.mp4"
    property var db

    signal requestFullScreen
    signal requestNormalSize

    function changeSource(url){
        kioo.stop()
        fileName = url
        kioo.play()
    }

    DropArea {
        anchors.fill: parent
        enabled: true
        onEntered: {
            if (!drag.hasUrls)
                return;
            console.log(drag.urls[0])
          //  fileName = drag.urls[0]
            changeSource(drag.urls[0])
            pModel.append({ fTitle: Utils.fileName(fileName), fLink: fileName})
        }
    }

    FileDialog {
        id: fileDialog
        title: "Please choose a media file"
        onAccepted: {
            console.log("You chose: " + fileDialog.fileUrls)
            changeSource(fileDialog.fileUrls[0])
            pModel.append({ fTitle: Utils.fileName(fileName), fLink: fileName})
        }
        onRejected: {
            console.log("Canceled")
        }
    }

    MouseArea {
        id: mouse1
        anchors.fill: parent
        hoverEnabled: true

        onPositionChanged: {
            // console.log("mouse is moving.....")
            if(topbar.visible){
                timer1.start()
                timer2.start()
            }
            else if(timer1.running || timer2.running) {
                // console.log("stopping all timers")
                timer2.stop()
            }
            else if(!(topbar.visible && timer1.running)) {
               // topbar.visible = true
                topbar.visible = root.visibility == Window.FullScreen ? true : false
                bottombar.visible = true
                mouse1.cursorShape = Qt.ArrowCursor
            }
        }
    }    

    Timer {
        id: timer1
        interval: 6000
        onTriggered: {
           // console.log("timer1 still runnign")
            mouse1.cursorShape = Qt.BlankCursor
        }
    }

    Timer {
        id: timer2
        interval: 5000
        onTriggered: {
          //  console.log("timer2 still running")
            topbar.visible = false
            bottombar.visible = false
        }
    }

    header: ToolBar {
        id: topbar
        height: 26
        visible: root.visibility == Window.FullScreen ? true : false

        RowLayout {
            anchors.fill: parent
            Label {
                id: tLabel
                text: Utils.fileName(fileName)
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
                color: "white"
                opacity: 0.8
            }
        }
    }

    Video {
        id: kioo
        anchors.fill: parent
        source: fileName
        onPositionChanged: {
            slider.setProgress(position/duration)
        }
        onPlaybackStateChanged: {
            if(kioo.playbackState == MediaPlayer.PlayingState)
                osd.info("Playing")
            else if(kioo.playbackState == MediaPlayer.PausedState)
                osd.info("Paused")
            console.log("The audio tracks are:"+kioo.metaData.channelCount)
        }

    }

    footer: ToolBar {
        id: bottombar

        Keys.forwardTo: canvas

        ColumnLayout{
            spacing: 0
            width: root.width

            CustomSlider {
                id: slider
                Layout.preferredWidth: root.width

                ToolTip {
                    parent: slider.handle
                    visible: slider.pressed
                    text: Utils.milliSecToString(slider.value * kioo.duration)
                    bottomMargin: 0
                }
                onPressedChanged: {
                   kioo.seek(slider.value*kioo.duration)
                }
            }

           RowLayout {
               spacing: 0
               Layout.topMargin: -8
               Layout.preferredWidth: root.width
               Label {
                   text: Utils.milliSecToString(kioo.position)
                   color: "white"
                   opacity: 0.8
                   Layout.alignment: Qt.AlignLeft
               }
               Label {
                   text: Utils.milliSecToString(kioo.duration)
                   color: "white"
                   opacity: 0.8
                   Layout.alignment: Qt.AlignRight
               }
           }

            MyControls {
                id: controls
                Layout.topMargin: -8
                Layout.preferredWidth: root.width
                playState: kioo.playbackState == MediaPlayer.PlayingState ? "playing" : "paused"
                winState: root.visibility == Window.FullScreen ? "fullscreen" : "windowed"

                onTogglePlayback: {
                    kioo.playbackState == MediaPlayer.PlayingState ? kioo.pause() : kioo.play()
                }
                onToggleFullScreen: {
                    root.visibility == Window.FullScreen ? root.visibility=Window.Windowed : root.visibility=Window.FullScreen
                }
                onStop: {
                    kioo.stop()
                }
                onFileOpen: {
                    fileDialog.open()
                }
                onOpenPlaylist: {
                    drawer.visible == true ? drawer.close() : drawer.open()
                }
                onSkipNext: {
                    console.log(pModel.count+"  "+pList.currentIndex)
                    if(pModel.count > 1) {
                        if((pList.currentIndex+1) == pModel.count)
                            pList.currentIndex = 0
                        else
                            pList.currentIndex += 1
                    }
                }
                onSkipPrevious: {
                    console.log(pModel.count+"  "+pList.currentIndex)
                    if(pModel.count > 1) {
                        if(pList.currentIndex <= 0)
                            pList.currentIndex = pModel.count-1
                        else
                            pList.currentIndex -= 1
                    }
                }
            }
        }
    }

    Item {
        id: canvas
        anchors.fill: root
        focus: true

        Keys.onShortcutOverride: event.accepted = (event.key === Qt.Key_Space)

        Keys.onSpacePressed: kioo.playbackState == MediaPlayer.PlayingState ? kioo.pause() : kioo.play()
        Keys.onPressed: {
            console.log("a key was pressed")
            switch(event.key) {
            case Qt.Key_F:
                root.visibility == Window.FullScreen ? root.visibility=Window.Windowed : root.visibility=Window.FullScreen
                break
            case Qt.Key_Escape:
                root.visibility == Window.FullScreen ? root.visibility=Window.Windowed : root.visibility=Window.FullScreen
                break
            case Qt.Key_P:
                kioo.playbackState == MediaPlayer.PlayingState ? kioo.pause() : kioo.play()
                break
            case Qt.Key_Plus:
                kioo.playbackRate += 0.1
                console.log("Playback rate is: "+kioo.playbackRate)
                break;
            case Qt.Key_Minus:
                kioo.playbackRate -= 0.1
                console.log("Playback rate is: "+kioo.playbackRate)
                break;
            case Qt.Key_Up:
                kioo.volume = Math.min(2, kioo.volume+0.05)
                break
            case Qt.Key_Down:
                kioo.volume = Math.max(0, kioo.volume-0.05)
                break
            case Qt.Key_M:
                kioo.mute = !kioo.mute
                break
            case Qt.Key_Right:
                kioo.fastSeek = event.isAutoRepeat
                kioo.seek(kioo.position + 10000)
                break
            case Qt.Key_Left:
                kioo.fastSeek = event.isAutoRepeat
                kioo.seek(kioo.position - 10000)
                break
            case Qt.Key_R:
                kioo.orientation += 90
                drawer.open()
                break;
            case Qt.Key_T:
                videoOut.orientation -= 90
                break;
            case Qt.Key_L:
                drawer.visible == true ? drawer.close() : drawer.open()
                break;
            case Qt.Key_S:
                sDrawer.visible == true ? sDrawer.close() : sDrawer.open()
                break;
            case Qt.Key_C:
                kioo.videoCapture.capture()
                osd.info()
                break
            case Qt.Key_A:
                if (kioo.fillMode === VideoOutput.Stretch) {
                    kioo.fillMode = VideoOutput.PreserveAspectFit
                } else if (kioo.fillMode === VideoOutput.PreserveAspectFit) {
                    kioo.fillMode = VideoOutput.PreserveAspectCrop
                } else {
                    kioo.fillMode = VideoOutput.Stretch
                }
                break
            case Qt.Key_O:
                fileDialog.open()
                break;
            case Qt.Key_N:
                kioo.stepForward()
                break
            case Qt.Key_B:
                kioo.stepBackward()
                break;
            case Qt.Key_Q:
                Qt.quit()
                break

            }
        }
    }

    Label {
        id: osd
        objectName: "osd"
        horizontalAlignment: Text.AlignHCenter
        color: "white"
        font.pixelSize: 30
        opacity: 0.8
        anchors.top: root.top
        width: root.width
        height: root.height / 2

        onTextChanged: {
            osd_timer.stop()
            visible = true
            osd_timer.start()
        }
        Timer {
            id: osd_timer
            interval: 2000
            onTriggered: osd.visible = false
        }
        function error(value) {
            styleColor = "red"
            text = value
        }
        function info(value) {
            styleColor = "brown"
            text = value
        }
    }

    Label {
        id: osd_left
        objectName: "osd"
        horizontalAlignment: Text.AlignLeft
        color: "white"
        font.pixelSize: 30
        opacity: 0.8
        anchors.top: root.top
        width: root.width
        height: root.height / 2

        onTextChanged: {
            osd_timer_left.stop()
            visible = true
            osd_timer_left.start()
        }
        Timer {
            id: osd_timer_left
            interval: 2000
            onTriggered: osd.visible = false
        }
        function error(value) {
            color = "brown"
            opacity = 0.8
            text = value
        }
        function info(value) {
            color = "white"
            opacity = 0.8
            text = value
        }
    }

    Drawer {
        id: drawer
        width: Math.max(root.width, root.height) / 3 * 2
        height: root.height
        edge: Qt.RightEdge

        //interactive: stackView.depth === 1
        background: Rectangle {
            Rectangle {
                anchors.fill: parent
                color: "#a98274"
            }
        }

        ListView {
            id: pList

            focus: true
            currentIndex: -1
            anchors.fill: parent
            highlightFollowsCurrentItem: true

            header: Label {
                text: "Playlist"
                font.pixelSize: 30
                color: "white"
                background: Rectangle {
                    anchors.fill: parent
                    color: "#795548"
                }

                opacity: 0.9
                padding: 4
               // horizontalAlignment: Qt.AlignHCenter
                width: parent.width
            }
            onCurrentIndexChanged: {
               // console.log("Value of the current index is"+pList.get(pList.currentIndex).fLink)
                changeSource(pModel.get(pList.currentIndex).fLink)
            }

            delegate: ItemDelegate {
                id: pDel
                width: parent.width
                text: model.fTitle
                highlighted: ListView.isCurrentItem
                onClicked: {
                    pList.currentIndex = index
                    changeSource(model.fLink)
                    drawer.close()
                }

                contentItem: RowLayout {
                    Text {
                        anchors.left: parent.left
                        anchors.right: u.left
                        rightPadding: pDel.spacing
                        text: pDel.text
                        font: pDel.font
                        color: "white"
                        opacity: 0.8
                        elide: Text.ElideRight
                        visible: pDel.text
                        Layout.alignment: Qt.AlignLeft
                    }
                    Rectangle {
                        id: u
                        anchors.right: d.left
                        height: 30
                        width: 30
                        color: "transparent"
                        Layout.alignment: Qt.AlignRight

                        ToolButton {
                            anchors.fill: parent
                            contentItem:  Image {
                                source: "/icon/up.svg"
                                opacity: 0.8
                            }
                            onClicked: {
                                pModel.move(index,(index-1),1)
                            }
                        }
                    }
                    Rectangle {
                        id: d
                        anchors.right: r.left
                        height: 30
                        width: 30
                        color: "transparent"
                        Layout.alignment: Qt.AlignRight

                        ToolButton {
                            anchors.fill: parent
                            contentItem:  Image {
                                source: "/icon/down.svg"
                                opacity: 0.8
                            }
                            onClicked: {
                                pModel.move(index,(index+1),1)
                            }
                        }
                    }
                    Rectangle {
                        id: r
                        anchors.right: parent.right
                        height: 30
                        width: 30
                        color: "transparent"
                        Layout.alignment: Qt.AlignRight

                        ToolButton {
                            anchors.fill: parent
                            contentItem:  Image {
                                source: "/icon/close.svg"
                                opacity: 0.8
                            }
                            onClicked: {
                                pModel.remove(index)
                            }
                        }
                    }
                }
            }

            model: ListModel {
                id: pModel
              //  ListElement { title: ""; source: "" }
            }
            ScrollIndicator.vertical: ScrollIndicator { }
        }        
    }

    Drawer {
        id: sDrawer
        width: Math.max(root.width, root.height) / 3 * 1.5
        height: root.height
        edge: Qt.LeftEdge

        //interactive: stackView.depth === 1
        background: Rectangle {
            Rectangle {
                anchors.fill: parent
                color: "#a98274"
            }
        }

        ColumnLayout {
            Label {
                leftPadding: 2
                text: "Audio"
                font.pixelSize: 25
                font.bold: true
                color: "white"
                opacity: 0.8
            }

            Label {
                leftPadding: 2
                text: "Audio Device"
                font.pixelSize: 16
                color: "white"
                opacity: 0.8
            }

            RowLayout {
                Label {
                    text: "Audio Track"
                    font.pixelSize: 16
                    color: "white"
                    opacity: 0.8
                }

                CustomCombo {
                    Layout.leftMargin: sDrawer.width/3.5
                    textRole: "text"
                    model: ListModel {
                        id: aTrackModel
                        ListElement { text: "Stereo" }
                        ListElement { text: "Mono"  }
                        ListElement { text: "Left" }
                        ListElement { text: "Right" }
                    }

                    onAccepted: {
                        console.log("track changed")
                    }
                    onActivated: {
                        console.log("item activited successfully"+currentIndex)
                        if(currentIndex == 0)
                            kioo.channelLayout = MediaPlayer.Stereo
                        else if(currentIndex == 1)
                            kioo.channelLayout = MediaPlayer.Mono
                        else if(currentIndex == 2)
                            kioo.channelLayout = MediaPlayer.Left
                        else if(currentIndex == 3)
                            kioo.channelLayout = MediaPlayer.Right
                    }
                }
            }

            Label {
                leftPadding: 2
                text: "Video"
                font.pixelSize: 25
                font.bold: true
                color: "white"
                opacity: 0.8
            }

            Label {
                leftPadding: 2
                text: "Subtitle"
                font.pixelSize: 25
                font.bold: true
                color: "white"
            }
        }
        ScrollIndicator.vertical: ScrollIndicator { }
    }

    Component.onCompleted: {
        pModel.append({ fTitle: Utils.fileName(fileName), fLink: fileName })
        initDatabase()
        readData()
    }
    Component.onDestruction: {
        storeData()
    }

    function initDatabase() {
        print('..initializing the database')
        db = LocalStorage.openDatabaseSync("Kioo", "1.0", "Kioo Media", 1000000);
        db.transaction( function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS data(name TEXT, value TEXT)');
        });
    }

    function storeData() {
        print('...attempting to store some data.....')
        if(!db) { return; }
        db.transaction( function(tx) {
            var result = tx.executeSql('SELECT * from data where name = "playlist"');
            // prepare object to be stored as JSON
            var ldata =[];
            var obj = {};

            print('the data is sssssssssss'+ pModel.rowCount())
            for(var i = 1; i < pModel.rowCount(); i++){
                ldata.push({
                       "fileName" : pModel.get(i).fTitle,
                       "fileUrl" : pModel.get(i).fLink
                   });
            }
            obj.ldata = ldata;

            if(result.rows.length === 1) {// use update
                print('... playlist exists, update it')
                result = tx.executeSql('UPDATE data set value=? where name="playlist"', [JSON.stringify(obj)]);
            } else { // use insert
                print('... playlist does not exists, create it')
                result = tx.executeSql('INSERT INTO data VALUES (?,?)', ['playlist', JSON.stringify(obj)]);
            }
        });

    }

    function readData() {
        print('readData()')
        if(!db) { return; }
        db.transaction( function(tx) {
            var result = tx.executeSql('select * from data where name="playlist"');
            if(result.rows.length === 1) {
                // get the value column
                var rdata = result.rows[0].value;
                // convert to JS object
                var obj = JSON.parse(rdata)

                // apply to object
                for(var i in obj.ldata){
                    console.log(obj.ldata[0].fileUrl)
                    pModel.append({ fTitle: obj.ldata[i].fileName, fLink: obj.ldata[i].fileUrl})
                }
            }
        });
    }
}
