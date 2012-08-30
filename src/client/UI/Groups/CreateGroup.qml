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
import "../common/js/Global.js" as Helpers
import "../Contacts/js/contact.js" as ContactHelper
import "../common"
import "../EmojiDialog"

WAPage {

	id: content

	property bool creatingGroup: false
	signal emojiSelected(string emojiCode);

    Component.onCompleted: {
		selectedGroupPicture = "/opt/waxmppplugin/bin/wazapp/UI/common/images/group.png"
        status_text.forceActiveFocus();
		participantsModel.clear()
    }

	function cleanText(txt) {
        var repl = "p, li { white-space: pre-wrap; }";
        var res = txt;
        res = Helpers.getCode(res);
        res = res.replace(/<[^>]*>?/g, "").replace(repl,"");
        return res.replace(/^\s+/,"");
	}	

	tools: statusTool

    Emojidialog{
        id:emojiDialog

        Component.onCompleted: {
            emojiDialog.emojiSelected.connect(content.emojiSelected);
        }

    }


	Connections {
		target: content
		onEmojiSelected: {
		    consoleDebug("GOT EMOJI "+emojiCode);

		   	var str = cleanText(status_text.text)
			var pos = str.indexOf("&quot;")
			var newPosition = status_text.lastPosition
			while(pos>-1 && pos<status_text.lastPosition) {
				status_text.lastPosition = status_text.lastPosition +5
				pos = str.indexOf("&quot;", pos+1)
			}
			pos = str.indexOf("&amp;")
			while(pos>-1 && pos<status_text.lastPosition) {
				status_text.lastPosition = status_text.lastPosition +4
				pos = str.indexOf("&amp;", pos+1)
			}

			var emojiImg = '<img src="/opt/waxmppplugin/bin/wazapp/UI/common/images/emoji/20/emoji-E'+emojiCode+'.png" />'
			str = str.substring(0,status_text.lastPosition) + cleanText(emojiImg) + str.slice(status_text.lastPosition)
			status_text.text = Helpers.emojify2(str)
			status_text.cursorPosition = newPosition + 1
			status_text.forceActiveFocus()
		}
    }


	Component {
		id: participantsDelegate

		Rectangle
		{
			height: 80
			width: appWindow.inPortrait? 464:838
			color: "transparent"
			clip: true

			property int cindex: model.index

		    RoundedImage {
				x: 16
		        size:62
		        imgsource: contactPicture
		        opacity: 1
				y: 8
		    }

		    Column{
				y: 9
				x: 90
				width: parent.width -100
				anchors.verticalCenter: parent.verticalCenter
				Label{
					y: 2
		            text: contactName
				    font.pointSize: 18
					elide: Text.ElideRight
					width: parent.width -56
					font.bold: true
				}
				Label{
		            text: Helpers.emojify(contactStatus)
				    font.pixelSize: 20
				    color: "gray"
					width: parent.width -56
					elide: Text.ElideRight
					height: 24
					clip: true
					visible: contactStatus!==""
			   }

		    }

			BorderImage {
				id: removeButton
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

    Flickable {
        id: flickArea
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: column1.height -60 //Fucking listview!

        Column {
            id: column1
            width: parent.width
            spacing: 16

			WAHeader{
				title: qsTr("Create group")
				width:parent.width
				height: 73
			}

			Row {
				width: parent.width
				height: 80
				spacing: 10
				x: 16

				RoundedImage {
					id: picture
					size: 80
					height: size
					width: size
					imgsource: selectedGroupPicture
				}

				Button {
					id: picButton
					height: 50
					width: parent.width -32 - 90
					anchors.verticalCenter: parent.verticalCenter
					font.pixelSize: 22
					text: qsTr("Select picture")
					onClicked: pageStack.push (Qt.resolvedUrl("SelectPicture.qml"))
				}



			}

			Separator {
				x: 16
				width:parent.width -32
			}

		    Label {
				x: 16
		        color: theme.inverted ? "white" : "black"
		        text: qsTr("Group subject")
		    }

		    WATextArea {
				id: status_text
				x: 16
				width:parent.width -32
				wrapMode: TextEdit.Wrap
				//textFormat: Text.RichText
				textColor: "black"
				/*onActiveFocusChanged: { 
					lastPosition = status_text.cursorPosition 
					consoleDebug("LAST POSITION: " + lastPosition)
				}*/
			}

			/*Rectangle {
				id: input_button_holder
				anchors.left: parent.left
				width: parent.width
				height: 50
				color: "transparent"
				clip: true
						
				Button
				{
					id:emoji_button
					//platformStyle: ButtonStyle { inverted: true }
					width:50
					height:50
		            iconSource: "../common/images/emoji/32/emoji-E415.png"
					anchors.left: parent.left
					anchors.leftMargin: 0
					anchors.verticalCenter: send_button.verticalCenter
					onClicked: emojiDialog.openDialog()
				}

	
				Button
				{
					id:send_button
					platformStyle: ButtonStyle { inverted: true }
					width:160
					height:50
					text: qsTr("Done")
					anchors.right: parent.right
					anchors.rightMargin: 0
					//enabled: cleanText(status_text.text).trim() !=""
					y: 0
					onClicked:{
						var toSend = cleanText(status_text.text);
						toSend = toSend.trim();
						if ( toSend != "")
						{
							changeStatus(toSend);
							pageStack.pop()
						}
					}
				}
			}*/
			
			Separator {
				x: 16
				width:parent.width -32
			}

			Rectangle {
				x: 16
				width: parent.width -32
				height: 60
				color: "transparent"

				Label {
					width: parent.width - 60
				    color: theme.inverted ? "white" : "black"
				    text: qsTr("Group participants")
					font.bold: true
					anchors.verticalCenter: addButton.verticalCenter
				}

				BorderImage {
					id: addButton
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
						onClicked: pageStack.push (Qt.resolvedUrl("AddContacts.qml"))
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
			}

		}

	}
    
	ToolBarLayout {
        id:statusTool

        ToolIcon{
			enabled: !creatingGroup
            platformIconId: "toolbar-back"
       		onClicked: pageStack.pop()
        }

        ToolButton
        {
			id: createButton
			anchors.horizontalCenter: parent.horizontalCenter
			width: 300
            text: qsTr("Create")
			enabled: status_text.text!=="" && participantsModel.count>0 && !creatingGroup
            onClicked: {
				creatingGroup = true
				createGroupChat(status_text.text)

				/*var participants;
				for (var i=0; i<participantsModel.count; ++i) {
					if (participantsModel.get(i).contactJid)
						participants = participants + (participants!==""? ",":"") + participantsModel.get(i).contactJid;
				}
				consoleDebug("NOW ADD PARTICIPANTS: " + participants)
				groupId = "5491133302246-1342011766@g.us"
				addParticipants(groupId,participants)*/
			}
        }
       
    }

    function setConversation(c){
        ContactHelper.conversation=c;
    }

	Connections {
		target: appWindow
		onGroupCreated: {
			setPicture(groupId, selectedGroupPicture)
		}
		onOnContactUpdated: {
			if (groupId == ujid) {
				var participants;
				for (var i=0; i<participantsModel.count; ++i) {
					if (participantsModel.get(i).contactJid!="undefined")
						participants = participants + (participants!==""? ",":"") + participantsModel.get(i).contactJid;
				}
				addParticipants(groupId,participants)
			}
		}
		onAddedParticipants: {
			//pageStack.pop()
            openConversation(groupId);
			getGroupInfo(groupId)
		}
	}

}
