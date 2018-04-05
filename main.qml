import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Window 2.3
import QtQuick.Layouts 1.3
import QtQuick.LocalStorage 2.0
import Qt.labs.settings 1.0
import QtQuick.Dialogs 1.2
import QtAV 1.7
import "Utils.js" as Utils
import QtWinExtras 1.0 // Thumbnail For Windows

ApplicationWindow {
    id: root
    visible: true
    width: Utils.scale(720)
    height: Utils.scale(480)
    color: "black"
    title: Utils.fileName(fileName)
    // visibility: Window.FullScreen
    // flags: Qt.Window | Qt.FramelessWindowHint

    property var fileName: ""
    property var db : ""
    property  var version: "Kioo v1.12 - (http://www.kiooplayer.com)"

    signal requestFullScreen
    signal requestNormalSize

    function changeSource(url){
        kioo.stop()
        fileName = url
        kioo.play()
    }

    function fnSkipNext() {
        if(pModel.count > 1) {
            if(controls.plstState === "three" ) {
                var curIndex = Math.floor((Math.random()*pModel.count+1)-1);
                pList.currentIndex = curIndex;
                changeSource(pModel.get(curIndex).fLink)
            } else if(controls.plstState === "two") {
                changeSource(pModel.get(pList.currentIndex).flink)
            }
            else {
                if((pList.currentIndex+1) == pModel.count)
                    pList.currentIndex = 0
                else
                    pList.currentIndex += 1
            }
        }
        else {
            changeSource(pModel.get(pList.currentIndex).flink)
        }
    }

    function fnSkipPrevious() {
        if(pModel.count > 1) {
            if(controls.plstState === "three" ) {
                var curIndex = Math.floor((Math.random()*pModel.count+1)-1);
                pList.currentIndex = curIndex;
                changeSource(pModel.get(curIndex).fLink)
            } else if(controls.plstState === "two") {
                changeSource(pModel.get(pList.currentIndex).flink)
            }
            else {
                if(pList.currentIndex <= 0)
                    pList.currentIndex = pModel.count-1
                else
                    pList.currentIndex -= 1
            }
        }
        else {
            changeSource(pModel.get(pList.currentIndex).flink)
        }
    }

//    Rectangle {
//        id: sOverlay
//        height: parent.height
//        width: parent.width
//        z: 1
//        anchors.centerIn: vidOut
//        color: "teal"
//        opacity: 50
//    }

//    ToolBar {
//        id: sHeader

//        z: 1
//        width: parent.width
//        parent: window.overlay

//        Label {
//            id: label
//            anchors.centerIn: parent
//            text: "Qt Quick Controls 2"
//        }
//    }

    Settings {
        id: appOption

        property alias alSubtitleEnable : subtitleEnable.checked
        property alias alVideoEnable : videoEnable.checked
        property alias alAudioEnable : audioEnable.checked
        property alias alRememberPlaylist : enableHistory.checked
        property alias lastPlayed: pList.currentIndex
        //property alias alRepeatOne: repeatOne
        // property alias alRepeatAll: repeatAll
    }

    Connections {
        target: ipcInterface
        onLinkReceived: {
            Utils.getSingleFile(data);
        }
    }

    DropArea {
        anchors.fill: parent
        enabled: true
        onEntered: {
            var urls = drag.urls;
            var subs;
            for (var i = 0; i < urls.length; i++) {
                var sk = "";
                sk = urls[i];
                console.log(Utils.fileName(sk));
                if (sk.endsWith(".srt") || sk.endsWith(".ass") || sk.endsWith(".ssa") || sk.endsWith(".sub")
                        || sk.endsWith(".idx") || sk.endsWith(".mpl2") || sk.endsWith(".smi") || sk.endsWith(".sami")
                        || sk.endsWith(".sup") || sk.endsWith(".txt"))
                    subs = sk;
                else {
                    pModel.append({ fTitle: Utils.fileName(sk), fLink: sk});
                    changeSource(sk);
                }
            }
            if (subs) {
               // console.log("the subs are:"+subs)
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
            var urls = drag.urls;
            var subs;
            for (var i = 0; i < urls.length; i++) {
                var sk = "";
                sk = urls[i];
                console.log(Utils.fileName(sk));
                if (sk.endsWith(".srt") || sk.endsWith(".ass") || sk.endsWith(".ssa") || sk.endsWith(".sub")
                        || sk.endsWith(".idx") || sk.endsWith(".mpl2") || sk.endsWith(".smi") || sk.endsWith(".sami")
                        || sk.endsWith(".sup") || sk.endsWith(".txt"))
                    subs = sk;
                else {
                    pModel.append({ fTitle: Utils.fileName(sk), fLink: sk});
                    changeSource(sk);
                }
            }
            if (subs) {
               // console.log("the subs are:"+subs)
                subtitle.autoLoad = true
                subtitle.file = subs
            } else {
                subtitle.file = ""
            }
        }
        onRejected: {
           // console.log("Canceled")
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
                topbar.visible = root.visibility === Window.FullScreen ? true : false
                bottombar.visible = true
                mouse1.cursorShape = Qt.ArrowCursor
            }
        }

        onDoubleClicked: {
            root.visibility == Window.FullScreen ? root.visibility=Window.Windowed : root.visibility=Window.FullScreen
        }

        onClicked: {
            kioo.playbackState == MediaPlayer.PlayingState ? kioo.pause() : kioo.play()
            //console.log(Math.max(root.width, root.height) / 30)
        }

        //        onRightChanged: {
        //            sDrawer.visible == true ? sDrawer.close() : sDrawer.open()
        //        }

        onWheel: {
           // console.log(wheel.angleDelta.y)
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
          //  rotation: -vidOut.orientation
            source: subtitle
            anchors.fill: root
            fillMode: VideoOutput.PreserveAspectFit

        }

        Text {
            id: subtitleLabel
        //    rotation: -vidOut.orientation
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignBottom
            width: root.width
            wrapMode: Text.Wrap
            style: Text.Raised
            styleColor: "black"
            color: "white"
            opacity: 0.8
            font.pixelSize: Math.max(root.width, root.height) / 32
            anchors.fill: parent
            anchors.bottomMargin: Math.max(root.width, root.height) / 32
        }
    }

    Subtitle {
        id: subtitle
        player: kioo
        enabled: appOption.alSubtitleEnable
       // autoLoad: true
        delay: 0
        engines: ["FFmpeg"]

        onContentChanged: { //already enabled
            if (!canRender || !subtitleItem.visible)
                subtitleLabel.text = text
        }

        onEngineChanged: { // assume a engine canRender is only used as a renderer
            subtitleItem.visible = canRender
            subtitleLabel.visible = !canRender
        }

        onEnabledChanged: {
            subtitleItem.visible = true
            subtitleLabel.visible = true
        }
        onLoaded: {
            csub.currentIndex = 0;
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
            osd_right.info(kioo.volume.toPrecision(2));
        }
        onStatusChanged: {
            if(kioo.status == 3) {
                fileName = kioo.source
                root.title = Utils.fileName(fileName)
                // pModel.append({ fTitle: Utils.fileName(fileName), fLink: fileName })
            }
            if(kioo.status == 7) {
                if(pModel.count > 1) {
                    if(controls.plstState === "three" ) {
                        var curIndex = Math.floor((Math.random()*pModel.count+1)-1);
                        pList.currentIndex = curIndex;
                        changeSource(pModel.get(curIndex).fLink)
                    } else if(controls.plstState === "two") {
                        changeSource(pModel.get(pList.currentIndex).flink)
                    }
                    else {
                        if((pList.currentIndex+1) == pModel.count)
                            pList.currentIndex = 0
                        else
                            pList.currentIndex += 1
                    }
                }
                else {
                    changeSource(pModel.get(pList.currentIndex).flink)
                }
            }
        }
    }


    footer: ToolBar {
        id: bottombar
        height: 70
        Keys.forwardTo: canvas

        ColumnLayout{
            spacing: 0
            width: root.width

            CustomSlider {
                id: slider
                Layout.preferredWidth: root.width
                Keys.forwardTo: canvas

                ToolTip {
                    parent: slider.handle
                    visible: slider.pressed
                    text: Utils.milliSecToString(slider.value * kioo.duration)
                    bottomMargin: 0
                }
                onPressedChanged: {
                    focus = true
                    kioo.fastSeek = true
                    kioo.seek(slider.value*kioo.duration)
                    osd_left.info("Seeking")
                    osd_right.info(Utils.milliSecToString(kioo.position)+"/"+Utils.milliSecToString(kioo.duration))
                    focus = false
                }
            }

            RowLayout {
                spacing: 0
                Layout.alignment: Qt.AlignCenter
                Layout.topMargin: -8
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
                plstState: "one"
                Keys.forwardTo: canvas

                onTogglePlayback: {
                    kioo.playbackState === MediaPlayer.PlayingState ? kioo.pause() : kioo.play()
                }
                onToggleFullScreen: {
                    root.visibility === Window.FullScreen ? root.visibility=Window.Windowed : root.visibility=Window.FullScreen
                }
                onStop: {
                    kioo.stop()
                    slider.value = 0;
                }
                onFileOpen: {
                    fileDialog.open()
                }
                onOpenPlaylist: {
                    drawer.visible === true ? drawer.close() : drawer.open()
                }
                onOpenSettings: {
                    sDrawer.visible === true ? sDrawer.close() : sDrawer.open()
                }

                onSkipNext: {
                    fnSkipNext();
                }
                onSkipPrevious: {
                    fnSkipPrevious();
                }
                onVolumeChanged: {
                    kioo.volume = vValue
                }
                onPlstChanged: {
                   // console.log(plstState);
                    if(plstState === "three"){
                        plstState = "one"
                    }
                    else if(plstState === "one"){
                        plstState = "two"
                    }
                    else if(plstState === "two"){
                        plstState = "three"
                    }
                }
            }
        }
    }

    Item {
        id: canvas
        anchors.fill: kioo
        focus: true

      //  Keys.onShortcutOverride: event.accepted = (event.key === Qt.Key_Space)

        Keys.onSpacePressed: kioo.playbackState === MediaPlayer.PlayingState ? kioo.pause() : kioo.play()
        Keys.onPressed: {            
            switch(event.key) {
            case Qt.Key_F:
                root.visibility === Window.FullScreen ? root.visibility=Window.Windowed : root.visibility=Window.FullScreen
                break
            case Qt.Key_Escape:
                root.visibility === Window.FullScreen ? root.visibility=Window.Windowed : root.visibility=Window.FullScreen
                break
            case Qt.Key_P:
                kioo.playbackState === MediaPlayer.PlayingState ? kioo.pause() : kioo.play()
                break
            case Qt.Key_Plus:
                kioo.playbackRate += 0.1
               // console.log("Playback rate is: "+kioo.playbackRate)
                break;
            case Qt.Key_Minus:
                kioo.playbackRate -= 0.1
               // console.log("Playback rate is: "+kioo.playbackRate)
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
                osd_left.info("Seeking")
                osd_right.info(Utils.milliSecToString(kioo.position)+"/"+Utils.milliSecToString(kioo.duration))
                break
            case Qt.Key_Left:
                kioo.fastSeek = event.isAutoRepeat
                kioo.seek(kioo.position - 5000)
                osd_left.info("Seeking")
                osd_right.info(Utils.milliSecToString(kioo.position)+"/"+Utils.milliSecToString(kioo.duration))
                break
            case Qt.Key_R:
                kioo.orientation += 90
               // drawer.open()
                break;
            case Qt.Key_T:
                videoOut.orientation -= 90
                break;
            case Qt.Key_L:
                drawer.visible === true ? drawer.close() : drawer.open()
                break;
            case Qt.Key_S:
                sDrawer.visible === true ? sDrawer.close() : sDrawer.open()
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
                break;
            case Qt.Key_E:
                sOverlay.visible === true ? sOverlay.close() : sOverlay.open()
                break;
            }
        }
    }

    Label {
        id: osd
        z: 10
        objectName: "osd"
        horizontalAlignment: Text.AlignHCenter
        color: "white"
        font.pixelSize: Math.max(root.width, root.height) / 32
        opacity: 0.8
        anchors.top: root.top
        width: root.width
        height: root.height / 2
        elide: Text.ElideRight
        padding: 4

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
            osd.color = "#ffff00"
            text = value
        }
        function info(value) {
            osd.color = "white"
            text = value
        }
    }

    Label {
        id: osd_left
        objectName: "osd"
        horizontalAlignment: Text.AlignLeft
        color: "white"
        font.pixelSize: Math.max(root.width, root.height) / 32
        opacity: 0.8
        anchors.top: root.top
        width: root.width
        height: root.height
        elide: Text.ElideRight
        padding: 4

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
            osd_left.color = "#ffff00"
            opacity = 0.8
            text = value
        }
        function info(value) {
            osd_left.color = "white"
            opacity = 0.8
            text = value
        }
    }

    Label {
        id: osd_right
        horizontalAlignment: Text.AlignRight
        color: "white"
        font.pixelSize: Math.max(root.width, root.height) / 32
        opacity: 0.8
        anchors.top: root.top
        width: root.width
        height: root.height
        elide: Text.ElideRight
        padding: 4

        onTextChanged: {
            osd_timer_right.stop()
            visible = true
            osd_timer_right.start()
        }
        Timer {
            id: osd_timer_right
            interval: 2000
            onTriggered: osd_right.visible = false
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

//    Drawer {
//        id: sOverlay
//        width: root.width
//        height: root.height
//        edge: Qt.TopEdge

//        TabBar {
//            id: bar
//            width: parent.width

//            background: Rectangle {
//                Rectangle {
//                    anchors.fill: parent
//                    color: "#a98274"
//                }
//            }

//            TabButton {
//                text: qsTr("Audio")
//                font.bold: true
//            }
//            TabButton {
//                text: qsTr("Video")
//                font.bold: true
//            }
//            TabButton {
//                text: qsTr("Subtitle")
//                font.bold: true
//            }
//            TabButton {
//                text: qsTr("System")
//                font.bold: true
//            }
//        }

//        StackLayout {
//            width: parent.width
//            currentIndex: bar.currentIndex

//            Item {
//                id: sAudio
//            }
//            Item {
//                id: sVideo
//            }
//            Item {
//                id: sSubtitle
//            }
//            Item {
//                id: sSystem
//            }
//        }
//    }

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

           // focus: true
            //   currentIndex: pSet.lastPlayed
            anchors.fill: parent
            highlightFollowsCurrentItem: true

            header: Rectangle {
                //anchors.fill: parent
                color: "#795548"
                height: 48
                width: parent.width
                RowLayout {
                    anchors.fill: parent
                    spacing: 0
                    Label {
                        Layout.alignment: Qt.AlignLeft
                        text: "Playlist"
                        font.pixelSize: 30
                        color: "white"
                        opacity: 0.9
                        padding: 4
                        // horizontalAlignment: Qt.AlignHCenter
                        width: parent.width
                    }

                    Switch {
                        id: clearPlaylist
                        Layout.alignment: Qt.AlignRight
                        onPressed: {
                            pModel.clear();
                            fileName = "";
                            clearPlaylist.checked = true
                        }
                    }
                }
            }

            onCurrentIndexChanged: {
                // console.log("Value of the current index is"+pList.get(pList.currentIndex).fLink)
                try {
                    changeSource(pModel.get(pList.currentIndex).fLink);
                   // console.log("current index: "+pList.currentIndex)
                }
                catch(err) {   }
            }

            onVisibleChanged: {
                if(kioo.playbackState === MediaPlayer.StoppedState) {
                    currentIndex = appOption.lastPlayed;
                }
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

            Settings {
                id: pSet
                property alias lastPlayed: pList.currentIndex
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
                        Layout.preferredWidth: sDrawer.width/2
                        text: "Audio Channel"
                        font.pixelSize: 16
                        color: "white"
                        opacity: 0.8
                    }

                    CustomCombo {
                        Layout.alignment: Qt.AlignLeft
                        Layout.preferredWidth: sDrawer.width/2.5
                        Layout.preferredHeight: 30
                        textRole: "text"
                        model: ListModel {
                            ListElement { text: "Stereo" }
                            ListElement { text: "Mono"  }
                            ListElement { text: "Left" }
                            ListElement { text: "Right" }
                        }

                        onActivated: {
                            // console.log("item activited successfully"+currentIndex)
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

                RowLayout {
                    Layout.topMargin: -16
                    Layout.leftMargin: 4

                    Label {
                        Layout.alignment: Qt.AlignLeft
                        Layout.preferredWidth: sDrawer.width/2
                        text: "Audio Track"
                        font.pixelSize: 16
                        color: "white"
                        opacity: 0.8
                    }

                    CustomCombo {
                        id: caudio
                        Layout.alignment: Qt.AlignLeft
                        Layout.preferredWidth: sDrawer.width/2.5
                        Layout.preferredHeight: 30
                        currentIndex: 0
                        model: ListModel {
                            id: aTrackModel
                        }

                        onActivated: {
                            kioo.audioTrack = currentIndex;
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

                    RowLayout {
                        Layout.topMargin: -16
                        Layout.leftMargin: 4

                        Label {
                            Layout.preferredWidth: sDrawer.width/2
                            text: "Subtitle Track"
                            font.pixelSize: 16
                            color: "white"
                            opacity: 0.8
                        }

                        CustomCombo {
                            id: csub
                            Layout.alignment: Qt.AlignLeft
                            Layout.preferredWidth: sDrawer.width/2.5
                            Layout.preferredHeight: 30
                            currentIndex: index
                            textRole: "title"
                            delegate: ItemDelegate {
                                width: csub.width
                                contentItem: Text {
                                    text: title
                                    color: "white"
                                    opacity: 0.8
                                    font: csub.font
                                    elide: Text.ElideRight
                                    verticalAlignment: Text.AlignVCenter
                                }
                                highlighted: csub.highlightedIndex === index
                            }
                            model: ListModel {
                                id: sTrackModel
                            }

                            onActivated: {
                                if(sTrackModel.get(currentIndex).link.includes("internal")) {
                                    kioo.internalSubtitleTrack = currentIndex
                                    subtitle.file = ""
                                }

                                for(var k=0; k < sTrackModel.count; k++ ) {
                                    if(sTrackModel.get(k).title.includes(currentText)) {
                                        currentIndex = k
                                    }
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.topMargin: 0
                        Layout.leftMargin: 2

                        Label {
                            Layout.preferredWidth: sDrawer.width/2
                            text: "Opensubtitles:"
                            font.pixelSize: 16
                            color: "white"
                            opacity: 0.8
                        }

                        ToolButton {
                            id: subSearchBtn
                            Layout.preferredHeight: 30

                            contentItem: Text {
                                text: qsTr("SEARCH")
                                font.pointSize: 10
                                color: "white"
                                opacity: 0.8
                            }
                            background: Rectangle {
                                anchors.fill: parent
                                // color: "#795548"
                                opacity: enabled ? 1 : 0.3
                                color: Qt.darker("#795548", subSearchBtn.enabled && (subSearchBtn.checked || subSearchBtn.highlighted) ? 1.5 : 1.0)
                                visible: subSearchBtn.down || (subSearchBtn.enabled && (subSearchBtn.checked || subSearchBtn.highlighted))
                            }

                            onClicked: {
                                if((kioo.playbackState === MediaPlayer.PlayingState) || (kioo.playbackState === MediaPlayer.PausedState)) {
                                    addon.sourceUrl = kioo.source
                                    request('https://rest.opensubtitles.org/search/moviebytesize-'+kioo.metaData.size+'/moviehash-'+addon.sourceUrl+'/sublanguageid-eng', function (v) {
                                        try {
                                            var resObj = JSON.parse(v.responseText);
                                            if(resObj.length > 0) {
                                                for (var i=0;i < resObj.length; i++) {
                                                    subOssModel.append({ fTitle: resObj[i].SubFileName, fLink: resObj[i].SubDownloadLink});
                                                }
                                                subList.currentIndex = 0;
                                                addon.subFile = subOssModel.get(subList.currentIndex).fLink+"|"+subOssModel.get(subList.currentIndex).fTitle+"|"+kioo.source;
                                            }
                                            else {
                                                osd.info('Subtitle Not Found');
                                            }
                                        }
                                        catch(e) {
                                           // console.log('Search not working');
                                            osd.error('Subtitle Search Not Working');
                                        }
                                    });

                                }
                                else {
                                    osd.error("No Media Loaded");
                                   // console.log("No media is loaded");
                                }
                            }
                            function request(url, callback) {
                                var xhr = new XMLHttpRequest();
                                xhr.onreadystatechange = (function(res) {
                                    return function() {
                                       if(xhr.readyState == 4 && xhr.status == 200) {
                                            callback(res);
                                        }
                                    }
                                })(xhr);
                                xhr.open('GET', url, true);
                                xhr.setRequestHeader('X-Dummy', 'Dummy-Header\r\nUser-Agent: Kioo Media v1.0');
                                xhr.send('');
                            }
                        }
                        ToolButton {
                            Layout.preferredHeight: 30
                            id: subDownBtn

                            contentItem: Text {
                                text: qsTr("LOAD")
                                font.pointSize: 10
                                color: "white"
                                opacity: 0.8
                            }
                            background: Rectangle {
                                anchors.fill: parent
                                // color: "#795548"
                                opacity: enabled ? 1 : 0.3
                                color: Qt.darker("#795548", subDownBtn.enabled && (subDownBtn.checked || subDownBtn.highlighted) ? 1.5 : 1.0)
                                visible: subDownBtn.down || (subDownBtn.enabled && (subDownBtn.checked || subDownBtn.highlighted))
                            }
                            onClicked: {
                                addon.subFile = subOssModel.get(subList.currentIndex).fLink+"|"+subOssModel.get(subList.currentIndex).fTitle+"|"+kioo.source;
                            }

                            Connections {
                                target: addon
                                onSubFileChanged: {
                                    console.log("changedasdfafsfasfsdfsd")
                                    subtitle.file = addon.subFile;
                                    sTrackModel.append({title: "External Sub", link: subtitle.file })
                                    sDrawer.close();
                                    osd.info("Subtitle Loaded");
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.topMargin: 0
                        Layout.leftMargin: 2

                        CustomCombo {
                            id: subLang
                            Layout.preferredWidth: sDrawer.width/4
                            Layout.preferredHeight: 30
                            textRole: "name"

                            // model: ["English","French","Spanish"]
                            model: ListModel {
                                id: subLangList
                                ListElement {
                                    name: "English"
                                    value: "eng"
                                }
                                ListElement {
                                    name: "French"
                                    value: "fre"
                                }
                                ListElement {
                                    name: "Spanish"
                                    value: "spa"
                                }
                            }
                            delegate: ItemDelegate {
                                width: subLang.width
                                contentItem: Text {
                                    text: name
                                    color: "white"
                                    opacity: 0.8
                                    font: subLang.font
                                    elide: Text.ElideRight
                                    verticalAlignment: Text.AlignVCenter
                                }
                                highlighted: subLang.highlightedIndex === index
                            }

                            onAccepted: {
                                if (find(editText) === -1)
                                    model.append({text: editText})
                            }
                        }

                        CustomCombo {
                            id: subList
                            Layout.preferredWidth: sDrawer.width/1.5
                            Layout.preferredHeight: 30
                            currentIndex: index
                            textRole: "fTitle"
                            model: ListModel {
                                id: subOssModel
                                //  ListElement { title: ""; source: "" }
                            }
                            delegate: ItemDelegate {
                                width: subList.width
                                contentItem: Text {
                                    text: fTitle
                                    color: "white"
                                    opacity: 0.8
                                    font: subList.font
                                    elide: Text.ElideRight
                                    verticalAlignment: Text.AlignVCenter
                                }
                                highlighted: subList.highlightedIndex === index
                            }                            

                            onActivated: {
                               // console.log("Current index is: "+index);
                            }
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

                ColumnLayout {
                    Label {
                        leftPadding: 2
                        text: "About"
                        font.pixelSize: 25
                        color: "white"
                        opacity: 0.8
                    }

                    RowLayout {
                        Layout.topMargin: 0
                        Layout.leftMargin: 0

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
        }
        onVisibleChanged: {
            var ai = caudio.currentIndex            
            var si = csub.currentIndex
            aTrackModel.clear();
            sTrackModel.clear();
           // sTrackModel.append({title: "--Subtitle tracks---"})
            for(var i=0; i < kioo.internalAudioTracks.length; i++){
                var a = kioo.internalAudioTracks[i].id +" - "+kioo.internalAudioTracks[i].codec +" ("+kioo.internalAudioTracks[i].language+")";
                aTrackModel.append({title: a})               
            }

            var v = 0;

            for(var j=0; j < kioo.internalSubtitleTracks.length; j++){
                var b = kioo.internalSubtitleTracks[j].id +" - "+kioo.internalSubtitleTracks[j].codec +" ("+kioo.internalSubtitleTracks[j].language+")";
                sTrackModel.append({title: b, link: "internal"})
                v = j;
            }

            if(subtitle.file !== "") {
                sTrackModel.append({title: j+ " - external subs", link: subtitle.file })

                for(var k=0; k < sTrackModel.count; k++ ) {
                    if(sTrackModel.get(k).title.includes("external")) {
                       csub.currentIndex = k;
                    }
                }
            }

            else {
                csub.currentIndex = kioo.internalSubtitleTrack;
            }

          //  sTrackModel.append({title: "External Sub", link: subs.file })

            caudio.currentIndex = ai;
          //  csub.currentIndex = si;
        }
    }

    Component.onCompleted: {
        // pModel.append({ fTitle: Utils.fileName(fileName), fLink: fileName })
        initDatabase()

        if(enableHistory.checked)
            readData()
        else {
            cleanData()
            initDatabase()
        }

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
        else
            pModel.clear()
    }

    function initDatabase() {
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

            for(var i = 0; i < pModel.rowCount(); i++){
                ldata.push({
                               "fileName" : pModel.get(i).fTitle,
                               "fileUrl" : pModel.get(i).fLink
                           });
            }
            obj.ldata = ldata;

            if(result.rows.length === 1) {// use update
                //  print('... playlist exists, update it')
                result = tx.executeSql('UPDATE data set value=? where name="playlist"', [JSON.stringify(obj)]);
            } else { // use insert
                //  print('... playlist does not exists, create it')
                result = tx.executeSql('INSERT INTO data VALUES (?,?)', ['playlist', JSON.stringify(obj)]);
            }
        });

    }

    function readData() {
        // print('readData()')
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
                    //  console.log(obj.ldata[0].fileUrl)
                    pModel.append({ fTitle: obj.ldata[i].fileName, fLink: obj.ldata[i].fileUrl})
                }
            }
        });
    }

    function cleanData() {
        db = LocalStorage.openDatabaseSync("Kioo", "1.0", "Kioo Media", 1000000);
        db.transaction( function(tx) {
            tx.executeSql('DROP TABLE IF EXISTS data');
        });
    }

    ThumbnailToolBar {
        ThumbnailToolButton {
            iconSource: "/icon/skip_previous.svg";
            tooltip: kioo.playbackState == MediaPlayer.PlayingState ? "Pause" : "Play";
            onClicked: fnSkipPrevious();
        }
        ThumbnailToolButton {
            iconSource: kioo.playbackState == MediaPlayer.PlayingState ? "/icon/pause.svg" : "/icon/play.svg";
            tooltip: kioo.playbackState == MediaPlayer.PlayingState ? "Pause" : "Play";
            onClicked: kioo.playbackState == MediaPlayer.PlayingState ? kioo.pause() : kioo.play()
        }
        ThumbnailToolButton {
            iconSource: "/icon/skip_next.svg";
            tooltip: kioo.playbackState == MediaPlayer.PlayingState ? "Pause" : "Play";
            onClicked: fnSkipNext();
        }
       // ThumbnailToolButton { interactive: false; flat: true }
    }
}
