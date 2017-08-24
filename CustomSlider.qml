import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtMultimedia 5.9
import QtQuick.Window 2.0

Slider {
    id: control
    topPadding: -4
    leftPadding: 0
    rightPadding: 0

    function setProgress(value) {
        control.value = value
    }
    
    background: Rectangle {
     //   x: control.leftPadding
     //  y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: 200
        implicitHeight: 6
        width: control.availableWidth
        height: implicitHeight
        color: "white"
        opacity: 0.8
        
        Rectangle {
            width: control.visualPosition * parent.width
            height: parent.height
            color: "#795548"
            radius: 0
        }
    }
    
    handle: Rectangle {
        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: 12
        implicitHeight: 12
        radius: 13
        color: control.pressed ? "#f0f0f0" : "#f6f6f6"
        border.color: "#bdbebf"
    }
}
