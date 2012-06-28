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
import QtQuick 1.1
import com.nokia.meego 1.0

import "js/chats.js" as ChatScript
import "../common/js/classes.js" as Components
import "../common/js/Global.js" as Helpers
import "../common"
import "../Menu"

WAPage {
    id: chatsContainer
    property alias indicator_state:wa_notifier.state

    //state:"no_data"

    signal clicked(string number,string prev_state)
    signal deleteConversation(string conv_id);

    /********** NEW STUFF ***********/

    function getOrCreateConversation(jid){


        var conversation = findConversation(jid);
        if(conversation)
            return conversation;

        console.log("NOT FOUND")
        conversation = new Components.Conversation(appWindow).view;
        conversation.jid = jid;

        console.log("APPENDING");
        conversationsModel.append({conversation:conversation})

        console.log("RETURNING")
        return conversation;
    }

    function moveToCorrectIndex(jid){ChatScript.moveToCorrectIndex(jid);}

    function getConversation(jid){

        console.log("FIND");
        var conversation = findConversation(jid);
        if(conversation)
            return conversation;

        return false;
    }

    ListModel{id:conversationsModel}

    function findConversation(jid){
        for (var i=0; i<conversationsModel.count;i++)
        {
            var conversation = conversationsModel.get(i).conversation;
            if(conversation.jid == jid)
                   return  conversation;
        }
        return 0
    }

    /********************************/

    states: [
        State {
            name: "no_data"
            PropertyChanges {
                target: no_data
                visible:true
            }
        }
    ]

    Component{
        id:chatsDelegate;

        Chat{
           // conversation: model.conversation
            onClicked: {
                /*UNCOMMENTME
				chatsContainer.clicked(model.jid,"chats")
                appWindow.conversationOpened(model.jid);
                unread_messages=0
                */
			}
            Component.onCompleted: {
                setConversation(model.conversation);
            }

            width:chatsContainer.width
            onOptionsRequested: {
                /*UNCOMMENTME
                chatDelConfirm.cid_confirm = model.jid;
				contactNumber = model.jid.split('-')[0].split('@')[0]
				contactNumberGroup = isGroup
				showContactDetails = isGroup? 
									getAuthor(model.jid).split('-')[0]==getAuthor(contactInfo.name.split('-')[0]+"@s.whatsapp.net").split('@')[0] : 
									getAuthor(model.jid)==model.jid
                chatItemMenu.open()
                */
            }
        }
    }

    Column{
        anchors.fill: parent;
        spacing:0
        width:parent.width
        height:parent.height
        WANotify{
            id:wa_notifier
        }
        Item{
            width:parent.width
            height:parent.height-wa_notifier.height
            visible:false;
            id:no_data

            Label{
                anchors.centerIn: parent;
                text: qsTr("No conversations yet")
                font.pointSize: 22
				color: "gray"
                width:parent.width
                horizontalAlignment: Text.AlignHCenter
            }
        }

        ListView {
            id: chatsList
            //anchors.fill: parent
            width:parent.width
            height:parent.height-wa_notifier.height
            model: conversationsModel
            delegate: chatsDelegate
            spacing: 1
            clip:true
            cacheBuffer: 10000
        }
    }

	Menu {
	id: chatItemMenu

		MenuLayout {
            WAMenuItem {
				height: 80
                //UNCOMMENTME singleItem: !detailsMenuItem.visible
				text: qsTr("Delete Conversation")
				onClicked: chatDelConfirm.open()
			}
            /*UNCOMMENTME
			MyMenuItem {
				id: detailsMenuItem
				visible: showContactDetails
				height: visible ? 80 : 0
				text: contactNumberGroup ? qsTr("Add group owner to contacts") : qsTr("Add to contacs")
				onClicked: Qt.openUrlExternally("tel:"+contactNumber)
			}
            */
		}
	}

    QueryDialog {
        id: chatDelConfirm
        property string cid_confirm;
        titleText: qsTr("Confirm Delete")
        message: qsTr("Are you sure you want to delete this conversation and all its messages?")
        acceptButtonText: qsTr("Yes")
        rejectButtonText: qsTr("No")
        onAccepted: {
            deleteConversation(cid_confirm)
            removeChatItem(cid_confirm)
        }
    }
}
