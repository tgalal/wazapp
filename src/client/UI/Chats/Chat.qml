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
import "../common/js/Global.js" as Helpers
import "../common"


Rectangle{
    id:container

    property string jid;
    property string subject;
	property string owner;
    property string groupSubjectNotReady:qsTr("Fetching group subject")+"...";
    property bool isGroup:false
    property string title;//:ChatHelper.conversation.title;
    property variant lastMessage;
    property string picture;
    property int unreadCount;
	property bool isOpenend:false

    signal clicked(string number);
    signal optionsRequested()

    height: 102 //lastMessage || isGroup ? 102 : 0;
    color:"transparent"

    state:(!lastMessage)?"":(lastMessage.type==1?(isGroup && lastMessage.status == "pending"?"delivered":lastMessage.status):"received")

	Connections {
		target: appWindow

		onReorderConversation: {
			if (jid==cjid)
				waChats.moveToCorrectIndex(cjid);
		}

        /*onGroupInfoUpdated: {
			var data = gdata.split("<<->>")
			if (jid==gjid) {
				consoleDebug("CONVERSATION JID: " + jid)
				var data = gdata.split("<<->>")
				subject = data[2]
				owner = data[1]
				title = subject
			}
		}
		onOnContactPictureUpdated: {
			if (jid == ujid) {
				chat_picture.imgsource = ""
				chat_picture.imgsource = picture
			}
        }*/

		onUpdateContactName: {
			if (jid == ujid) {
				if (title = jid.split('@')[0]) {
					consoleDebug("Update push name in Chat")
					chat_title.text = npush
				}
			}
		}
	}

    function getAuthor(inputText) {
		if (inputText==myAccount)
			return qsTr("You")
        var resp = inputText;
        for(var i =0; i<contactsModel.count; i++)
        {
            if(resp == contactsModel.get(i).jid) {
                resp = contactsModel.get(i).name;
		    	if (resp.indexOf("@")>-1 && contactsModel.get(i).pushname!="")
					resp = contactsModel.get(i).pushname;
				break;
			}
        }

		return resp.split('@')[0]
    }

    function setConversation(c){
        ChatHelper.conversation = c;
        c.ustatusChanged.connect(ustatusChanged)
        c.addObserver(container);
        rebind();
    }

    function ustatusChanged(s){
        if(s=="typing"){
            last_msg.visible = false
            isWriting.visible = true
        } else {
            last_msg.visible = true
            isWriting.visible = false
        }
    }

    function getConversation(){return ChatHelper.conversation;}

    function rebind(){
        var c = ChatHelper.conversation;
        isGroup = c.isGroup;
        jid = c.jid;
        subject = c.subject;
        title = c.title;
        picture = c.picture.indexOf("/home")>-1? c.picture : (isGroup? "../common/images/group.png" : "../common/images/user.png")
        lastMessage = c.lastMessage;
        unreadCount = c.unreadCount;
		isOpenend = c.opened;
		//if(lastMessage) 
        //    waChats.moveToCorrectIndex(jid);
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
			/*if (!ChatHelper.conversation.opened) {
				ChatHelper.conversation.loadReverse = true
				ChatHelper.conversation.loadMoreMessages(19)
				ChatHelper.conversation.loadReverse = false
			}*/
            ChatHelper.conversation.open();
			if (isGroup && subject=="") {
				consoleDebug("GETTING GROUP INFO FOR "+jid)
				getGroupInfo(jid)
			}
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

			Item{
                //spacing:5
				height: 30
                width:parent.width -6

                Label{
                    id: chat_title
                    text: title
                   	width:parent.width - 30
                    elide: Text.ElideRight
                    font.bold: true
					font.pointSize: 18
                    verticalAlignment: Text.AlignVCenter
					height: 30
                }
				/*Rectangle {
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
				}*/
				CountBubble {
					title: unreadCount? unreadCount : ""
					anchors.right: parent.right
					anchors.verticalCenter: parent.verticalCenter
				}
            }
            Row{
                spacing:5
                width:parent.width
				y: -2

                Image {
                    id: status
                    height: lastMessage ? (isWriting.visible ? 0 : 16) : 0
					width: 16
					smooth: true
                    y: 5
 				}
                Text {
                    id:last_msg
                    text: lastMessage? (lastMessage.type==0 || lastMessage.type==1 ? Helpers.emojify(lastMessage.content) : 
                          (lastMessage.type==20 ? qsTr("%1 joined the group").arg(getAuthor(lastMessage.content)) :
                          (lastMessage.type==21 ? qsTr("%1 left the group").arg(getAuthor(lastMessage.content)) :
						  (lastMessage.type==22 ? (lastMessage.author.jid==myAccount ?
                            qsTr("%1 changed the subject to %2").arg(getAuthor(lastMessage.author.jid)).arg(Helpers.emojify(lastMessage.content)) :
                            qsTr("%1 changed the subject to %2").arg(getAuthor(lastMessage.author.jid)).arg(Helpers.emojify(lastMessage.content)) ):
						  (lastMessage.author.jid==myAccount ? 
                            qsTr("%1 changed the group picture").arg(getAuthor(lastMessage.content)) :
                            qsTr("%1 changed the group picture").arg(getAuthor(lastMessage.content))) )))) :
						  qsTr("(no messages)")
                   	width:parent.width -(status.visible?30:10)
                    elide: Text.ElideRight
                    font.pixelSize: 20
                    height: 28
                    color: unreadCount!=0 ? "#27a01b" : chat_title.color
					clip: true
                }
				Label {
					id: isWriting
                    visible: false
					text: "<i>" + qsTr("is writing a message...") + "</i>"
                    elide: Text.ElideRight
                    font.pixelSize: 20
                    height: 28
                    color: "gray"
					clip: true
				}
            }

            Label{
                id: last_msg_time
                text: lastMessage? Helpers.getDateText(lastMessage.formattedDate).replace("Today", qsTr("Today")).replace("Yesterday", qsTr("Yesterday")) : ""
                font.pixelSize: 16
				color: "gray"
				height: 30
                width:parent.width
				visible: text!==""
            }	    
        }
    }
}
