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

import "contacts.js" as ContactsManager
import "Global.js" as Helpers

Page {
    id: contactsContainer
   // tools: commonTools
    //width: parent.width
    //anchors.fill: parent

	orientationLock: myOrientation==2 ? PageOrientation.LockLandscape:
			myOrientation==1 ? PageOrientation.LockPortrait : PageOrientation.Automatic

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

    function onMessageSent(message_id,jid){

          var chatWindow = getChatWindow(jid);
          if(chatWindow)chatWindow.conversation.messageSent(message_id);
    }

    function onMessageDelivered(message_id,jid){
          var chatWindow = getChatWindow(jid);
          if(chatWindow)chatWindow.conversation.messageDelivered(message_id);
    }

      function onMediaTransferProgressUpdated(progress,jid,message_id){
          var chatWindow = getChatWindow(jid);

          if(chatWindow)chatWindow.conversation.mediaTransferProgressUpdated(progress,message_id);
      }

      function onMediaTransferSuccess(jid,message_id,mediaObject){
          var chatWindow = getChatWindow(jid);
          console.log("Caught transfer success in contacts")
          if(chatWindow)chatWindow.conversation.mediaTransferSuccess(message_id,mediaObject);
      }

      function onMediaTransferError(jid,message_id,mediaObject){
          var chatWindow = getChatWindow(jid);

          if(chatWindow)chatWindow.conversation.mediaTransferError(message_id,mediaObject);


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

    function hideSearchBar() {
        searchbar.h1 = 71
        searchbar.h2 = 0
        searchbar.height = 0
        searchInput.enabled = false
        sbutton.enabled = false
        searchInput.text = ""
        searchInput.focus = false
		list_view1.forceActiveFocus()
        timer.stop()
    }

    function showSearchBar() {
        searchbar.h1 = 0
        searchbar.h2 = 71
        searchbar.height = 71
        searchInput.enabled = true
        sbutton.enabled = true
        searchInput.text = ""
        searchInput.focus = false
        list_view1.forceActiveFocus()
        timer.start()
    }

    function replaceText(text,str) {
        var ltext = text.toLowerCase()
        var lstr = str.toLowerCase()
        var ind = ltext.indexOf(lstr)
        var txt = text.substring(0,ind)
        text = txt + "<u><font color=#4591FF>" +
               text.slice(ind,ind+str.length)  + "</font></u>" +
               text.slice(ind+str.length,text.length);
        return text;
    }


    Timer {
        id: timer
        interval: 5000
        onTriggered: {
            if (searchInput.text==="") hideSearchBar()
        }
    }

    Component{
        id:myDelegate

        Contact{
			property bool filtered: model.name.match(new RegExp(searchInput.text,"i")) != null
            height: filtered ? 80 : 0
			visible: height!=0
			jid:model.jid
            number:model.number
            picture:model.picture
            name: searchInput.text.length>0 ? replaceText(model.name, searchInput.text) : model.name
            status:model.status?model.status:""
			myData: model

            onClicked: {
				openChatWindow(model.jid)
				hideSearchBar()
				list_view1.positionViewAtBeginning()
				if(searchbar.height==71) searchInput.platformCloseSoftwareInputPanel()
			}
        }
    }

    WANotify{
		anchors.top: parent.top
        id:wa_notifier
    }

	Rectangle {
		id: searchbar
		width: parent.width
		height: 0
		anchors.top: parent.top
		anchors.topMargin: wa_notifier.height
		color: "transparent"

		property int h1
		property int h2

		Rectangle {

			id: srect
			anchors.fill: searchbar
			anchors.leftMargin: 12
			anchors.rightMargin: 12
			anchors.top: searchbar.top
			anchors.topMargin: searchbar.height - 62
			anchors.bottomMargin: 2
			color: "transparent"

			TextField {
			    id: searchInput
			    inputMethodHints: Qt.ImhNoPredictiveText
			    placeholderText: qsTr("Quick search")
			    anchors.top: srect.top
			    anchors.left: srect.left
			    width: parent.width
			    enabled: false
			    onTextChanged: timer.restart()
			}

			Image {
			    id: sbutton
			    smooth: true
			    anchors.top: srect.top
			    anchors.topMargin: 1
			    anchors.right: srect.right
			    anchors.rightMargin: 4
			    height: 52
			    width: 52
			    enabled: false
			    source: searchInput.text==="" ? "image://theme/icon-m-common-search" : "image://theme/icon-m-input-clear"
			    MouseArea {
			        anchors.fill: parent
			        onClicked: {
			            searchInput.text = ""
			            searchInput.forceActiveFocus()
			        }
			    }
			}

		}

		onHeightChanged: SequentialAnimation {
			PropertyAction { target: searchbar; property: "height"; value: searchbar.h1 }
			NumberAnimation { target: searchbar; property: "height"; to: searchbar.h2; duration: 300; easing.type: Easing.InOutQuad }
		}

        states: [
            State {
                name: 'hidden'; when: searchbar.height == 0
                PropertyChanges { target: searchbar; opacity: 0; }
            },
            State {
                name: 'showed'; when: searchbar.height == 71
                PropertyChanges { target: searchbar; opacity: 1; }
            }
        ]
        transitions: Transition {
            NumberAnimation { properties: "opacity"; easing.type: Easing.InOutQuad; duration: 300 }
        }


	}

    Rectangle {
        anchors.top: parent.top
		anchors.topMargin: wa_notifier.height + searchbar.height
        width:parent.width
        height:parent.height - wa_notifier.height - searchbar.height
		color: "transparent"
		clip: true

        Item{
        	anchors.fill: parent
            visible:false;
            id:no_data

            Label{
                anchors.centerIn: parent;
                text: qsTr("No contacts yet. Try to resync")
                font.pointSize: 20
                width:parent.width
                horizontalAlignment: Text.AlignHCenter
            }
        }

        ListView {
            id: list_view1
			anchors.fill: parent
            clip: true
            model: contactsModel
            delegate: myDelegate
            spacing: 1
			cacheBuffer: 10000
			highlightFollowsCurrentItem: false
            section.property: "alphabet"
            section.criteria: ViewSection.FirstCharacter

            section.delegate: GroupSeparator {
				anchors.left: parent.left
				anchors.leftMargin: 16
				width: parent.width - 44
				height: searchInput.text==="" ? 50 : 0
				title: section
			}

			Component.onCompleted: fast.listViewChanged()

            onContentYChanged:  {
                if ( list_view1.visibleArea.yPosition < 0)
                {
                    if ( searchbar.height==0 )
                        showSearchBar()
                }
            }
        }

		FastScroll {
			id: fast
			listView: list_view1
			enabled: searchInput.text===""
		}

    }


}
