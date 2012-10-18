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
import "../common/WAListView"
import "../Profile"
import "../EmojiDialog"

WAPage {

	id: content

	property string groupId
	property bool creatingGroup: false
    property string selectedPicture
    busy: creatingGroup

    state: (screen.currentOrientation == Screen.Portrait) ? "portrait" : "landscape"

    states: [
        State {
            name: "landscape"

            PropertyChanges{target:groupInfoContainer;  parent:rowContainer;  width:rowContainer.width/2}
            PropertyChanges { target: participantsColumn;  parent:rowContainer;  height:rowContainer.height; width:rowContainer.width/2}


        },
        State {
            name: "portrait"
            PropertyChanges{target:groupInfoContainer;  parent:columnContainer; width:columnContainer.width}
            PropertyChanges { target: participantsColumn; parent:columnContainer; height:content.height-groupInfoContainer.height; width:columnContainer.width}
        }
    ]

    Component.onCompleted: {
        //participantsModel.clear()
        //selectedContacts = ""

        subject_text.forceActiveFocus();

        genericSyncedContactsSelector.resetSelections()
        genericSyncedContactsSelector.unbindSlots()
        genericSyncedContactsSelector.positionViewAtBeginning()
    }

    onStatusChanged: {
        if(status == PageStatus.Activating){
            genericSyncedContactsSelector.tools = contactsTool
        } else if(status == PageStatus.Deactivating){
           // genericSyncedContactsSelector.tools = ""
        }
    }

    function getCurrentContacts() {
		for (var i=0; i<participantsModel.count; ++i) {
			selectedContacts = selectedContacts + (selectedContacts!==""? ",":"") + participantsModel.get(i).contactJid;
		}
	}

	tools: statusTool



    ListModel {
        id: participantsModel
    }


    Row{
        id:rowContainer
        anchors.fill: parent
        anchors.margins: 10
     }

    Column{
        id: columnContainer
        anchors.fill: parent
        anchors.margins: 10
        spacing:10
    }


    Column {
        id: groupInfoContainer
        spacing:12

        WAHeader{
            id:header
            title: qsTr("Create group")
            width:parent.width
            height: 73
        }
        Label {
            color: theme.inverted ? "white" : "black"
            text: qsTr("Group subject")
        }

        WATextArea {
            id: subject_text
            width:parent.width
            wrapMode: TextEdit.Wrap
            //textFormat: Text.RichText
            textColor: "black"
        }

        Separator {
            width:parent.width
        }

        Row {
            width: parent.width
            height: 80
            spacing: 10

            RoundedImage {
                id: picture
                size: 80
                height: size
                width: size
                imgsource: selectedPicture || "../"+defaultGroupPicture
            }

            Button {
                id: picButton
                height: 50
                width: parent.width - 10 - 80
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 22
                text: qsTr("Select picture")
                onClicked: pageStack.push(selectPicturePage)
            }
        }



        Separator {
            width:parent.width
        }
    }


    Item{
        id:participantsColumn

        Rectangle {
            id:participantsHeader
            width: parent.width
            height: partText.height
            color: "transparent"

            Label {
                id:partText
                width: parent.width
                color: theme.inverted ? "white" : "black"
                text: qsTr("Group participants")
                font.bold: true
                anchors.verticalCenter: addButton.verticalCenter
            }

            BorderImage {
                id: addButton
                width: labelText.paintedWidth + 30
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
                        //getCurrentContacts()
                        genericSyncedContactsSelector.title = qsTr("Add participants")
                        genericSyncedContactsSelector.multiSelectmode = true
                        //pageStack.push(genericSyncedContactsSelector)
                        pageStack.push(genericSyncedContactsSelector)
                    }
                }
            }

        }


        WAListView{
            id:groupParticipants
            defaultPicture: "../common/images/user.png"
            anchors.top:participantsHeader.bottom
            anchors.topMargin: 5
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            allowRemove: true
            allowSelect: false
            allowFastScroll: false
            emptyLabelText: qsTr("No participants added yet")

            onRemoved: {
                consoleDebug(index)
                var rmItem = participantsModel.get(index)
                genericSyncedContactsSelector.unSelect(rmItem.relativeIndex)
            }

           model:participantsModel

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
            text: creatingGroup?qsTr("Creating"):qsTr("Create");
            enabled: subject_text.text!=="" && participantsModel.count>0 && !creatingGroup
            onClicked: {
				creatingGroup = true
                createGroupChat(subject_text.text)
			}
        }
       
    }

    function setConversation(c){
        ContactHelper.conversation=c;
    }

	Connections {
		target: appWindow
		onGroupCreated: {
			consoleDebug("GROUP CREATED: " + group_id)
			groupId = group_id + "@g.us"
			var participants;
			for (var i=0; i<participantsModel.count; ++i) {
                if (participantsModel.get(i).jid!="undefined")
                    participants = participants + (participants!==""? ",":"") + participantsModel.get(i).jid; //what about Array.join?!!
			}
			addParticipants(groupId,participants)
		}
		onAddedParticipants: {

            if(selectedPicture && selectedPicture !== "/opt/waxmppplugin/bin/wazapp/UI/common/images/group.png")
                setPicture(groupId, selectedPicture)
        	openConversation(groupId);
		}
	}


    ToolBarLayout {
        id:contactsTool
        visible:false

        ToolIcon{
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }

        ToolButton
        {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.centerIn: parent
            width: 300
            text: qsTr("Done")
            onClicked: {
                /*var myContacts = selectedContacts
                selectedContacts = ""
                participantsModel.clear()
                for (var i=0; i<contactsModel.count; ++i) {
                    if (myContacts.indexOf(contactsModel.get(i).jid)>-1) {
                        consoleDebug("ADDING CONTACT: "+contactsModel.get(i).jid)
                        selectedContacts = selectedContacts + (selectedContacts!==""? ",":"") + contactsModel.get(i).jid;
                        participantsModel.append({"contactPicture":contactsModel.get(i).picture,
                            "contactName":contactsModel.get(i).name,
                            "contactStatus":contactsModel.get(i).status,
                            "contactJid":contactsModel.get(i).jid})
                    }
                }
                consoleDebug("PARTICIPANTS RESULT: " + selectedContacts)
                pageStack.pop()*/

                consoleDebug("GEtting selected")
                var selected = genericSyncedContactsSelector.getSelected()
                consoleDebug("Selected count: "+selected.length)
                participantsModel.clear()
                groupParticipants.reset()

                for(var i=0; i<selected.length; i++) {
                    consoleDebug("Appending")
                   participantsModel.append({name:selected[i].data.name, picture:selected[i].data.picture, jid:selected[i].data.jid, relativeIndex:selected[i].selectedIndex})
                }

                pageStack.pop()
            }
        }

    }

    SelectPicture {
        id:selectPicturePage
        onSelected: {
            pageStack.pop()
            selectedPicture = path
        }
    }


}
