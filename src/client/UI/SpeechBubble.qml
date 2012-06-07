
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


//	Component.onCompleted: console.log(message)


  //  property int mediatype_id;

    property string picture;

    property bool from_me;
    property string date;
    property string name;
    property int msg_id;
    property string state_status;
    property variant media;

    property alias bubbleContent:bubbleContent.children

    property int inboundBubbleColor: 1 // 1 is blue and 2 is darkblue 3 is orange 4 is brown 5 is pink 6 is purple 7 is green 8 is darkgreen
    property int outboundBubbleColor: 1


    QtObject {
        id: d
        property int inboundBubbleNumber: parseInt( (bubble.inboundBubbleColor / 2) + 0.5 )
        property int outboundBubbleNumber: parseInt( (bubble.outboundBubbleColor /2) + 0.5 )
        property string inboundBubbleState: bubbleMouseArea.pressed ? "pressed" : "normal"
        property string outboundBubbleState: bubbleMouseArea.pressed ? "pressed" : "normal"
    }



    state: state_status;

    signal optionsRequested();

    width: Math.max(bubbleContent.width+10,dataRow.width+20)
     //bubble.mediatype_id == 1 ? calcBubbleWidth() : (bubble.mediatype_id == 2 ? dataRow.width+22 : dataRow.width+22)
    height: from_me ? content.height+12 : content.height



    TextFieldStyle {
        id: textFieldStyle
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
        onClicked: {
            console.log("CLICKED!!!");

        }

        onPressAndHold:{
            console.log("pressed and held!")
            optionsRequested();
        }
    }

    Column{
        id:content
        spacing: 4
        width: bubble.width-20
        anchors.horizontalCenter: bubble.horizontalCenter

        Item {
            id: margin1;
            height: from_me? 10 : 18
            width: parent.width;
        }



        Item{
            id:bubbleContent
            width:bubbleContent.children[0].width
            height:bubbleContent.children[0].height
        }



    Row {
        id: dataRow
        spacing: 10
        x: from_me? 0 : bubble.width-msg_date.width-20
            Label{
                    id:msg_date
                    color: from_me?"black":"white"
                    text: date
                    font.pixelSize: 18
                    font.family: textFieldStyle.textFont
                    horizontalAlignment: from_me? Text.AlignLeft : Text.AlignRight
                    opacity: 0.7
            }
        Image {
                id: status
                visible: from_me
            width: sourceSize.width  //from_me ? sourceSize.width : 0
            y: msg_date.y+3
        }
    }
    }
}

