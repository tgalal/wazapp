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
import "../common/js/Global.js" as Helpers
import "js/contact.js" as ContactHelper
import "../common"

Item{
    id:container

    property string jid;
    property string picture;
    property string defaultPicture:"../common/images/user.png"
    property string contactPicture:getPicture()
    property string contactName;
    property string contactShowedName;
    property string contactStatus;
    property string contactNumber;
	//property bool isVisible
	//property bool isNew: false

    signal clicked();
	signal optionsRequested()

    width: parent.width;
    //color:"transparent"
	clip: true

	/*onIsVisibleChanged: {
		if (isVisible && isNew) {
			isNew = false
			newContacts = newContacts-1
		}
	}*/

    function openProfile(){
        if(contactProfileLoader.progress==0)
            contactProfileLoader.sourceComponent = contactProfileComponent

        appWindow.pageStack.push(contactProfileLoader.item)
    }

    function unsetConversation(){
        ContactHelper.conversation = false;
    }

    function setConversation(c){
        ContactHelper.conversation=c;
    }

    function getConversation(){
        return ContactHelper.conversation;
    }

    function getPicture(){
        if(!picture || picture == "none")
            return defaultPicture;

        return picture;
    }

	Connections {
		target: appWindow
        /*onOnContactPictureUpdated: {
			if (jid == ujid) {
				contact_picture.imgsource = ""
				contact_picture.imgsource = getPicture()
			}
        }*/
	}

	Rectangle {
		anchors.fill: parent
		color: theme.inverted? "darkgray" : "lightgray"
		opacity: theme.inverted? 0.2 : 0.8
		visible: mouseArea.pressed
	}

    MouseArea{
        id:mouseArea
        anchors.fill: parent
		onPressAndHold: container.optionsRequested()
        onClicked:{
            consoleDebug("CLICKED");
			consoleDebug("OPENING CONTACT FOR CONVERSATION: " + jid)

            /*if(ContactHelper.conversation){
                //ContactHelper.conversation.jid="sdgsg-fsdfsdf"
                ContactHelper.conversation.open()
             }else{*/
                consoleDebug("CONTACT: NOT FOUND")
				container.clicked() // Needed to clear quick search
                ContactHelper.conversation = waChats.getOrCreateConversation(jid);
                setConversation(ContactHelper.conversation)
                ContactHelper.conversation.addContact(container);
                ContactHelper.conversation.open();
            //}
        }
    }

    Row
    {
        anchors.fill: parent
        spacing: 12
        anchors.topMargin: 10
        anchors.leftMargin: 10
		height: 62
		anchors.verticalCenter: parent.verticalCenter

        RoundedImage {
            id:contact_picture
            size:62
            imgsource: contactPicture
            opacity: 1
            anchors.topMargin: -2
			y: -1
			//onClicked: mouseArea.clicked()
        }

		Column{
			width: parent.width -80 - (userblocked.visible? 54 : 0) 
			y: contact_status.visible? 0 : 14
			Label {
				y: 2
				id: contact_name
				text:contactShowedName
				font.pointSize: 18
				elide: Text.ElideRight
				width: parent.width -16
				font.bold: true
				//color: isNew? "green" : (theme.inverted? "white":"black")
			}
			Label {
				id:contact_status
				text: Helpers.emojify(contactStatus)
				font.pixelSize: 20
				color: "gray"
				width: parent.width -16
				elide: Text.ElideRight
				height: 24
				clip: true
				visible: contactStatus!==""
			}
		}

		Image {
			id: userblocked
	        anchors.verticalCenter: contact_picture.verticalCenter
	        width: 28
	        height: 28
	        smooth: true
	        source: "../common/images/blocked.png"
			visible: blockedContacts.indexOf(jid)>-1
		}
    }

    Component {
        id:contactProfileComponent
        ContactProfile{
            id:contactProfile
            contactName: container.contactName
            contactNumber: container.contactNumber
            contactPicture: container.picture
            contactStatus: container.contactStatus
            contactJid: container.jid
        }
    }

    Loader{
        id:contactProfileLoader
    }

}
