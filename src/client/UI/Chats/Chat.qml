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

import "js/chat.js" as ChatHelper
import "../common"


Rectangle{
    id:container

    property string jid;
    property string subject;
    property string groupSubjectNotReady:qsTr("Fetching group subject")+"...";
    property bool isGroup:false
    property string title;//:ChatHelper.conversation.title;
    property variant lastMessage;
    property string picture;
    property int unreadCount;
    signal clicked(string number);
    signal optionsRequested()
    visible:lastMessage || isGroup ? true : false;
    height: lastMessage || isGroup ? 102 : 0;
    color:"transparent"

    state:(!lastMessage)?"":(lastMessage.type==1?lastMessage.status:"received")

    function setConversation(c){
        ChatHelper.conversation = c;
        c.addObserver(container);
        rebind();
    }

    function getConversation(){return ChatHelper.conversation;}

    function rebind(){
        var c = ChatHelper.conversation;
        isGroup = c.isGroup;
        jid = c.jid;
        subject = c.subject;
        title = c.title;
        picture = c.picture;
        lastMessage = c.lastMessage;
        unreadCount =c.unreadCount;

        if(lastMessage)
            waChats.moveToCorrectIndex(jid);
    }

    states: [
        State {
            name: "received"
            PropertyChanges {
                target: status
                visible:false
            }
        },

        State {
            name: "sending"
            PropertyChanges {
                target: status
                source: "images/indicators/sending.png"
            }
            PropertyChanges {
                target: status
                visible:true
            }
        },
        State {
            name: "pending"
            PropertyChanges {
                target: status
                source: "images/indicators/pending.png"
                 visible:true
            }
        },
        State {
            name: "delivered"
            PropertyChanges {
                target: status
                source: "images/indicators/delivered.png"
                visible:true
            }
        }
    ]

    MouseArea{

        id:mouseArea
        anchors.fill: parent
        onClicked: {
            ChatHelper.conversation.open();
        }
        onPressAndHold: optionsRequested()
    }

	Rectangle {
		anchors.fill: parent
		color: theme.inverted? "darkgray" : "lightgray"
		opacity: theme.inverted? 0.2 : 0.8
		visible: mouseArea.pressed
	}

    Row
    {
        anchors.fill: parent
        spacing: 10
        anchors.topMargin: 10
        anchors.leftMargin: 10
        anchors.rightMargin: 10
		height: 80
		width: parent.width
		anchors.verticalCenter: parent.verticalCenter

		RoundedImage {
            id:chat_picture
            width:80
            height: 80
            size:72
            imgsource: picture
            x: 2;
			anchors.verticalCenter: parent.verticalCenter
			opacity:appWindow.stealth?0.2:1
			//onClicked: mouseArea.clicked()
			//onPressAndHold: mouseArea.pressAndHold()
        }

        Column{
			id:last_msg_wrapper
		    width:parent.width - 90
			spacing: 0

			Row{
                spacing:5
                width:parent.width -6

                Label{
                    id: chat_title
                    text: title
                   	width:parent.width - 30
                    elide: Text.ElideRight
                    font.bold: true
					font.pointSize: 18
                    verticalAlignment: Text.AlignVCenter
                }
				Rectangle {
					color: "gray"
					radius: 10
					smooth: true
					width: 30
					height: 26
                    visible: unreadCount !=0
					Label {
						color: "white"
						font.pixelSize: 14
						anchors.centerIn: parent
                        text:unreadCount
					}
				}
            }
            Row{
                spacing:5
                width:parent.width

                Image {
                    id: status
                    height: 18; width: 18
					smooth: true
                    y:5
 				}
                Label{
                    id:last_msg
                    text: lastMessage?lastMessage.content:"";
                   	width:parent.width
                    elide: Text.ElideRight
                    font.pixelSize: 20
                    height: 30
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Label{
                id:last_msg_time
                text:lastMessage?lastMessage.formattedDate:"";
                font.pixelSize: 16
				color: "gray"
				height: 30
                width:parent.width
            }	    
        }
    }
}
