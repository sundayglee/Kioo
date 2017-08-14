import QtQuick 2.9
import QtQuick.XmlListModel 2.0

XmlRpc {
    id: xroot
//    query: "/methodResponse/params/param/value/struct/member/value/array/data/"
    query: "/methodResponse/params/param/value/struct/member/value/array/data/value/struct"
//    signal itemFound(string name, int index)
//    signal updateComplete()
//    property string command: "data"
//    property int interval: 0

//    property QtObject _timer: Timer {
//        id: refreshtimer
//        interval: xroot.interval
//        repeat: true
//        running: interval > 0
//        onTriggered: xroot.refresh()
//    }

    XmlRole { name: "matchedby";        query: "member[1]/name/string()"; }
    XmlRole { name: "subfile";          query: "member[7]/value/string/string()" }
    XmlRole { name: "sublink";          query: "member[50]/value/string/string()" }

//    onStatusChanged: {
//        console.log("XmlRpcMap.onStatusChanged()", status)
//        if (status == XmlListModel.Ready) {
//            console.log("XmlRpcMap.onStatusChanged()", xroot.count)
//            for (var i=0; i<xroot.count; i++) {
//                itemFound(xroot.get(i).sublink,i);
//            }
//            updateComplete()
//        }
//    }

 //   Component.onCompleted: xroot.refresh()
}
