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
import "../Chats/js/chat.js" as ChatHelper
import "../common/js/Global.js" as Helpers
import "../common"
import "../common/js/createobject.js" as ObjectCreator

WAPage {
    id:container

	//anchors.fill: parent

	property string groupSubject
	property string groupDate
	property string groupPicture: "../common/images/group.png"
	property string groupOwner
	property string groupOwnerJid
	property string groupSubjectOwner
	property bool working: false

    tools: ToolBarLayout {
        id: toolBar
        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
			enabled: !working
        }
        ToolButton
        {
			width: 300
            text: qsTr("Save changes")
			visible: myAccount==groupOwnerJid
			anchors.verticalCenter: parent.verticalCenter
			anchors.horizontalCenter: parent.horizontalCenter
			enabled: !working
            onClicked: {
				working = true
				var participants;
				var removeparticipants;
				for (var i=0; i<participantsModel.count; ++i) {
					if (participantsModel.get(i).contactJid!="undefined" && participantsModel.get(i).contactJid!=myAccount)
						participants = participants + (participants!==""? ",":"") + participantsModel.get(i).contactJid;
				}
				consoleDebug("CURRENT PARTICIPANTS: "+participants)
				for (var i=0; i<partModel.count; ++i) {
					if ( participants.indexOf(partModel.get(i).contactJid)==-1 && partModel.get(i).contactJid!=myAccount )
						removeparticipants = removeparticipants + (removeparticipants!==""? ",":"") + partModel.get(i).contactJid;
				}
				consoleDebug("REMOVING PARTICIPANTS: "+removeparticipants)

				removeParticipants(profileUser,removeparticipants)
			}
        }

    }

	Component.onCompleted: {
		selectedContacts = ""
		participantsModel.clear()
		partModel.clear()
		getInfo()
	}


	function getInfo() {
		var c = waChats.getOrCreateConversation(profileUser);
        groupPicture = c.picture
		groupSubject = c.subject
		getGroupInfo(profileUser)
		getGroupParticipants(profileUser)
	}


    function getAuthor(inputText) {
		if (inputText==myAccount)
			return qsTr("You")
        var resp = inputText;
        for(var i =0; i<contactsModel.count; i++)
        {
            if(resp == contactsModel.get(i).jid)
                resp = contactsModel.get(i).name;
        }
        return resp
    }

	function getDateTime(mydate) {
		var date = new Date(mydate)
		var check = Qt.formatDateTime(date, "dd-MM-yyyy | HH:mm");
		return check;
	}

	function getCurrentContacts() {
		for (var i=0; i<participantsModel.count; ++i) {
			selectedContacts = selectedContacts + (selectedContacts!==""? ",":"") + participantsModel.get(i).contactJid;
		}
	}

	Connections {
		target: appWindow
	
		onGroupInfoUpdated: {
			if (gdata=="ERROR") {
				groupOwner = ""
				groupOwnerJid = ""
				groupDate = ""
				groupSubjectOwner = ""
				partText.text = qsTr("Error reading group information")
			} else {
				var data = gdata.split("<<->>")
				groupSubject = data[2] 
				groupOwner = getAuthor(data[1]).split('@')[0]
				groupOwnerJid = data[1]
				groupDate = getDateTime(parseInt(data[5])*1000)
				groupSubjectOwner = qsTr("Subject created by") + " " + getAuthor(data[3]).split('@')[0]
				partText.text = qsTr("Group participants:")
				getPicture(profileUser, "image")
			}
		}

		onGroupParticipants: { 
			var list = groupParticipantsIds.split(",")
			//consoleDebug("PARTICIPANTS: " + list)
		    for(var i =0; i<contactsModel.count; i++) {
		        if( list.indexOf(contactsModel.get(i).jid)>-1 ) {
					list.splice(list.indexOf(contactsModel.get(i).jid),1)
					
					participantsModel.append({"contactPicture":contactsModel.get(i).picture,
					"contactName":contactsModel.get(i).name,
					"contactStatus":contactsModel.get(i).status,
					"contactJid":contactsModel.get(i).jid})

					partModel.append({"contactPicture":contactsModel.get(i).picture,
					"contactName":contactsModel.get(i).name,
					"contactStatus":contactsModel.get(i).status,
					"contactJid":contactsModel.get(i).jid})
				}
		    }
			consoleDebug("PARTICIPANTS: " + list)
			for (var i=0; i<list.length; i++) {
				participantsModel.append({"contactPicture":"../common/images/user.png",
				"contactName":list[i].split('@')[0],
				"contactStatus":"",
				"contactJid":list[i]})

				partModel.append({"contactPicture":"../common/images/user.png",
				"contactName":list[i].split('@')[0],
				"contactStatus":"",
				"contactJid":list[i]})
			}
			
		}

		onRemovedParticipants: {
			var participants;
			for (var i=0; i<participantsModel.count; ++i) {
				if (participantsModel.get(i).contactJid!="undefined")
					participants = participants + (participants!==""? ",":"") + participantsModel.get(i).contactJid;
			}
			addParticipants(profileUser,participants)
		}

		onAddedParticipants: {
			participantsModel.clear()
			partModel.clear()
			getGroupParticipants(profileUser)
			working = false
		}
		
		onOnContactPictureUpdated: {
			if (profileUser == ujid) {
				picture.imgsource = ""
				picture.imgsource = groupPicture
				bigImage.source = ""
				bigImage.source = groupPicture.replace(".png",".jpg").replace("contacts","profile")
			}
		}	

	}

	ListModel { id:partModel }


	Image {
		id: bigImage
		visible: false
		source: groupPicture.replace(".png",".jpg").replace("contacts","profile")
	}


    Flickable {
        id: flickArea
        anchors.fill: parent
		anchors.topMargin: 12
        contentWidth: parent.width
        contentHeight: column1.height -60 //Fucking listview!

        Column {
            id: column1
			width: parent.width
			anchors.left: parent.left
			anchors.leftMargin: 16
			anchors.rightMargin: 16
			anchors.topMargin: 12
			spacing: 12

			Row {
				width: parent.width
				height: 80
				spacing: 10

				ProfileImage {
					id: picture
					size: 80
					height: size
					width: size
					imgsource: groupPicture
					onClicked: { 
						if (bigImage.height>0) {
							bigProfileImage = groupPicture.replace(".png",".jpg").replace("contacts","profile")
							//pageStack.push (Qt.resolvedUrl("../common/BigProfileImage.qml"))
							Qt.openUrlExternally(groupPicture.replace(".png",".jpg").replace("contacts","profile"))
						}
					}
				}

				Column {
					width: parent.width - picture.size -10
					anchors.verticalCenter: picture.verticalCenter

					Label {
						text: Helpers.emojify(groupSubject)
						font.bold: true
						font.pixelSize: 26
						width: parent.width
						elide: Text.ElideRight
					}

					Label {
						font.pixelSize: 20
						color: "gray"
						visible: groupSubjectOwner!==""
						text: groupSubjectOwner
						width: parent.width
						elide: Text.ElideRight
					}

				}
			}

			Separator {
				width: parent.width -32 
				height: 10
			}

			Label {
				width: parent.width - 60
			    color: theme.inverted ? "white" : "black"
			    text: qsTr("Group owner:") + " <b>" + (groupOwnerJid!=myAccount ? groupOwner : qsTr("You")) + "</b>"
			}

			Label {
				width: parent.width - 60
			    color: theme.inverted ? "white" : "black"
			    text: qsTr("Creation date:") + " " + groupDate
			}

			Separator {
				width: parent.width -32
				height: 10
			}

			Button {
				id: statusButton
				height: 50
				width: parent.width -32
				font.pixelSize: 22
				text: qsTr("Change group subject")
				enabled: !working && groupSubjectOwner!=""
				onClicked: pageStack.push(Qt.resolvedUrl("ChangeSubject.qml"))
			}

			Button {
				id: picButton
				height: 50
				width: parent.width -32
				font.pixelSize: 22
				text: qsTr("Change group picture")
				enabled: !working
				onClicked: pageStack.push(setProfilePicture)
			}

			Separator {
				width: parent.width -32
				height: 10
			}

			Rectangle {
				x: 0
				width: parent.width -32
				height: 60
				color: "transparent"

				Label {
					id: partText
					width: parent.width - 60
				    color: theme.inverted ? "white" : "black"
				    text: qsTr("Group participants:")
					font.bold: true
					anchors.verticalCenter: addButton.verticalCenter
				}

				BorderImage {
					id: addButton
					visible: myAccount==groupOwnerJid && !working
					width: labelText.paintedWidth + 32
					height: 42
					anchors.verticalCenter: parent.verticalCenter
					anchors.right: parent.right
					source: "image://theme/meegotouch-sheet-button-"+(theme.inverted?"inverted-":"")+
							"background" + (bcArea.pressed? "-pressed" : "")
					border { left: 22; right: 22; bottom: 22; top: 22; }
					Label { 
						id: labelText
						anchors.verticalCenter: parent.verticalCenter
						anchors.horizontalCenter: parent.horizontalCenter
						font.pixelSize: 22; font.bold: true
		                text: qsTr("Add")
					}
					MouseArea {
						id: bcArea
						anchors.fill: parent
						onClicked: {
							getCurrentContacts()
							pageStack.push (addContacts) 
						}
					}
				}				
 
			}


			ListView {
				id: participants
				width: parent.width
				interactive: false
				height: 80 + (participants.count *80) 
				model: participantsModel
				delegate: participantsDelegate
				clip: true
				visible: groupSubjectOwner!=""
			}



		}

	}

	function getUserAuthor(inputText) {
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


	Component {
		id: participantsDelegate

		Rectangle
		{
			height: 80
			width: parent.width -32
			color: "transparent"
			clip: true

			property int cindex: model.index

		    RoundedImage {
				x: 0
		        size:62
		        imgsource: contactPicture=="none" ? "../common/images/user.png" : contactPicture
		        opacity: 1
				y: 8
		    }

		    Column{
				y: 9
				x: 74
				width: parent.width -74
				anchors.verticalCenter: parent.verticalCenter
				Label{
					y: 2
		            text: getUserAuthor(contactName)
				    font.pointSize: 18
					elide: Text.ElideRight
					width: parent.width
					font.bold: true
				}
				Label{
		            text: Helpers.emojify(contactStatus)
				    font.pixelSize: 20
				    color: "gray"
					width: parent.width
					elide: Text.ElideRight
					height: 24
					clip: true
					visible: contactStatus!==""
			   }

		    }

			BorderImage {
				id: removeButton
				visible: myAccount==groupOwnerJid && !working && contactJid!=myAccount
				width: 42
				height: 42
				anchors.verticalCenter: parent.verticalCenter
				anchors.right: parent.right
				source: "image://theme/meegotouch-sheet-button-"+(theme.inverted?"inverted-":"")+
						"background" + (bcArea.pressed? "-pressed" : "")
				border { left: 22; right: 22; bottom: 22; top: 22; }
				Image {
					y: 2
					source: "image://theme/icon-m-toolbar-cancle"+(theme.inverted?"-white":"")
					anchors.verticalCenter: parent.verticalCenter
					anchors.horizontalCenter: parent.horizontalCenter
				}
				MouseArea {
					id: bcArea
					anchors.fill: parent
					onClicked: {
						consoleDebug("REMOVING " +contactJid)
						participantsModel.remove(cindex)
						var newSelectedContacts = selectedContacts
						newSelectedContacts = newSelectedContacts.replace(contactJid,"")
						newSelectedContacts = newSelectedContacts.replace(",,",",")
						selectedContacts = newSelectedContacts
					}
				}
			}

		}
	}

}
