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
import "../common"
import "../common/WAListView"
import "../Profile"
import "js/groupprofile.js" as ProfileHelper

WAPage {
    id:container

	//anchors.fill: parent


    property string jid;
	property string groupSubject
	property string groupDate
    property string groupPicture: defaultPicture
    property string defaultPicture: "../common/images/group.png"
	property string groupOwner
	property string groupOwnerJid
	property string groupSubjectOwner
	property bool working: false
	property string currentParticipants
    property string selectedContacts
	property string addparticipants
	property string removeparticipants
    property bool loaded;
    property int addedCount;
    property int removedCount;
    property bool waitForRemove;
    property bool waitForAdd;


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
            PropertyChanges { target: participantsColumn; parent:columnContainer; height:container.height-groupInfoContainer.height; width:columnContainer.width}
        }
    ]

    function pushParticipants(jids){
        participantsModel.clear()
        console.log("SHOULD PUSH "+jids)
        jids = jids.split(",")
        ProfileHelper.currentParticipantsJids.length = 0;
        for(var i=0; i<contactsModel.count; i++) {

            var tmp = contactsModel.get(i)

            for(var j=0; j<jids.length; j++){

                if(tmp.jid == jids[j]) {
                    var modelData = {name:tmp.name, picture:tmp.picture, jid:tmp.jid, relativeIndex:i};
                    participantsModel.append(modelData)
                    ProfileHelper.currentParticipantsJids.push(tmp.jid)
                    break;
                }
            }
        }

        participantsModel.append({name:qsTr("You"), picture:currentProfilePicture || defaultProfilePicture, noremove:true})

        groupParticipants.model = participantsModel
        groupParticipants.state = "loaded"

       // currentParticipants = selectedContacts
    }

    function resetEdits(){
        genericSyncedContactsSelector.resetSelections()
        genericSyncedContactsSelector.unbindSlots()
        genericSyncedContactsSelector.positionViewAtBeginning()

        ProfileHelper.added = new Array();
        ProfileHelper.removed = new Array();

    }


    function pushGroupInfo(data){
        if (data=="ERROR") {
            groupOwner = ""
            groupDate = ""
            groupSubjectOwner = ""
            partText.text = qsTr("Error reading group information")
        } else {

            console.log("pushing" + data)
            data = data.split("<<->>")
            groupOwner = getAuthor(data[1]).split('@')[0]
            console.log(groupOwner)
            groupDate = getDateTime(parseInt(data[5])*1000)
            console.log(groupDate)
            groupSubjectOwner = qsTr("Subject created by") + " " + getAuthor(data[3]).split('@')[0]
            partText.text = qsTr("Group participants:")

            console.log("PUSHED")
        }
    }

    onStatusChanged: {
        if(status == PageStatus.Activating){

            if(!loaded){
                selectedContacts = ""
                currentParticipants = ""
                addparticipants = "";
                removeparticipants = "";
                getInfo()
                loaded = true
            }

            genericSyncedContactsSelector.tools = participantsSelectorTools
        }
    }

    tools: ToolBarLayout {
        id: toolBar
        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }
        ToolButton
        {
			width: 300
            text: qsTr("Save changes")
			visible: myAccount==groupOwnerJid
			anchors.verticalCenter: parent.verticalCenter
			anchors.horizontalCenter: parent.horizontalCenter
            enabled: !working && (addedCount || removedCount)
            onClicked: {
                working = true
                if (ProfileHelper.removed.length) {
                   // waitForRemove = true
                    removeParticipants(jid, ProfileHelper.removed.join(","))
                }

                if(ProfileHelper.added.length){
                   // waitForAdd = true
                    addParticipants(jid, ProfileHelper.added.join(","))
                }

                pageStack.pop()
                working = false
			}
        }

    }




	function getInfo() {
        resetEdits()
        addedCount = 0;
        removedCount = 0;
        participantsModel.clear()
        groupParticipants.state="loading"
        consoleDebug("GET XINFO FOR "+jid)
        getGroupInfo(jid)
        getGroupParticipants(jid)
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

	Connections {
		target: appWindow
	

        /*onRemovedParticipants: {
			if(addparticipants!=="")
                addParticipants(jid,addparticipants)
			else
				pageStack.pop()
		}

		onAddedParticipants: {
			working = false
			pageStack.pop()
        }*/
		
        /*onOnContactPictureUpdated: {
			if (profileUser == ujid) {
				picture.imgsource = ""
				picture.imgsource = groupPicture
				bigImage.source = ""
				bigImage.source = groupPicture.replace(".png",".jpg").replace("contacts","profile")
			}
        }*/

	}


	Image {
		id: bigImage
		visible: false
		source: groupPicture.replace(".png",".jpg").replace("contacts","profile")
	}


    Row{
        id:rowContainer
        anchors.fill: parent
        anchors.margins: 5
     }

    Column{
        id: columnContainer
        anchors.fill: parent
        anchors.margins: 5
        spacing:10
    }

    Column {

        id:groupInfoContainer
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
                        //bigProfileImage = groupPicture.replace(".png",".jpg").replace("contacts","profile")
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
            width: parent.width
            height: 10
        }

        Label {
            width: parent.width
            color: theme.inverted ? "white" : "black"
            text: qsTr("Group owner:") + " <b>" + (groupOwnerJid!=myAccount ? groupOwner : qsTr("You")) + "</b>"
        }

        Label {
            width: parent.width
            color: theme.inverted ? "white" : "black"
            text: qsTr("Creation date:") + " " + groupDate
        }

        Separator {
            width: parent.width
            height: 10
        }

        Button {
            id: statusButton
            height: 50
            width: parent.width
            font.pixelSize: 22
            text: qsTr("Change group subject")
            enabled: !working && groupSubjectOwner!=""
            onClicked: pageStack.push(groupSubjectChanger)
        }

        Button {
            id: picButton
            height: 50
            width: parent.width
            font.pixelSize: 22
            text: qsTr("Change group picture")
            enabled: !working
            onClicked: pageStack.push(setProfilePicture)
        }

        Separator {
            width: parent.width
            height: 10
        }
    }


    SelectPicture {
        id:setProfilePicture
        onSelected: {
            pageStack.pop()
            breathe();
            setGroupPicture(jid, path)
        }
    }

    ChangeSubject{
        id:groupSubjectChanger
        jid:container.jid
        currentSubject:groupSubject
    }



    Item{
        id:participantsColumn
      //  width:parent.width



        Rectangle {
            x: 0
            width: parent.width
            height: partText.height
            color: "transparent"
            id:participantsHeader

            Label {
                id: partText
                width: parent.width
                color: theme.inverted ? "white" : "black"
                text: qsTr("Group participants:")
                font.bold: true
                anchors.verticalCenter: addButton.verticalCenter
            }

            BorderImage {
                id: addButton
                visible: myAccount==groupOwnerJid && !working
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

                        genericSyncedContactsSelector.resetSelections()
                        genericSyncedContactsSelector.unbindSlots()
                        genericSyncedContactsSelector.positionViewAtBeginning()

                        for(var i=0; i<participantsModel.count; i++){
                           var p = participantsModel.get(i)

                            if(p.relativeIndex >= 0)
                                genericSyncedContactsSelector.select(participantsModel.get(i).relativeIndex)
                        }

                        genericSyncedContactsSelector.multiSelectmode = true
                        genericSyncedContactsSelector.title = qsTr("Edit Participants")
                        pageStack.push(genericSyncedContactsSelector);
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
            allowRemove: myAccount==groupOwnerJid
            allowSelect: false
            allowFastScroll: false
            emptyLabelText: qsTr("No participants")

            onRemoved: {

                var rmItem = participantsModel.get(index)

                genericSyncedContactsSelector.unSelect(rmItem.relativeIndex)


                if(ProfileHelper.currentParticipantsJids.indexOf(rmItem.jid) >= 0 ) {
                    ProfileHelper.removed.push(rmItem.jid)
                    removedCount=ProfileHelper.removed.length
                }
                else {

                    ProfileHelper.added.splice(ProfileHelper.added.indexOf(rmItem.jid),1)
                    addedCount = ProfileHelper.added.length
                }
                groupParticipants._removedCount--;
                participantsModel.remove(index);
            }

          // model:participantsModel

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
				//y: 9
				x: 74
				width: parent.width -74
				anchors.verticalCenter: parent.verticalCenter
				Label{
					y: 2
		            text: getUserAuthor(contactJid)
				    font.pointSize: 18
					elide: Text.ElideRight
					width: parent.width -48
					font.bold: true
				}
				Label{
		            text: Helpers.emojify(contactStatus)
				    font.pixelSize: 20
				    color: "gray"
					width: parent.width -48
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
						selectedContacts = selectedContacts.replace(contactJid,"")
						selectedContacts = selectedContacts.replace(/,,/g,",")
						participantsModel.remove(cindex)
						consoleDebug("NEW PARTICIPANTS RESULT: " +selectedContacts)
					}
				}
			}

		}
    }

    ListModel {
        id: participantsModel
    }


    ToolBarLayout {
        id:participantsSelectorTools
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
                consoleDebug("GEtting selected")
                var selected = genericSyncedContactsSelector.getSelected()
                consoleDebug("Selected count: "+selected.length)
                participantsModel.clear()
                groupParticipants.reset()

                ProfileHelper.added.length = 0
                ProfileHelper.removed.length = 0
                var found;
                for(var i=0; i<ProfileHelper.currentParticipantsJids.length; i++){
                   found = false;
                    for(var j=0; j<selected.length; j++){
                        if(ProfileHelper.currentParticipantsJids[i] == selected[j].data.jid) {
                            found = true;
                            break;
                        }
                    }

                    if(!found){
                        ProfileHelper.removed.push(ProfileHelper.currentParticipantsJids[i])
                    }
                }

                for(var i=0; i<selected.length; i++){

                    if(ProfileHelper.currentParticipantsJids.indexOf(selected[i].data.jid) == -1)
                        ProfileHelper.added.push(selected[i].data.jid)
                }

                console.log("Added: "+ProfileHelper.added.join(","))
                console.log("Removed:"+ProfileHelper.removed.join(","))

                addedCount = ProfileHelper.added.length
                removedCount = ProfileHelper.removed.length
                var modelData;
                for(var i=0; i<selected.length; i++) {
                    consoleDebug("Appending")

                    modelData = {name:selected[i].data.name, picture:selected[i].data.picture, jid:selected[i].data.jid, relativeIndex:selected[i].selectedIndex};

                   participantsModel.append(modelData)
                }

                participantsModel.append({name:qsTr("You"), picture:currentProfilePicture || defaultProfilePicture, noremove:true})
                pageStack.pop()
            }
        }

    }

}
