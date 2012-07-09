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
    signal deleteConversation(string jid);

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
    function removeChatItem(jid){

        var chatItemIndex = findChatIem(jid);
        console.log("deleting")
        if(chatItemIndex >= 0){
            var conversation = conversationsModel.get(chatItemIndex).conversation;
            var contacts = conversation.getContacts();

            for(var i=0; i<contacts.length; i++){

                contacts[i].unsetConversation();
            }

            delete conversation;

            conversationsModel.remove(chatItemIndex);

            if(conversationsModel.count == 0){
                //chatsContainer.state="no_data";
            }
        }
    }

    function findChatIem(jid){
        for (var i=0; i<conversationsModel.count;i++)
        {
            var chatItem = conversationsModel.get(i);

            if(chatItem.conversation.jid == jid)
                   return  i;
        }
        return -1;
    }

    function findConversation(jid){

        var chatItemIndex = findChatIem(jid);

        if(chatItemIndex >= 0)
            return conversationsModel.get(chatItemIndex).conversation;

        return 0
    }

    states: [
        State {
            name: "no_data"
            PropertyChanges {
                target: no_data
                visible:true
            }
        }
    ]

    ListModel{id:conversationsModel}

    Component{
        id:chatsDelegate;

        Chat{
            Component.onCompleted: {
                setConversation(model.conversation);
            }

            width:chatsContainer.width
            onOptionsRequested: {
                chatMenu.jid = getConversation().jid;

                if(!isGroup){
                    chatMenu.number = getConversation().getContacts()[0].contactNumber;
                    chatMenu.name =  getConversation().getContacts()[0].contactName;
                }
                else
                    chatMenu.number = "";

                chatMenu.open();
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
        id: chatMenu
        property string name;
        property string jid;
        property string number;

        MenuLayout {

            WAMenuItem {
                id: detailsMenuItem
                visible: chatMenu.number?true:false
                height: visible ? 80 : 0
                text: chatMenu.name?qsTr("View contact"):qsTr("Add to contacts")
                onClicked: Qt.openUrlExternally("tel:"+chatMenu.number);
            }

            WAMenuItem {
                height: 80
                singleItem: !detailsMenuItem.visible
                text: qsTr("Delete Conversation")
                onClicked: chatDelConfirm.open()
            }


        }
	}

    QueryDialog {
        id: chatDelConfirm
        titleText: qsTr("Confirm Delete")
        message: qsTr("Are you sure you want to delete this conversation and all its messages?")
        acceptButtonText: qsTr("Yes")
        rejectButtonText: qsTr("No")
        onAccepted: {
            deleteConversation(chatMenu.jid)
            removeChatItem(chatMenu.jid)
        }
    }
}
