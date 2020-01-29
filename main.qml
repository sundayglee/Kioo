/************************************************************************************************
    Kioo Media Player: A Player With Clear Crystal Sound, Extra Sharp Video, with a Beautiful Design.
    Copyright (C) 2017 - 2020 Kioo Media Player <support@kiooplayer.com>.
    Homepage: https://www.kiooplayer.com
    Developer: Godfrey E Laswai <sundayglee@gmail.com>
    All rights reserved.

    Use of this source code is governed by a BSD-3-Clause license that can be
    found in the BSD-LICENSE file or see it here <https://opensource.org/licenses/BSD-3-Clause>.
*************************************************************************************************/

import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Window 2.12
import QtQuick.LocalStorage 2.12
import Qt.labs.settings 1.0
import QtQuick.Dialogs 1.3
import QtAV 1.7
import "Utils.js" as Utils
import QtWinExtras 1.0 // Thumbnail For Windows

ApplicationWindow {
    id: root
    visible: true
    width: Utils.scale(720)
    height: Utils.scale(480)
    color: "#4b2c20"
    title: fileName
    // visibility: Window.FullScreen
    // flags: Qt.Window | Qt.FramelessWindowHint

    property string fileName: ""
    property string fileURL: ""
    property var db : ""
    property  string version: "Kioo v1.17 - (https://www.kiooplayer.com)"
    property alias alSubUrl: subtitle.file

    signal requestFullScreen
    signal requestNormalSize

    function changeSource(url){        
        kioo.stop()
        alSubUrl = "";
        fileURL = url
        fileName = pModel.get(pList.currentIndex).fTitle
        root.title = fileName
        subOssModel.clear();
        kioo.play()

        refreshData()

        ksp.comments = ""
        if(c_view.enabled === true) {

            // Comments related
            ksp.getComments()
            get_comment_timer.start()
            c_scan_timer.restart()
        } else {
            c_scan_timer.stop()
            get_comment_timer.stop()
        }
    }

    function tickComments() {
        if(ksp.comments.comments) {
            var obj = ksp.comments
            var n = slider.width / 2 // This 2 is the width of the tickMark
            var d = kioo.duration / n
            for(var i = 0; i < n; i++) {
                var m = i*d;
                for(var j=0; j < obj.comments.length; j++) {
                    if((m >= (parseInt(obj.comments[j].position) - d/2))  && (m <= (parseInt(obj.comments[j].position) + d/2))) {
                        cRepeater.itemAt(i).opacity = 1;
                     }
                }
            }
        }
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

    Settings {
        id: appOption

        property alias alSubtitleEnable : subtitleEnable.checked
        property alias alVideoEnable : videoEnable.checked
        property alias alAudioEnable : audioEnable.checked
        property alias alRememberPlaylist : enableHistory.checked
        property alias lastPlayed: pList.currentIndex
        property alias subLanguage: subLang.currentIndex
        property alias alEnableKsp: kspEnable.checked
        property alias alApiToken: ksp.apiToken
        property alias alOsdEnable: osdEnable.checked
    }

    Connections {
        target: ipcInterface
        onLinkReceived: {
            Utils.getSingleFile(data);
        }
    }

    Item {
        id: ksp
        property var authStatus: 0
        property string apiToken: "0000"
        property var postStatus: 0
        property var comments: ""
        property var host: "https://kiooplayer.com"

        onAuthStatusChanged: {
            if(authStatus === 3) {
                loginPopup.close()
                commentPopup.open()
            }
        }

        function login() {
            authStatus = 1
            function request(url, callback) {
                var xhr = new XMLHttpRequest();
                xhr.onreadystatechange = (function(res) {
                    return function() {
                       if(xhr.readyState === 4 && xhr.status === 200) {
                            callback(res);
                        } else if(xhr.readyState === 4 && xhr.status === 400) {
                           // console.log('Login failed')
                           ksp.authStatus = 2
                       }
                    }
                })(xhr);
                xhr.open('POST',url, true);
                xhr.setRequestHeader('Content-type' , 'application/x-www-form-urlencoded');
                xhr.send('username='+username.text+'&password='+password.text);
            }

            request(ksp.host+'/users/login-api/', function (v) {
                try {
                    var resObj = JSON.parse(v.responseText);

                    if(resObj.token) {
                        ksp.authStatus = 3
                        ksp.apiToken = resObj.token
                    }  else {
                        ksp.authStatus = 2
                    }
                }
                catch(e) {
                    // console.log('Something went wrong');
                    ksp.authStatus = 2
                }
            });
        }
        function postComment() {
            ksp.postStatus = 1
            addon.sourceUrl = kioo.source
            var movie_name = ""
            if(fileName == version) {
                movie_name = ""
            } else {
                movie_name = fileName
            }

            function request(url, callback) {
                var xhr = new XMLHttpRequest();
                xhr.onreadystatechange = (function(res) {
                    return function() {
                       if(xhr.readyState === 4 && (xhr.status === 200 || xhr.status === 201)) {
                            callback(res);
                        } else if(xhr.readyState === 4 && xhr.status === 400) {
                           // console.log('Post failed')
                           ksp.postStatus = 2
                       }
                    }
                })(xhr);
                xhr.open('POST',url, true);
                xhr.setRequestHeader('Content-type' , 'application/json');
                xhr.setRequestHeader('Authorization' , 'Token '+ksp.apiToken);
                xhr.send(JSON.stringify({"movie": { "movie_name": movie_name, "movie_hash": addon.sourceUrl}, "content": cContent.text, "position": (kioo.position - 2000)}));
            }

            request(ksp.host+'/social/post-comment/', function (v) {
                try {
                    ksp.postStatus = 3
                    commentPopup.close()
                    ksp.getComments()
                    var resObj = JSON.parse(v.responseText);
                    // console.log(JSON.stringify(resObj))
                    cContent.text = ""
                }
                catch(e) {
                    ksp.postStatus = 2
                    // console.log('Something went wrong');
                }
            });
        }

        function getComments() {
            addon.sourceUrl = kioo.source
            function request(url, callback) {
                var xhr = new XMLHttpRequest();
                xhr.onreadystatechange = (function(res) {
                    return function() {
                       if(xhr.readyState === 4 && xhr.status === 200) {
                            callback(res);
                        } else if(xhr.readyState === 4 && xhr.status === 400) {
                           // console.log('400 Error Occured')
                       }
                    }
                })(xhr);
                xhr.open('POST',url, true);
                xhr.setRequestHeader('Content-type' , 'application/json');
                xhr.send(JSON.stringify({'movie_hash': addon.sourceUrl }));
            }

            request(ksp.host+'/social/comments-list/', function (v) {
                try {
                    var resObj = JSON.parse(v.responseText);

                    if(resObj.comments) {
                        ksp.comments = resObj
                        // Show comment Position
                        tickComments()
                    }  else {
                        // console.log('Something went wrong')
                    }
                }
                catch(e) {
                    // console.log('Something went wrong');
                }
            });
        }

        function getVersion() {
            addon.sourceUrl = kioo.source
            function request(url, callback) {
                var xhr = new XMLHttpRequest();
                xhr.onreadystatechange = (function(res) {
                    return function() {
                       if(xhr.readyState === 4 && xhr.status === 200) {
                            callback(res);
                        } else if(xhr.readyState === 4 && xhr.status === 400) {
                           // console.log('400 Error Occured')
                       }
                    }
                })(xhr);
                xhr.open('GET',url, true);
                xhr.setRequestHeader('Content-type' , 'application/json');
                xhr.send('');
            }

            request(ksp.host+'/home/kioo-version/', function (v) {
                try {
                    var resObj = JSON.parse(v.responseText);

                    if(resObj.version !== version) {
                        root.title = 'New Kioo Version Available at Kioo Website (https://kiooplayer.com)';
                        fileName = 'New Kioo Version Available at Kioo Website (https://kiooplayer.com)';
                    }  else {
                        // console.log('Something went wrong')
                    }
                }
                catch(e) {
                    // console.log('Something went wrong');
                }
            });
        }

    }

    DropArea {
        id: dropArea
        anchors.fill: parent
        enabled: true

        onEntered: {
            if(drag.hasUrls) {
                var subArray = [];
                var avArray = [];
                var urlArray = Object.values(drag.urls)
                for(var i in urlArray) {
                    if(urlArray[i].endsWith(".srt") || urlArray[i].endsWith(".ass") || urlArray[i].endsWith(".ssa") || urlArray[i].endsWith(".sub")
                            || urlArray[i].endsWith(".idx") || urlArray[i].endsWith(".mpl2") || urlArray[i].endsWith(".smi") || urlArray[i].endsWith(".sami")
                            || urlArray[i].endsWith(".sup") || urlArray[i].endsWith(".txt")) {
                        subArray.push(urlArray[i])
                    } else if(urlArray[i].endsWith(".jpg") || urlArray[i].endsWith(".png")) {
                        continue;
                    } else {
                        avArray.push(urlArray[i]);
                        pModel.append({ fTitle: Utils.fileName(urlArray[i]), fLink: urlArray[i]});
                    }
                }

                if (avArray.length > 0) {
                    pList.currentIndex = pModel.count - avArray.length;
                }
                if(subArray.length > 0) {
                    alSubUrl = subArray[0]
                }
            }
        }
    }

    FileDialog {
        id: fileDialog
        title: "Please choose a media file"
        selectMultiple: true

        onAccepted: {

            if(fileUrls) {
                var subArray = [];
                var avArray = [];
                var urlArray = Object.values(fileUrls)
                for(var i in urlArray) {
                    if(urlArray[i].endsWith(".srt") || urlArray[i].endsWith(".ass") || urlArray[i].endsWith(".ssa") || urlArray[i].endsWith(".sub")
                            || urlArray[i].endsWith(".idx") || urlArray[i].endsWith(".mpl2") || urlArray[i].endsWith(".smi") || urlArray[i].endsWith(".sami")
                            || urlArray[i].endsWith(".sup") || urlArray[i].endsWith(".txt")) {
                        subArray.push(urlArray[i])
                    } else if(urlArray[i].endsWith(".jpg") || urlArray[i].endsWith(".png")) {
                        continue;
                    } else {
                        avArray.push(urlArray[i]);
                        pModel.append({ fTitle: Utils.fileName(urlArray[i]), fLink: urlArray[i]});
                    }
                }
                if (avArray.length > 0) {
                    pList.currentIndex = pModel.count - avArray.length;
                }
                if(subArray.length > 0) {
                    alSubUrl = subArray[0]
                }
            }
        }
    }

    MouseArea {
        id: mouse1
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onPositionChanged: {
            if(topbar.visible){
                timer1.start()
                timer2.start()
            }
            else if(timer1.running || timer2.running) {
                timer2.stop()
            }
            else if(!(topbar.visible && timer1.running)) {
                topbar.visible = root.visibility === Window.FullScreen ? true : false
                bottombar.visible = true
                mouse1.cursorShape = Qt.ArrowCursor
            }

            // Show comment Position
            tickComments()
        }

        onDoubleClicked: {
            root.visibility == Window.FullScreen ? root.visibility=Window.Windowed : root.visibility=Window.FullScreen
        }        

        onClicked: {
            if (mouse.button === Qt.LeftButton)
                kioo.playbackState == MediaPlayer.PlayingState ? kioo.pause() : kioo.play()
        }

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
                text: fileName
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
                color: "white"

            }
        }
    }

    VideoOutput2 {
        id: vidOut
        opengl: true;
        antialiasing: true;
        visible: appOption.alVideoEnable
        fillMode: VideoOutput.PreserveAspectFit
        anchors.fill: parent
        source: kioo
        orientation: 0
        //filters: [negate, hflip]

        SubtitleItem {
            id: subtitleItem
            rotation: -vidOut.orientation
            source: subtitle
            anchors.fill: parent
            fillMode: VideoOutput.PreserveAspectFit
        }

        Label {
            id: subtitleLabel
            rotation: -vidOut.orientation
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignBottom
            width: root.width
            wrapMode: Text.Wrap
            style: Text.Raised
            styleColor: "black"
            color: "white"

            font.pixelSize: Math.max(root.width, root.height) / 32
            anchors.fill: parent
            anchors.bottomMargin: Math.max(root.width, root.height) / 32
        }
    }

    Subtitle {
        id: subtitle
        player: kioo
        enabled: appOption.alSubtitleEnable
        autoLoad: true
        delay: 0
        engines: ["FFmpeg"]

        onContentChanged: { //already enabled
            subtitleLabel.text = text;
        }

        onEngineChanged: { // assume a engine canRender is only used as a renderer
            subtitleItem.visible = canRender
            subtitleLabel.visible = !canRender
        }

        onEnabledChanged: {
            if(subtitle.enabled) {
                subtitleItem.visible = true
                subtitleLabel.visible = true
            } else {
                subtitleItem.visible = false
                subtitleLabel.visible = false
            }
        }
        onLoaded: {
            csub.currentIndex = 0;
        }
    }

    // This time is important for displaying progress on the ProgressBar
    Timer {
        id: timer3
        interval: 1000
        running: true;
        repeat: true
        onTriggered: {
            slider.setProgress(kioo.position/kioo.duration)
        }
    }

    MediaPlayer {
        id: kioo
        source: fileURL
        muted: !appOption.alAudioEnable
        objectName: "kioo"
        autoPlay: true

        videoCapture {
            autoSave: true
            onSaved: {
                osd.info("Capture Saved At: " + path)
            }
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
        onError: {
            if(error > 0) {
                osd.error('An Error Has Occured. Try Again.')
            }
        }

        onStatusChanged: {
            if(kioo.status == 3) {
                // root.title = fileName
                // pModel.append({ fTitle: Utils.fileName(fileName), fLink: fileName })


            }
            if(kioo.status == 7) {
                if(kioo.playbackState == 1) {
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
    }

    Popup {
        id: urlPopup
        anchors.centerIn: parent
        width: Utils.scale(root.width/2)
        background: Rectangle {
            Rectangle {
                anchors.fill: parent
                color: "#a98274"
            }
        }

        onVisibleChanged: {
            oUrlName.forceActiveFocus()
        }

        ColumnLayout {
            spacing: 4

            Label {
                width: Layout.width
                Layout.alignment: Qt.AlignCenter

                font.bold: true;
                text: "OPEN NETWORK STREAM"
                font.pointSize: 10
                color: "white"
            }

            Label {
                text: "Stream Name: "
                font.pointSize: 10
                font.bold: true
                Layout.preferredWidth: (urlPopup.width) - 16

                color: "white"
            }

            TextField {
                id: oUrlName
                placeholderText: "Stream Name"
                text: "Stream 1"
                color: "white"
                selectByMouse: true
                cursorVisible: true;
                font.pointSize: 10
                Layout.preferredWidth: (urlPopup.width) - 16
                Layout.preferredHeight: 48
                focus: true

                KeyNavigation.down:  oUrlLink

            }

            Label {
                text: "Stream Link: "
                font.pointSize: 10
                font.bold: true
                Layout.preferredWidth: (urlPopup.width) - 16

                color: "white"
            }

            TextField {
                id: oUrlLink
                placeholderText: "https://example.com"
                color: "white"
                selectByMouse: true
                cursorVisible: true;
                font.pointSize: 10
                Layout.preferredWidth: (urlPopup.width) - 16
                Layout.preferredHeight: 48

                KeyNavigation.up:  oUrlName
                KeyNavigation.down:  oUrlBtn
                Keys.onReturnPressed: {
                    pModel.append({ fTitle: oUrlName.text, fLink: oUrlLink.text});
                    pList.currentIndex = pModel.count - 1
                    kioo.stop()
                    changeSource(oUrlLink.text)
                    urlPopup.close();
                }
            }

            Button {
                id: oUrlBtn
                text: "PLAY STREAM"
                font.pointSize: 10
                focus: true

                onClicked: {
                    pModel.append({ fTitle: oUrlName.text, fLink: oUrlLink.text});
                    pList.currentIndex = pModel.count - 1
                    kioo.stop()
                    changeSource(oUrlLink.text)
                    urlPopup.close();
                }

            }

            Label {
                text: "Tip:  Stream anything which can be downloaded as a file or any live stream. Remember, the link must be the URL to the actual file or stream and not otherwise."
                font.pointSize: 10

                Layout.preferredWidth: (urlPopup.width) - 16
                wrapMode: Label.WordWrap
                color: "white"
            }

            // Dummy Item to Fill Remaining Height
            Item { Layout.fillHeight: true }
        }

    }


    footer: ToolBar {
        id: bottombar
        height: 75
        Keys.forwardTo: canvas

        MouseArea {
            id: mouse4
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onPositionChanged: {
                if(topbar.visible){
                    timer1.start()
                    timer2.start()
                }
                else if(timer1.running || timer2.running) {
                    timer2.stop()
                }
                else if(!(topbar.visible && timer1.running)) {
                    topbar.visible = root.visibility === Window.FullScreen ? true : false
                    bottombar.visible = true
                    mouse4.cursorShape = Qt.ArrowCursor
                }

                // Show comment Position
                tickComments()
            }
        }

        ColumnLayout{
            spacing: 0
            width: root.width

            Row {
                Repeater {
                    id: cRepeater
                    model: slider.width / 2
                    anchors.fill: parent
                    Rectangle {
                        id: cTickMark
                        y: -18
                        width: 2; height: 20
                        color: "#795548"
                        opacity: 0
                    }
                }

            }

            CustomSlider {
                id: slider
                Layout.preferredWidth: root.width
                Keys.forwardTo: canvas
                Layout.topMargin: -26

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

                onWidthChanged: {
                    // console.log('width changed')
                    // Show comment Position
                    tickComments()
                }
            }

            RowLayout {
                spacing: 0
                Layout.alignment: Qt.AlignCenter
                Layout.topMargin: -12

                Label {
                    text: Utils.milliSecToString(kioo.position)
                    color: "white"
                    // font.pixelSize: 22

                    Layout.alignment: Qt.AlignHCenter
                }
                Label {
                    text: " / "
                    color: "white"
                    // font.pixelSize: 22

                    Layout.alignment: Qt.AlignHCenter
                }
                Label {
                    text: Utils.milliSecToString(kioo.duration)
                    color: "white"

                    Layout.alignment: Qt.AlignHCenter
                }
            }

            CustomControls {
                id: controls
                Layout.topMargin: -4
                Layout.alignment: Qt.AlignTop
                Layout.preferredWidth: parent.width
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
                   // fileDialog.open()
                    fileDialog.visible === true ? fileDialog.close() : fileDialog.open()
                }
                onUrlOpen: {
                    urlPopup.visible === true ? urlPopup.close() : urlPopup.open()
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
                onPlbsChanged: {
                    if(plbSpeed === "x0.25") {
                        plbSpeed = "x0.5"
                        kioo.playbackRate = 0.5
                    } else if (plbSpeed === "x0.5") {
                        plbSpeed = "x0.75"
                        kioo.playbackRate = 0.75
                    } else if (plbSpeed === "x0.75") {
                        plbSpeed = "x1.0"
                        kioo.playbackRate = 1.0
                    } else if (plbSpeed === "x1.0") {
                        plbSpeed = "x1.25"
                        kioo.playbackRate = 1.25
                    } else if (plbSpeed === "x1.25") {
                        plbSpeed = "x1.75"
                        kioo.playbackRate = 1.75
                    } else if (plbSpeed === "x1.75") {
                        plbSpeed = "x2.0"
                        kioo.playbackRate = 2.0
                    } else if (plbSpeed === "x2.0") {
                        plbSpeed = "x0.25"
                        kioo.playbackRate = 0.25
                    }

                    // Display that playback speed changed
                    osd_left.info("Speed: "+plbSpeed)
                }

                onPostKSP: {
                    if(ksp.apiToken.length < 6) {
                        loginPopup.visible === true ? loginPopup.close() : loginPopup.open()
                    } else if((kioo.playbackState === MediaPlayer.PlayingState) || (kioo.playbackState === MediaPlayer.PausedState)) {
                        postButton.enabled = true
                        commentPopup.visible === true ? commentPopup.close() : commentPopup.open()
                    } else {
                        postButton.enabled = false
                        commentPopup.visible === true ? commentPopup.close() : commentPopup.open()
                    }
                }
            }
        }
    }

    Item {
        id: canvas
        anchors.fill: parent
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
                kioo.videoCapture.capture()
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
                kioo.fastSeek = true
                kioo.seek(kioo.position + 5000)
                osd_left.info("Seeking")
                osd_right.info(Utils.milliSecToString(kioo.position)+"/"+Utils.milliSecToString(kioo.duration))
                break
            case Qt.Key_Left:
                kioo.fastSeek = true
                kioo.seek(kioo.position - 5000)
                osd_left.info("Seeking")
                osd_right.info(Utils.milliSecToString(kioo.position)+"/"+Utils.milliSecToString(kioo.duration))
                break
            case Qt.Key_R: // Not working
                kioo.orientation += 90
               // drawer.open()
                break;
            case Qt.Key_T: // Not working
                videoOut.orientation -= 90
                break;
            case Qt.Key_L:
                drawer.visible === true ? drawer.close() : drawer.open()
                break;
            case Qt.Key_U:
                urlPopup.visible === true ? urlPopup.close() : urlPopup.open()
                break;
            case Qt.Key_S:
                sDrawer.visible === true ? sDrawer.close() : sDrawer.open()
                break;
            case Qt.Key_C: // Not working
                commentPopup.visible === true ? commentPopup.close() : commentPopup.open()
                break
            case Qt.Key_A: // Not working
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
            case Qt.Key_N: // Not working
                kioo.stepForward()
                break
            case Qt.Key_B: // Not working
                kioo.stepBackward()
                break;
            case Qt.Key_Q: // Not working
                Qt.quit()
                break;
            case Qt.Key_E: // Not working
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
            interval: 4000
            onTriggered: osd.visible = false
        }
        function error(value) {
            osd.color = "#ffff00"
            if(osdEnable.checked) {
                text = value
            }
        }
        function info(value) {
            osd.color = "white"
            if(osdEnable.checked) {
                text = value
            }
        }
    }

    Label {
        id: osd_left
        objectName: "osd"
        horizontalAlignment: Text.AlignLeft
        color: "white"
        font.pixelSize: Math.max(root.width, root.height) / 32

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

            if(osdEnable.checked) {
                text = value
            }
        }
        function info(value) {
            osd_left.color = "white"

            if(osdEnable.checked) {
                text = value
            }
        }
    }

    Label {
        id: osd_right
        horizontalAlignment: Text.AlignRight
        color: "white"
        font.pixelSize: Math.max(root.width, root.height) / 32

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

            if(osdEnable.checked) {
                text = value
            }
        }
        function info(value) {
            color = "white"

            if(osdEnable.checked) {
                text = value
            }
        }
    }

    Popup {
        id: loginPopup
        anchors.centerIn: parent
        width: Utils.scale(root.width/2)
        contentHeight: loginLayout.implicitHeight

        background: Rectangle {
            color: '#a98274'
        }

        onVisibleChanged: {
            username.forceActiveFocus()
        }

        ColumnLayout {
            id: loginLayout
            anchors.fill: parent

            Label {
                width: Layout.width
                Layout.alignment: Qt.AlignCenter

                font.bold: true;
                text: "LOGIN"
                font.pointSize: 10
                color: "white"
            }

            TextField {
               id: username
               Layout.fillWidth: true
               placeholderText: "Username"
               enabled: true

               KeyNavigation.down: password
            }

            TextField {
               id: password
               Layout.fillWidth: true
               placeholderText: "Password"
               echoMode: TextInput.PasswordEchoOnEdit
               enabled: true

               KeyNavigation.up: username
               KeyNavigation.down:  processButton

               Keys.onReturnPressed: {
                   ksp.login()
               }
            }

            Button {
               id: processButton
               Layout.fillWidth: true

               onClicked: {
                   ksp.login();
               }
            }

            Label {
                id: linkText
                width: Layout.width
                Layout.alignment: Qt.AlignCenter
                font.pointSize: 10
                text: '<a href="https://kiooplayer.com/social/" style="color: red"> Register Here (https://kiooplayer.com/social/)</a>'

                onLinkActivated: {
                    Qt.openUrlExternally('https://kiooplayer.com/social/')
                }

                MouseArea {
                    anchors.fill: linkText
                    cursorShape: Qt.PointingHandCursor
                }
            }

            states: [
               State {
                   name: "NotAuthenticated"
                   when: ksp.authStatus === 0
                   PropertyChanges {
                       target: processButton
                       text: "Login"
                   }
               },
               State {
                   name: "Authenticating"
                   when: ksp.authStatus === 1
                   PropertyChanges {
                       target: processButton
                       text: "Authenticating..."
                       enabled: false
                   }
               },
               State {
                   name: "AuthenticationFailure"
                   when: ksp.authStatus === 2
                   PropertyChanges {
                       target: processButton
                       text: "Authentication failed, restart"
                   }
               },
               State {
                   name: "Authenticated"
                   when: ksp.authStatus === 3
                   PropertyChanges {
                       target: processButton
                       text: "Logout"
                   }
               }
           ]
        }
    }

    Popup {
        id: commentPopup
        anchors.centerIn: parent
        width: Utils.scale(root.width/2)
        contentHeight: commentLayout.implicitHeight

        background: Rectangle {
            color: '#a98274'
        }

        onVisibleChanged: {
            cContent.forceActiveFocus()
        }

        onOpened: {
            kioo.pause()
            postButton.text = "SUBMIT"
        }

        onClosed: {
            kioo.play()
            postButton.text = "SUBMIT"
        }

        ColumnLayout {
            id: commentLayout

            Label {
                width: Layout.width
                Layout.alignment: Qt.AlignCenter

                font.bold: true;
                text: "NEW COMMENT"
                font.pointSize: 10
                color: "white"
            }

            Label {
                id: comment
                text: "Comment"
                font.pointSize: 10
                font.bold: true
                Layout.preferredWidth: (urlPopup.width) - 16

                color: "white"

            }

            TextField {
                id: cContent
                placeholderText: "Type your comment here(180 Character Max)"
                color: "white"
                text: ""
                maximumLength: 180
                selectByMouse: true
                cursorVisible: true;
                font.pointSize: 10
                Layout.preferredWidth: (commentPopup.width) - 16
                Layout.preferredHeight: 48


                KeyNavigation.down: postButton
                KeyNavigation.tab: postButton

                Keys.onReturnPressed: {
                    if(postButton.enabled) {
                        ksp.postComment()
                    }
                }

            }

           Button {
               id: postButton
               Layout.fillWidth: true

               onClicked: {
                  ksp.postComment();
               }

               Keys.onReturnPressed: {
                   ksp.postComment()
               }
           }

           states: [
               State {
                   name: "NotSubmitted"
                   when: ksp.postStatus === 0
                   PropertyChanges {
                       target: postButton
                       text: "SUBMIT"
                   }
               },
               State {
                   name: "Submitting"
                   when: ksp.postStatus === 1
                   PropertyChanges {
                       target: postButton
                       text: "Submitting..."
                       enabled: false
                   }
               },
               State {
                   name: "SubmitFailed"
                   when: ksp.postStatus === 2
                   PropertyChanges {
                       target: postButton
                       text: "Submit failed, resubmit"

                       onClicked: {
                           ksp.postComment()
                       }
                   }
               },
               State {
                   name: "Submitted"
                   when: ksp.postStatus === 3
                   PropertyChanges {
                       target: postButton
                       text: "Submitted"
                   }
               }
           ]
        }
    }

    Item {
        id: c_view
        anchors.top: root.top
        x : 10
        y : 10
        width: 80; height: 80
        visible: alEnableKsp
        Rectangle {
            anchors.fill: cLayout
            color: "black"
            opacity: 0.5
        }

        ColumnLayout {
            id: cLayout
            spacing: 4
            Label {
                id: c_userid
                Layout.alignment: Qt.AlignLeft
                Layout.preferredHeight: 12
                font.pixelSize: 14
                color: "white"
                opacity: 0.7
                padding: 4
                font.bold: true
                width: root.width
                text: ""
            }

            Label {
                id: c_comment
                Layout.alignment: Qt.AlignLeft
                font.pixelSize: 16
                color: "white"
                opacity: 0.9
                padding: 4
                font.bold: true
                Layout.preferredWidth: Math.max(root.width, root.height) / 2.5

                text: ""
                wrapMode: Text.Wrap
            }
        }

        Timer {
            id: c_scan_timer
            interval: 500; repeat: true
            property var iteration : 0
            onTriggered: {
               // console.log('timer is running')
                if(ksp.comments === "") {
                    if(iteration === 10) {
                        ksp.comments === {
                            "comments": ""
                        }
                    } else {
                        ksp.getComments()
                        iteration  = iteration + 1
                    }
                } else {
                    var obj = ksp.comments
                    for (var i = 0; i < obj.comments.length; i++){
                      if (parseInt(obj.comments[i].position) >= (kioo.position - 500)  && parseInt(obj.comments[i].position) <= (kioo.position + 500)) {
                          c_userid.text = obj.comments[i].author
                          c_comment.text = obj.comments[i].content
                          c_view.visible = true
                          c_timer.restart()
                      }
                    }
                }
            }
        }

        Timer {
            id: c_timer
            interval: 6000
            onTriggered: c_view.visible = false
        }

        Timer {
            id: get_comment_timer
            interval: 300000
            repeat: true
            onTriggered: {
                ksp.getComments()
            }
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

                        hoverEnabled: true
                        ToolTip.delay: 1000
                        ToolTip.timeout: 5000
                        ToolTip.visible: hovered
                        ToolTip.text: qsTr("Clear Current Playlist")

                        onPressed: {
                            pModel.clear();
                            fileName = "";
                            fileURL = "";
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
                       // anchors.left: parent.left
                      //  anchors.right: u.left
                        rightPadding: pDel.spacing
                        text: pDel.text
                        font: pDel.font
                        color: "white"

                        elide: Text.ElideRight
                        visible: pDel.text
                        Layout.alignment: Qt.AlignLeft
                        Layout.preferredWidth: drawer.width - 120
                    }
                    Rectangle {
                        id: u
                     //   anchors.right: d.left
                        height: 30
                        width: 30
                        color: "transparent"
                        Layout.alignment: Qt.AlignRight

                        ToolButton {
                            anchors.fill: parent

                            hoverEnabled: true
                            ToolTip.delay: 1000
                            ToolTip.timeout: 5000
                            ToolTip.visible: hovered
                            ToolTip.text: qsTr("Move its position up")

                            contentItem:  Image {
                                source: "/icon/up.svg"

                            }
                            onClicked: {
                                pModel.move(index,(index-1),1)
                                refreshData()
                            }
                        }
                    }
                    Rectangle {
                        id: d
                     //   anchors.right: r.left
                        height: 30
                        width: 30
                        color: "transparent"
                        Layout.alignment: Qt.AlignRight


                        ToolButton {
                            anchors.fill: parent

                            hoverEnabled: true
                            ToolTip.delay: 1000
                            ToolTip.timeout: 5000
                            ToolTip.visible: hovered
                            ToolTip.text: qsTr("Move its position down")
                            contentItem:  Image {
                                source: "/icon/down.svg"

                            }
                            onClicked: {
                                pModel.move(index,(index+1),1)
                                refreshData()
                            }
                        }
                    }
                    Rectangle {
                        id: r
                       // anchors.right: parent.right
                        height: 30
                        width: 30
                        color: "transparent"
                        Layout.alignment: Qt.AlignRight

                        ToolButton {
                            anchors.fill: parent

                            hoverEnabled: true
                            ToolTip.delay: 1000
                            ToolTip.timeout: 5000
                            ToolTip.visible: hovered
                            ToolTip.text: qsTr("Remove from playlist")

                            contentItem:  Image {
                                source: "/icon/close.svg"

                            }
                            onClicked: {
                                pModel.remove(index)
                                refreshData()
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
                    text: "Window"
                    font.pixelSize: 25
                    color: "white"
                }

                RowLayout {
                    Layout.topMargin: -16
                    Layout.leftMargin: 4

                    Label {
                        Layout.alignment: Qt.AlignLeft
                        Layout.preferredWidth: sDrawer.width/2
                        text: "Always On Top"
                        font.pixelSize: 16
                        color: "white"

                    }

                    Switch {
                        id: onTopEnable
                        checked: false
                        // root.visibility == Window.FullScreen ? root.visibility=Window.Windowed : root.visibility=Window.FullScreen
                        enabled: root.visibility == Window.FullScreen ? false : true

                        hoverEnabled: true
                        ToolTip.delay: 1000
                        ToolTip.timeout: 5000
                        ToolTip.visible: hovered
                        ToolTip.text: qsTr("Toggle Always on Top On/Off")

                        onToggled: {
                            if(root.visibility === Window.Windowed) {
                                if(onTopEnable.checked) {
                                    root.flags |= Qt.WindowTitleHint | Qt.WindowSystemMenuHint |
                                            Qt.WindowStaysOnTopHint | Qt.CustomizeWindowHint |
                                            Qt.WindowMaximizeButtonHint | Qt.WindowMinimizeButtonHint |
                                            Qt.WindowCloseButtonHint

                                } else {
                                    root.flags ^= Qt.WindowStaysOnTopHint
                                }
                            }
                        }
                    }
                }

                Label {
                    Layout.topMargin: -16
                    leftPadding: 2
                    text: "Audio"
                    font.pixelSize: 25
                    color: "white"
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

                    }

                    Switch {
                        id: audioEnable
                        checked: true

                        hoverEnabled: true
                        ToolTip.delay: 1000
                        ToolTip.timeout: 5000
                        ToolTip.visible: hovered
                        ToolTip.text: qsTr("Toggle Audio On/Off")
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
                    }

                    CustomCombo {
                        Layout.alignment: Qt.AlignLeft
                        Layout.preferredWidth: sDrawer.width/2.5
                        Layout.preferredHeight: 48
                        textRole: "text"

                        hoverEnabled: true
                        ToolTip.delay: 1000
                        ToolTip.timeout: 5000
                        ToolTip.visible: hovered
                        ToolTip.text: qsTr("Change Audio Channel")

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

                    }

                    CustomCombo {
                        id: caudio
                        Layout.alignment: Qt.AlignLeft
                        Layout.preferredWidth: sDrawer.width/2.5
                        Layout.preferredHeight: 48
                        currentIndex: 0

                        hoverEnabled: true
                        ToolTip.delay: 1000
                        ToolTip.timeout: 5000
                        ToolTip.visible: hovered
                        ToolTip.text: qsTr("Change Audio Track")

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

                        }

                        Switch {
                            id: videoEnable
                            checked: true

                            hoverEnabled: true
                            ToolTip.delay: 1000
                            ToolTip.timeout: 5000
                            ToolTip.visible: hovered
                            ToolTip.text: qsTr("Toggle Video On/Off")
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

                    }

                    RowLayout {
                        Layout.topMargin: -16
                        Layout.leftMargin: 4

                        Label {
                            text: "Enable Subtitles "
                            Layout.preferredWidth: sDrawer.width/2
                            font.pixelSize: 16
                            color: "white"

                        }
                        Switch {
                            id: subtitleEnable
                            checked: true

                            hoverEnabled: true
                            ToolTip.delay: 1000
                            ToolTip.timeout: 5000
                            ToolTip.visible: hovered
                            ToolTip.text: qsTr("Toggle Subtitles On/Off")
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

                        }

                        CustomCombo {
                            id: csub
                            Layout.alignment: Qt.AlignLeft
                            Layout.preferredWidth: sDrawer.width/2.5
                            Layout.preferredHeight: 48
                            currentIndex: 0
                            textRole: "title"

                            hoverEnabled: true
                            ToolTip.delay: 1000
                            ToolTip.timeout: 5000
                            ToolTip.visible: hovered
                            ToolTip.text: qsTr("Change Subtitle Track")

                            delegate: ItemDelegate {
                                width: csub.width
                                contentItem: Text {
                                    text: title
                                    color: "white"

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
                                 //   subtitle.file = ""
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

                        }

                        Button {
                            id: subSearchBtn
                            text: 'SEARCH'

                            hoverEnabled: true
                            ToolTip.delay: 1000
                            ToolTip.timeout: 5000
                            ToolTip.visible: hovered
                            ToolTip.text: qsTr("Search Online Subtitles")


                            onClicked: {
                                if((kioo.playbackState === MediaPlayer.PlayingState) || (kioo.playbackState === MediaPlayer.PausedState)) {
                                    addon.sourceUrl = kioo.source
                                    request('https://rest.opensubtitles.org/search/moviebytesize-'+kioo.metaData.size+'/moviehash-'+addon.sourceUrl+'/sublanguageid-'+ subLangList.get(subLang.currentIndex).value, function (v) {
                                        try {
                                            var resObj = JSON.parse(v.responseText);
                                            if(resObj.length > 0) {
                                                subOssModel.clear();
                                                for (var i=0;i < resObj.length; i++) {
                                                    subOssModel.append({ fTitle: resObj[i].SubFileName, fLink: resObj[i].SubDownloadLink});
                                                }
                                                subList.currentIndex = 0;
                                                addon.subFile = subOssModel.get(subList.currentIndex).fLink+"|"+subOssModel.get(subList.currentIndex).fTitle+"|"+kioo.source;
                                            }
                                            else {
                                                subOssModel.clear();
                                                subOssModel.append({fTitle: 'No Matching Subtitle', fLink: ''});
                                                subList.currentIndex = 0;
                                            }
                                        }
                                        catch(e) {
                                           // console.log('Search not working');
                                            subOssModel.clear();
                                            subOssModel.append({fTitle: 'Subtitle Search Not Working', fLink: ''});
                                            subList.currentIndex = 0;
                                        }
                                    });

                                }
                                else {
                                    subOssModel.clear();
                                    subOssModel.append({fTitle: 'Error - No Media Loaded', fLink: ''});
                                    subList.currentIndex = 0;
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
                        Button {
                            id: subDownBtn
                            text: 'LOAD'

                            hoverEnabled: true
                            ToolTip.delay: 1000
                            ToolTip.timeout: 5000
                            ToolTip.visible: hovered
                            ToolTip.text: qsTr("Download Selected Online")

                            onClicked: {
                                addon.subFile = subOssModel.get(subList.currentIndex).fLink+"|"+subOssModel.get(subList.currentIndex).fTitle+"|"+kioo.source;
                            }

                            Connections {
                                target: addon
                                onSubFileChanged: {
                                    sTrackModel.append({title: "External Sub", link: addon.subFile })
                                    sDrawer.close();
                                    alSubUrl = addon.subFile;
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
                            Layout.preferredHeight: 48
                            textRole: "name"

                            hoverEnabled: true
                            ToolTip.delay: 1000
                            ToolTip.timeout: 5000
                            ToolTip.visible: hovered
                            ToolTip.text: qsTr("Change Online Subtitle Language")

                            // model: ["English","French","Spanish"]
                            model: ListModel {
                                id: subLangList
                                ListElement { name: "English"; value: "eng" }
                                ListElement { name: "French"; value: "fre" }
                                ListElement { name: "Germany"; value: "ger" }
                                ListElement { name: "Spanish"; value: "spa" }
                                ListElement { name: "Russian"; value: "rus" }
                                ListElement { name: "Finnish"; value: "fin" }
                                ListElement { name: "Japanese"; value: "jpn" }
                                ListElement { name: "Korean"; value: "kor" }
                                ListElement { name: "Finnish"; value: "fin" }
                                ListElement { name: "Portuguese"; value: "por" }
                                ListElement { name: "Dutch"; value: "dut" }
                                ListElement { name: "Chinese"; value: "chi" }
                                ListElement { name: "Swahili"; value: "swa" }
                                ListElement { name: "Indonesian"; value: "ind" }
                            }
                            delegate: ItemDelegate {
                                width: subLang.width
                                contentItem: Text {
                                    text: name
                                    color: "white"

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
                            Layout.preferredWidth: sDrawer.width/1.53
                            Layout.preferredHeight: 48
                            currentIndex: 0
                            textRole: "fTitle"

                            hoverEnabled: true
                            ToolTip.delay: 1000
                            ToolTip.timeout: 5000
                            ToolTip.visible: hovered
                            ToolTip.text: qsTr("Selected/Change Online Subtitle")

                            model: ListModel {
                                id: subOssModel
                                //  ListElement { title: ""; source: "" }
                            }
                            delegate: ItemDelegate {
                                width: subList.width
                                contentItem: Text {
                                    text: fTitle
                                    color: "white"

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

                    }

                    RowLayout {
                        Layout.topMargin: -16
                        Layout.leftMargin: 4

                        Label {
                            text: "Enable History  "
                            Layout.preferredWidth: sDrawer.width/2
                            font.pixelSize: 16
                            color: "white"

                        }
                        Switch {
                            id: enableHistory
                            checked: true

                            hoverEnabled: true
                            ToolTip.delay: 1000
                            ToolTip.timeout: 5000
                            ToolTip.visible: hovered
                            ToolTip.text: qsTr("Toggle Play Auto Save On/Off")
                        }
                    }
                }

                ColumnLayout {
                    Label {
                        leftPadding: 2
                        text: "Kioo Social Platform"
                        font.pixelSize: 25
                        color: "white"

                    }

                    RowLayout {
                        Layout.topMargin: -16
                        Layout.leftMargin: 4

                        Label {
                            text: "Enable KSP:  "
                            Layout.preferredWidth: sDrawer.width/2
                            font.pixelSize: 16
                            color: "white"

                        }
                        Switch {
                            id: kspEnable
                            checked: true

                            hoverEnabled: true
                            ToolTip.delay: 1000
                            ToolTip.timeout: 5000
                            ToolTip.visible: hovered
                            ToolTip.text: qsTr("Toggle Kioo Social Platform On/Off")

                            onCheckedChanged: {

                                if(kspEnable.checked === true) {
                                    c_view.enabled = true
                                    c_scan_timer.restart()
                                } else {
                                    c_view.enabled = false
                                    c_scan_timer.stop()
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.topMargin: -16
                        Layout.leftMargin: 4
                        Label {
                            text: "Sign Out"
                            Layout.preferredWidth: sDrawer.width/2
                            font.pixelSize: 16
                            color: "white"

                        }

                        Button {
                            id: logoutButton
                            Layout.fillWidth: false
                            Layout.alignment: Qt.AlignRight
                            text: "LOGOUT"

                            hoverEnabled: true
                            ToolTip.delay: 1000
                            ToolTip.timeout: 5000
                            ToolTip.visible: hovered
                            ToolTip.text: qsTr("Logout from KSP")

                            onClicked: {
                                ksp.apiToken = "0000"
                            }
                        }
                    }
                }

                ColumnLayout {
                    Label {
                        leftPadding: 2
                        text: "OSD Settings"
                        font.pixelSize: 25
                        color: "white"

                    }

                    RowLayout {
                        Layout.topMargin: -16
                        Layout.leftMargin: 4

                        Label {
                            text: "Enable OSD  "
                            Layout.preferredWidth: sDrawer.width/2
                            font.pixelSize: 16
                            color: "white"

                        }
                        Switch {
                            id: osdEnable
                            checked: true

                            hoverEnabled: true
                            ToolTip.delay: 1000
                            ToolTip.timeout: 5000
                            ToolTip.visible: hovered
                            ToolTip.text: qsTr("Toggle On Screen Display")
                        }
                    }
                }

                ColumnLayout {
                    Label {
                        leftPadding: 2
                        text: "About"
                        font.pixelSize: 25
                        color: "white"

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

            if(alSubUrl !== "") {
                sTrackModel.append({title: j+ " - external subs", link: alSubUrl })

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
        // Comment related
        c_view.visible = false

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
        root.title = version;
        fileName = version;
        ksp.getVersion();
        Utils.getFile(Qt.application.arguments);

    }
    Component.onDestruction: {
        if(enableHistory.checked)
            refreshData();
        else
            pModel.clear();
    }

    function initDatabase() {
        db = LocalStorage.openDatabaseSync("Kioo", "1.0", "Kioo Media", 1000000);
        db.transaction( function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS data(name TEXT, value TEXT)');
        });
    }


    function storeData() {
        initDatabase();
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
            return;
        });

    }

    function readData() {
        db = LocalStorage.openDatabaseSync("Kioo", "1.0", "Kioo Media", 1000000);
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
        initDatabase();
        db.transaction( function(tx) {
            tx.executeSql('DROP TABLE IF EXISTS data');
        });
    }

    function refreshData() {
        if(enableHistory.checked) {
            cleanData();
            storeData();
        }
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
