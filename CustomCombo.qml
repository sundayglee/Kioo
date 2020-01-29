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
import QtQuick.Window 2.0
import QtAV 1.5
import "Utils.js" as Utils
import QtQuick.Dialogs 1.2
import QtQuick.LocalStorage 2.0

ComboBox {
    id: control
    
    delegate: ItemDelegate {
        width: control.width
        contentItem: Text {
            text: modelData
            color: "white"

            font: control.font
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }
        highlighted: control.highlightedIndex === index
    }
    
    indicator: Canvas {
        id: canvas
        x: control.width - width - control.rightPadding
        y: control.topPadding + (control.availableHeight - height) / 2
        width: 12
        height: 8
        contextType: "2d"

        Connections {
            target: control
            onPressedChanged: canvas.requestPaint()
        }

        onPaint: {
            if(context) {
                context.reset();
                context.moveTo(0, 0);
                context.lineTo(width, 0);
                context.lineTo(width / 2, height);
                context.closePath();
                context.fillStyle = control.pressed ? "#009688" : "#52c7b8";
                context.fill();
            }
        }
        
     }
    
    contentItem: Text {
        leftPadding: 4
        rightPadding: control.indicator.width + control.spacing

        text: control.displayText
        font: control.font
        color: "white"

        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
    
    background: Rectangle {
        implicitWidth: 120
        implicitHeight: 40
        border.color: control.pressed ? "#009688" : "#52c7b8";
      //  border.color: "transparent"
        border.width: control.visualFocus ? 2 : 1
        color: "#795548"
        radius: 2
    }
    
    popup: Popup {
        y: control.height - 1
        width: control.width
        implicitHeight: contentItem.implicitHeight
        padding: 1

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex
            ScrollIndicator.vertical: ScrollIndicator { }
        }

        background: Rectangle {
            border.color: "#52c7b8"
            color: "#795548"
            radius: 2
        }
    }
}
