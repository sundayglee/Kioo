import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Window 2.0
import QtAV 1.5
import "Utils.js" as Utils
import QtQuick.Dialogs 1.2
import QtQuick.LocalStorage 2.0
import Qt.labs.settings 1.0

ApplicationWindow {
    id: root
    visible: true
    width: 720
    height: 480
    color: "black"
    title: Utils.fileName(fileName)
   // visibility: Window.FullScreen
   // flags: Qt.Window | Qt.FramelessWindowHint

    property var fileName: ""
    property var db
    property  var version: "Kioo Media Player v1.3 [ALPHA] - August, 2017"

    signal requestFullScreen
    signal requestNormalSize

    function changeSource(url){
        kioo.stop()
        fileName = url
        kioo.play()
    }

    Settings {
        id: appOption

        property alias alSubtitleEnable : subtitleEnable.checked
        property alias alVideoEnable : videoEnable.checked
        property alias alAudioEnable : audioEnable.checked
        property alias alRememberPlaylist : enableHistory.checked
    }

    DropArea {
        anchors.fill: parent
        enabled: true
        onEntered: {
            if (!drag.hasUrls)
                return;
            var subs
            for (var i = 0; i < drag.urls.length; ++i) {
                var s = drag.urls[i].toString()
                if (s.endsWith(".srt") || s.endsWith(".ass") || s.endsWith(".ssa") || s.endsWith(".sub")
                        || s.endsWith(".idx") || s.endsWith(".mpl2") || s.endsWith(".smi") || s.endsWith(".sami")
                        || s.endsWith(".sup") || s.endsWith(".txt"))
                    subs = drag.urls[i]
                else {
                    pModel.append({ fTitle: Utils.fileName(drag.urls[i]), fLink: drag.urls[i]})
                    changeSource(drag.urls[0])
                }
            }
            if (subs) {
                console.log("the subs are:"+subs)
                subtitle.autoLoad = true
                subtitle.file = subs
            } else {
                subtitle.file = ""
            }
        }
    }

    FileDialog {
        id: fileDialog
        title: "Please choose a media file"
        selectMultiple: true

        onAccepted: {
            var subs
            for (var i = 0; i < fileUrls.length; ++i) {
                var s = fileUrls[i].toString()
                if (s.endsWith(".srt") || s.endsWith(".ass") || s.endsWith(".ssa") || s.endsWith(".sub")
                        || s.endsWith(".idx") || s.endsWith(".mpl2") || s.endsWith(".smi") || s.endsWith(".sami")
                        || s.endsWith(".sup") || s.endsWith(".txt"))
                    subs = fileUrls[i]
                else {
                    pModel.append({ fTitle: Utils.fileName(fileUrls[i]), fLink: fileUrls[i] })
                    changeSource(fileUrls[0])
                }
            }
            if (subs) {
                subtitle.autoLoad = true
                subtitle.file = subs
            } else {
                subtitle.file = ""
            }

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

        onDoubleClicked: {
            root.visibility == Window.FullScreen ? root.visibility=Window.Windowed : root.visibility=Window.FullScreen
        }

        onClicked: {
            kioo.playbackState == MediaPlayer.PlayingState ? kioo.pause() : kioo.play()
           // Utils.getFile(Qt.application.arguments)
        }

//        onRightChanged: {
//            sDrawer.visible == true ? sDrawer.close() : sDrawer.open()
//        }

        onWheel: {
            console.log(wheel.angleDelta.y)
            if(wheel.angleDelta.y > 0)
                kioo.volume = Math.min(2, kioo.volume+0.05)
            else if(wheel.angleDelta.y < 0)
                kioo.volume = Math.max(0, kioo.volume-0.05)
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
        height: 24
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

    VideoOutput2 {
        id: vidOut
        opengl: true
        visible: appOption.alVideoEnable
        fillMode: VideoOutput.PreserveAspectFit
        anchors.fill: parent
        source: kioo
        orientation: 0
        //filters: [negate, hflip]

        SubtitleItem {
            id: subtitleItem
            fillMode: vidOut.fillMode
            rotation: -vidOut.orientation
            source: subtitle
            anchors.fill: parent
        }
        Label {
            id: subtitleLabel
            rotation: -vidOut.orientation
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignBottom
          //  font: PlayerConfig.subtitleFont
            style: Text.Normal //PlayerConfig.subtitleOutline ? Text.Outline : Text.Normal
           // styleColor: "white" // PlayerConfig.subtitleOutlineColor
            color: "white"//PlayerConfig.subtitleColor
            opacity: 0.8
            font.pointSize: Math.max(root.width, root.height) / 30

            anchors.fill: parent
            anchors.bottomMargin: 20 //PlayerConfig.subtitleBottomMargin
        }
    }

    MediaPlayer {
        id: kioo
        source: fileName
        muted: !appOption.alAudioEnable
        objectName: "kioo"
        autoPlay: true

        onPositionChanged: {
            slider.setProgress(position/duration)
        }
        onPlaybackStateChanged: {
            if(kioo.playbackState == MediaPlayer.PlayingState)
                osd_left.info("Play")
            else if(kioo.playbackState == MediaPlayer.PausedState)
                osd_left.info("Pause")
        }
        onVolumeChanged: {
            controls.volumeValue = kioo.volume
        }
        onStatusChanged: {
            if(kioo.status == 3) {
                fileName = kioo.source
                root.title = Utils.fileName(fileName)
               // pModel.append({ fTitle: Utils.fileName(fileName), fLink: fileName })
            }
            if(kioo.status == 7) {
                if(pModel.count > 1) {
                    if((pList.currentIndex+1) == pModel.count)
                        pList.currentIndex = 0
                    else
                        pList.currentIndex += 1
                }
            }
        }
    }

    Subtitle {
        id: subtitle
        player: kioo
        enabled: appOption.alSubtitleEnable
        autoLoad: true //PlayerConfig.subtitleAutoLoad
       // engines: "FFmpeg" //PlayerConfig.subtitleEngines
        delay: 0 //PlayerConfig.subtitleDelay
       // fontFile: //PlayerConfig.assFontFile
       // fontFileForced: // PlayerConfig.assFontFileForced
       // fontsDir: //PlayerConfig.assFontsDir

        onContentChanged: { //already enabled
            if (!canRender || !subtitleItem.visible)
                subtitleLabel.text = text
        }

        onEngineChanged: { // assume a engine canRender is only used as a renderer
            subtitleItem.visible = canRender
            subtitleLabel.visible = !canRender
        }
        onEnabledChanged: {
            subtitleItem.visible = enabled
            subtitleLabel.visible = enabled
        }
    }

    footer: ToolBar {
        id: bottombar
        height: 60
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
               Layout.alignment: Qt.AlignCenter
               Layout.topMargin: -8
               Layout.bottomMargin: -8
               Label {
                   text: Utils.milliSecToString(kioo.position)
                   color: "white"
                  // font.pixelSize: 22
                   opacity: 0.8
                   Layout.alignment: Qt.AlignHCenter
               }
               Label {
                   text: " / "
                   color: "white"
                  // font.pixelSize: 22
                   opacity: 0.8
                   Layout.alignment: Qt.AlignHCenter
               }
               Label {
                   text: Utils.milliSecToString(kioo.duration)
                   color: "white"
                   opacity: 0.8
                   Layout.alignment: Qt.AlignHCenter
               }
           }

            CustomControls {
                id: controls
                Layout.topMargin: 0
                Layout.preferredWidth: root.width
                playState: kioo.playbackState == MediaPlayer.PlayingState ? "playing" : "paused"
                winState: root.visibility == Window.FullScreen ? "fullscreen" : "windowed"
                volumeValue: kioo.volume

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
                onOpenSettings: {
                    sDrawer.visible == true ? sDrawer.close() : sDrawer.open()
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
                onVolumeChanged: {
                    kioo.volume = vValue
                }
            }
        }
    }

    Item {
        id: canvas
        anchors.fill: parent
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
                kioo.seek(kioo.position + 5000)
                break
            case Qt.Key_Left:
                kioo.fastSeek = event.isAutoRepeat
                kioo.seek(kioo.position - 5000)
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
        font.pixelSize: 25
        opacity: 0.8
        anchors.top: root.top
        width: root.width
        height: root.height / 2
        elide: Text.ElideRight

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
        height: root.height
        elide: Text.ElideRight

        onTextChanged: {
            osd_timer_left.stop()
            visible = true
            osd_timer_left.start()
        }
        Timer {
            id: osd_timer_left
            interval: 2000
            onTriggered: osd_left.visible = false
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

            onVisibleChanged: {

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
        ScrollView {
            anchors.fill: parent
            ColumnLayout {
                spacing: 20

                Label {
                    text: "Options"
                    font.pixelSize: 30
                    color: "white"
                    background: Rectangle {
                        anchors.fill: parent
                        color: "#795548"
                    }

                    opacity: 0.9
                    padding: 4
                   // horizontalAlignment: Qt.AlignHCenter
                    Layout.preferredWidth: sDrawer.width
                }

                Label {
                    Layout.topMargin: -16
                    leftPadding: 2
                    text: "Audio"
                    font.pixelSize: 25
                    color: "white"
                    opacity: 0.8
                }

                RowLayout {
                    Layout.topMargin: -16
                    Layout.leftMargin: 4

                    Label {
                        Layout.alignment: Qt.AlignLeft
                        Layout.preferredWidth: sDrawer.width/2
                        text: "Enable Audio "
                        font.pixelSize: 16
                        color: "white"
                        opacity: 0.8
                    }

                    Switch {
                        id: audioEnable
                        checked: true
                    }
                }

                RowLayout {
                    Layout.topMargin: -16
                    Layout.leftMargin: 4

                    Label {
                        text: "Audio Track"
                        font.pixelSize: 16
                        color: "white"
                        opacity: 0.8
                    }

                    CustomCombo {
                        Layout.leftMargin: sDrawer.width/3.5
                        Layout.preferredHeight: 30
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


                ColumnLayout {
                    width: parent.width
                    Label {
                        leftPadding: 2
                        text: "Video"
                        font.pixelSize: 25
                        color: "white"
                        opacity: 0.8
                    }

                    RowLayout {
                        Layout.topMargin: -16
                        Layout.leftMargin: 4

                        Label {
                            Layout.alignment: Qt.AlignLeft
                            Layout.preferredWidth: sDrawer.width/2
                            text: "Enable Video "
                            font.pixelSize: 16
                            color: "white"
                            opacity: 0.8
                        }

                        Switch {
                            id: videoEnable
                            checked: true
                        }
                    }
                }

                ColumnLayout {
                    Label {
                        leftPadding: 2
                        bottomPadding: 2
                        text: "Subtitle"
                        font.pixelSize: 25
                        color: "white"
                        opacity: 0.8
                    }

                    RowLayout {
                        Layout.topMargin: -16
                        Layout.leftMargin: 4

                        Label {
                            text: "Enable Subtitles "
                            Layout.preferredWidth: sDrawer.width/2
                            font.pixelSize: 16
                            color: "white"
                            opacity: 0.8
                        }
                        Switch {
                            id: subtitleEnable
                            checked: true
                        }
                    }
                }

                ColumnLayout {
                    Label {
                        leftPadding: 2
                        text: "Playlist"
                        font.pixelSize: 25
                        color: "white"
                        opacity: 0.8
                    }

                    RowLayout {
                        Layout.topMargin: -16
                        Layout.leftMargin: 4

                        Label {
                            text: "Enable History  "
                            Layout.preferredWidth: sDrawer.width/2
                            font.pixelSize: 16
                            color: "white"
                            opacity: 0.8
                        }
                        Switch {
                            id: enableHistory
                            checked: true
                        }
                    }
                }
                Label {
                    id: myVersion
                    anchors.bottom: parent.Bottom
                    padding: 2
                    leftPadding: 4
                    text: version
                    color: "white"
                    opacity: 0.8
                }
            }
        }
    }

    Component.onCompleted: {
       // pModel.append({ fTitle: Utils.fileName(fileName), fLink: fileName })
        initDatabase()

        if(enableHistory.checked)
            readData()

        var opt = kioo.videoCodecOptions
     //   if (value) {
     //       opt["copyMode"] = "ZeroCopy"
     //   } else {
     //       if (Qt.platform.os == "osx")
    //            opt["copyMode"] = "LazyCopy"
      //      else
                opt["copyMode"] = "ZeroCopy"
      //  }
        kioo.videoCodecOptions = opt
        Utils.getFile(Qt.application.arguments);
    }
    Component.onDestruction: {
        if(enableHistory.checked)
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
        if(!db) { return; }
        db.transaction( function(tx) {
            var result = tx.executeSql('SELECT * from data where name = "playlist"');
            // prepare object to be stored as JSON
            var ldata =[];
            var obj = {};

            print('the data is sssssssssss'+ pModel.rowCount())
            for(var i = 0; i < pModel.rowCount(); i++){
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
