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

import "chats.js" as ChatScript
import "contacts.js" as ContactsScript
import "Global.js" as Helpers
Page {
    Component.onCompleted: ChatScript.importChats()
   // tools: commonTools
   // anchors.fill: parent

    id: chatsContainer
    property alias indicator_state:wa_notifier.state

	orientationLock: myOrientation==2 ? PageOrientation.LockLandscape:
			myOrientation==1 ? PageOrientation.LockPortrait : PageOrientation.Automatic

    state:"no_data"

    signal clicked(string number,string prev_state)
    signal deleteConversation(string conv_id);

    function setContacts(contacts){
        ContactsScript.contacts = contacts;
    }

    function onMessageSent(msg_id){
        var chatItemIndex = findChatItemIndex(msg_id);
        if(chatItemIndex>=0){
            var chatItem = chatsModel.get(chatItemIndex);


              //chatsModel.remove(chatItemIndex);
             //chatsModel.insert(chatItemIndex,chatItem);
            //chatsModel.set(chatItemIndex,chatItem)

            chatItem.status = 1

        }


    }


    function removeChatItem(cid){
        for (var i=0; i<chatsModel.count;i++)
        {
            console.log("deleting")
            var chatItem = chatsModel.get(i);
            console.log(chatItem.jid);
            if(chatItem.jid == cid)
            {
                chatsModel.remove(i)
                if(chatsModel.count == 0){
                    chatsContainer.state="no_data";
                }

                return;
            }
        }
    }

    function clearChats(){
        chatsModel.clear();
    }

    function onMessageDelivered(msg_id){
        var chatItemIndex = findChatItemIndex(msg_id);
        if(chatItemIndex>=0){
            var chatItem = chatsModel.get(chatItemIndex);

            chatItem.status = 2
        }
    }

    function findChatItemIndex(msg_id){

        for (var i=0; i<chatsModel.count;i++)
        {
            var chatItem = chatsModel.get(i);
            console.log(chatItem.id);
            if(chatItem.id == msg_id)
                   return i
        }
        return -1
    }




    //function updateConversation(msg_id,msgType,user_id, lastMsg,time,formattedDate)
    function updateConversation(msg)
    {

        var lastMsg = msg.content

        var tmp = lastMsg.split('\n');

        lastMsg = tmp[0];

        var maxLength = screen.currentOrientation == Screen.Portrait?30:100

        if(tmp.length>1){
            lastMsg += "..."
        }else if(lastMsg.length > maxLength){
            lastMsg = lastMsg.substring(0,maxLength).trim()+"...";
        }
        msg.content = lastMsg



       // ChatScript.updateChats(msg_id,msgType,user_id,lastMsg,time,formattedDate);
        ChatScript.updateChats(msg);
        chatsContainer.state=""
       // chatScript.sendMessage({'chatsModel':chatsModel});
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

	function getAuthor(inputText) {
		var resp;
		resp = inputText.split('@')[0];
		for(var i =0; i<contactsModel.count; i++)
		{
            var item = contactsModel.get(i).jid;
		    if(item == inputText)
		        resp = contactsModel.get(i).name;
		}
		return resp;
	}

	function getUnreadMessages(uname) {
		var res = "0"
		for(var i =0; i<unreadModel.count; i++)
		{
			if (unreadModel.get(i).name==uname) {
				res = parseInt(unreadModel.get(i).val)
				break;
	 		}
		}
		return res;
	}

    ListModel{
        id:chatsModel
    }

    Component{
        id:myDelegate;

        Chat{
            property variant contactInfo:ContactsScript.getContactData(model.jid)
            picture: contactInfo.picture;
            name: contactInfo.name.indexOf("-")>0 ? 
					qsTr("Group (%1)").arg(getAuthor(contactInfo.name.split('-')[0]+"@s.whatsapp.net")) : contactInfo.name
			isGroup: contactInfo.name.indexOf("-")>0
			number:model.jid;
            lastMsg: Helpers.emojify(Helpers.linkify(model.content))
            time:model.timestamp
            formattedDate: Helpers.getDateText(model.formattedDate).replace("Today", qsTr("Today")).replace("Yesterday", qsTr("Yesterday"))
			unread_messages: getUnreadMessages(model.jid)
            onClicked: {
				chatsContainer.clicked(model.jid,"chats")

				for(var i=0; i<unreadModel.count; i++)
				{
					if (unreadModel.get(i).name==model.jid) {
						unreadModel.get(i).val = 0
						break;
				 	}
				}
				updateUnreadCount()

			}
            width:chatsContainer.width
            msgId: model.id
            msgType:model.type
            state_status:model.status

            onOptionsRequested: {
                chatDelConfirm.cid_confirm = model.jid;
                chatItemMenu.open()
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
            id: list_view1
            //anchors.fill: parent
            width:parent.width
            height:parent.height-wa_notifier.height
            model: chatsModel
            delegate: myDelegate
            spacing: 1
            clip:true
        }
    }

    Menu {
        id: chatItemMenu

            MenuLayout {

            MenuItem{
                text:qsTr("Delete Conversation")
                onClicked:{
                    chatDelConfirm.open()

                }
          }
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
