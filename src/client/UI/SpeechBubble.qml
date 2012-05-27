/***************************************************************************
**
** Copyright (c) 2012, Tarek Galal <tarek@wazapp.im>
**
** This file is part of Wazapp, an IM application for Meego Harmattan
** platform that allows communication with Whatsapp users.
**
** Wazapp is free software: you can redistribute it and/or modify it under
** the terms of the GNU General Public License as published by the
** Free Software Foundation, either version 2 of the License, or
** (at your option) any later version.
**
** Wazapp is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
** See the GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with Wazapp. If not, see http://www.gnu.org/licenses/.
**
****************************************************************************/
// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0

BorderImage {
    id: bubble

    property string picture;
    property string message;
    property bool from_me;
    property string date;
    property string name;
    property int msg_id;
    property string state_status;

    property int inboundBubbleColor: 1 // 1 is blue and 2 is darkblue 3 is orange 4 is brown 5 is pink 6 is purple 7 is green 8 is darkgreen
    property int outboundBubbleColor: 1

    QtObject {
        id: d
        property int inboundBubbleNumber: parseInt( (bubble.inboundBubbleColor / 2) + 0.5 )
        property int outboundBubbleNumber: parseInt( (bubble.outboundBubbleColor /2) + 0.5 )
        property string inboundBubbleState: bubbleMouseArea.pressed ? "pressed" : "normal"
        property string outboundBubbleState: bubbleMouseArea.pressed ? "pressed" : "normal"
    }

    anchors.right: from_me?this.right:parent.right
    anchors.left: !from_me?this.left:parent.left
    anchors.rightMargin: 10
    anchors.leftMargin: 10

    state: state_status;

    signal optionsRequested();

    width: calcBubbleWidth()
    height: from_me ? content.height+12 : content.height

    function calcTextWidth() {
        return Math.max(calcLabel.width, msg_date.width)
    }

    function calcLabelWidth() {
        return Math.min(calcLabel.width, bubble.parent.width-40);
    }

    function calcBubbleWidth() {
        return Math.min(calcTextWidth()+50, bubble.parent.width-20);
    }

    TextFieldStyle {
        id: textFieldStyle
    }

    Label {
        id: calcLabel
        text: bubble.message
        visible: false
        font.family: textFieldStyle.textFont
        font.pixelSize: textFieldStyle.textFont.pixelSize
    }

    border {
        left: 22
        right: 22
        bottom: 22
        top: 22
    }

    source: from_me ?
        	"image://theme/meegotouch-messaging-conversation-bubble-outgoing" + d.outboundBubbleNumber + "-" + d.outboundBubbleState :                
                "image://theme/meegotouch-messaging-conversation-bubble-incoming" + d.inboundBubbleNumber + "-" + d.inboundBubbleState

    states: [
        State {
            name: "sending"
            PropertyChanges {
                target: status
                source: "pics/indicators/sending.png"
            }
        },
        State {
            name: "pending"
            PropertyChanges {
                target: status
                source: "pics/indicators/pending.png"
            }
        },
        State {
            name: "delivered"
            PropertyChanges {
                target: status
                source: "pics/indicators/delivered.png"
            }
        }
    ]

    MouseArea{
	id: bubbleMouseArea
        anchors.fill: parent
        /*onClicked: {
            console.log("CLICKED!!!");
             optionsRequested();
        }*/

        onPressAndHold:{
            console.log("pressed and held!")
            optionsRequested();
        }
    }
     
    Column{
        id:content

        Rectangle {
            id: margin1;
            height: from_me? 0 : 22
            width: parent.width;
            color: "transparent"
        }

Image {
        id: status
        visible: from_me
        anchors.left: msg_date.right
        anchors.leftMargin: 12
        anchors.bottom:parent.bottom
        anchors.bottomMargin: 4

    }

        /*Label{
            id:sender_name
            width:parent.width -20
            color:appWindow.stealth?colorPicker.color:(from_me?"black":"white")
            text:from_me?"You":name
            font.pixelSize: 20
            font.bold: true
            anchors.left: parent.left
            anchors.leftMargin: 10
            horizontalAlignment: from_me? Text.AlignLeft : Text.AlignRight
        }*/
        Label{
            id:msg_text
            text:message
            color:appWindow.stealth?colorPicker.color:(from_me?"black":"white")
            width: calcLabelWidth()
            wrapMode: "WrapAtWordBoundaryOrAnywhere"
            anchors.left: parent.left
            anchors.leftMargin: 10
            textFormat: Text.RichText
            font.pixelSize: 22
            font.family: textFieldStyle.textFont
            //horizontalAlignment: from_me? Text.AlignLeft : Text.AlignRight
            onLinkActivated: Qt.openUrlExternally(link);
        }

        /*Separator{
            top_margin: 5;
            bottom_margin: 2;
            visible:!appWindow.stealth
        }*/

        Label{
            id:colorPicker
            visible:false
        }

        Rectangle {
            id: margincenter;
            height: 4
            width: parent.width;
            color: "transparent"
        }

        Label{
            id:msg_date
            color:appWindow.stealth?colorPicker.color:(from_me?"black":"white")
            text: date
	    x: from_me? 10 : 10+bubble.width-msg_date.width-status.width
            font.pixelSize: 18
            font.family: textFieldStyle.textFont
            horizontalAlignment: from_me? Text.AlignLeft : Text.AlignRight
            opacity: 0.7
        }
    }
}


