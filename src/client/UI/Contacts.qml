/***************************************************************************
**
** Copyright (c) 2012, Tarek Galal <tarek@wazapp.im>
**
** This file is part of Wazapp, an IM application for Meego Harmattan
** platform that allows communication with Whatsapp users.
**
** Wazapp is free software: you can redistribute it and/or modify it under
** the terms of the GNU General Public License as published by the
** Free Software Foundation, either version 3 of the License, or
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

import "contacts.js" as ContactsManager
import "Global.js" as Helpers

Page {
    id: contactsContainer
   // tools: commonTools
    //width: parent.width
    //anchors.fill: parent
      Component.onCompleted: {
                ContactsManager.populateContacts();
           // contactsContainer.newMessage({data:"Hi","user_id":"201006960035"})
     }

      state:"no_data"

      property alias indicator_state:wa_notifier.state

      states: [
          State {
              name: "no_data"
              PropertyChanges {
                  target: no_data
                  visible:true
              }
          }
      ]



    // signal conversationUpdated(int msgId, int msgType, string user_id,string lastMsg,string time,string formattedDate);
     signal conversationUpdated(variant message);
     signal sendMessage(string user_id, string message);
     signal sendTyping(string user_id);
     signal sendPaused(string user_id);


      function deleteConversation(cid){
          for(var i =0; i<ContactsManager.chats.length; i++)
          {
              if(ContactsManager.chats[i].user_id == cid)
              {
                  delete ContactsManager.chats[i]
                  ContactsManager.chats.splice(i,1);
                  break;
              }

          }
      }

     function openChatWindow(user_id)
     {

         //var chatWindow = ContactsManager.openChatWindow(user_id,"contacts")
          var chatWindow = getChatWindow(user_id);
          appWindow.pageStack.push(chatWindow.conversation);
          //appWindow.requestPresence(user_id);
          return chatWindow

     }

    function onMessageSent(message){

          var chatWindow = getChatWindow(message.Contact.jid);
          if(chatWindow)chatWindow.conversation.messageSent(message.id);
    }

    function onMessageDelivered(message){
          var chatWindow = getChatWindow(message.Contact.jid);
          if(chatWindow)chatWindow.conversation.messageDelivered(message.id);
    }

      function clearConversations(){
        ContactsManager.chats = new Array();
      }

     function pushContacts(contacts)
     {
        //console.log("AHOM"+contacts)

        ContactsManager.contacts=contacts;

        ContactsManager.populateContacts();
     }

      function getChatWindow(user_id)
      {

          var chatWindow = ContactsManager.getChatWindow(user_id);
          if(chatWindow == 0)
          {
              console.log("couldn't find chat window")
              var contactData = ContactsManager.getContactData(user_id)

              chatWindow = ContactsManager.createChatWindow(user_id, contactData.name,contactData.picture);

          }

          console.log("found chat window")
          console.log(user_id)
         // console.log(chatWindow.conversation.user_id);

          return chatWindow;
      }

      function onAvailable(user_id){
          var chatWindow = getChatWindow(user_id);
          chatWindow.conversation.setOnline();
      }

      function onUnavailable(user_id,seconds){
          var chatWindow = getChatWindow(user_id);

          if(seconds)
              chatWindow.conversation.setOffline(seconds);
          else
              chatWindow.conversation.setOffline();

      }

      function onTyping(user_id){
          var chatWindow = getChatWindow(user_id);
          chatWindow.conversation.setTyping();

      }

      function onPaused(user_id){
          var chatWindow = getChatWindow(user_id);
          chatWindow.conversation.setPaused();
      }

     function addMessage(user_id,messages){

          var chatWindow = getChatWindow(user_id);


          for (var i =0; i< messages.length; i++)
          {
              chatWindow.conversation.newMessage(messages[i])
          }


      }

    function newMessage(msg_data){

        var chatWindow = getChatWindow(msg_data.user_id);
        chatWindow.conversation.newMessage(msg_data);
    }

    ListModel{

        id:contactsModel


    }

    Component{
        id:myDelegate
        Contact{

            jid:model.jid
            number:model.number
            picture:model.picture
            name:model.name;
            status:model.status?model.status:""
			myData: model

            //onClicked: {ContactsManager.openChatWindow(model.number,"contacts");contactsContainer.parent.parent.state="conversation"}
            onClicked: {openChatWindow(model.jid)}
        }
    }
    Component {
           id: sectionHeading
           Rectangle {
               width: parent.width
               height: 50
              // color: "#e6e6e6"
               color:"transparent"

				Rectangle {
					id: divline
                    anchors.verticalCenter: parent.verticalCenter
					anchors.leftMargin: 16
					anchors.left: parent.left
					anchors.rightMargin: 16
					anchors.right: sectionLabel.left
					height: 1
					color: "gray"
					opacity: 0.6
				}
				Text {
					id: sectionLabel
					text: section
					font.pointSize: 18
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
					anchors.right: parent.right
					anchors.rightMargin: 16
					color: "gray"
				}
               /*Text {
                   text: section
                   font.pixelSize: 42
                   font.bold: true
                   color:"#27a01b"
                   anchors.verticalCenter: parent.verticalCenter
                   horizontalAlignment: Text.AlignRight
                   width:parent.width-5
               }*/
		
           }
       }

    Rectangle {
        anchors.fill: parent;
        width:parent.width
        height:parent.height
		color: "transparent"

        WANotify{
			anchors.top: parent.top
            id:wa_notifier
        }

        Item{
            width:parent.width
            height:parent.height-wa_notifier.height
            visible:false;
            id:no_data

            Label{
                anchors.centerIn: parent;
                text:"No contacts yet. Try to resync"
                font.pointSize: 20
                width:parent.width
                horizontalAlignment: Text.AlignHCenter
            }
        }

        ListView {
            id: list_view1
            anchors.top: wa_notifier.botttom
            width:parent.width
            height:parent.height-wa_notifier.height
            clip: true
            model: contactsModel
            delegate: myDelegate
            spacing: 1
            section.property: "alphabet"
            section.criteria: ViewSection.FirstCharacter
            section.delegate: sectionHeading
			highlightFollowsCurrentItem: false
			Component.onCompleted: fast.listViewChanged()
        }

	FastScroll {
	    id: fast
	    listView: list_view1
	}

    }

    /*SectionScroller{
        listView: list_view1
    }*/



}
