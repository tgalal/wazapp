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

WAPage {
    id:container


    tools: ToolBarLayout {
        id: toolBar
        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }
    }

    property string contactJid;
    property string contactName
    property string contactNumber
    property string contactPicture: "../common/images/user.png"
    property string contactStatus
    property bool inContacts


    onStatusChanged: {
        if(status == PageStatus.Activating){
             getPictureIds(contactJid)
        }
    }

    function findChatIem(jid){
        for (var i=0; i<conversationsModel.count;i++) {
            var chatItem = conversationsModel.get(i);
            if(chatItem.conversation.jid == jid)
                   return  i;
        }
        return -1;
    }

    function removeChatItem(jid){
        var chatItemIndex = findChatIem(jid);
        consoleDebug("deleting")
        if(chatItemIndex >= 0){
            var conversation = conversationsModel.get(chatItemIndex).conversation;
            var contacts = conversation.getContacts();
            for(var i=0; i<contacts.length; i++){
                contacts[i].unsetConversation();
            }
            delete conversation;
            conversationsModel.remove(chatItemIndex);
            checkUnreadMessages()
        }
    }


    ButtonStyle {
        id: buttonStyleTop
        property string __invertedString: theme.inverted ? "-inverted" : ""
        pressedBackground: "image://theme/color3-meegotouch-button-background-pressed-vertical-top"
        checkedBackground: "image://theme/color3-meegotouch-button-background-selected-vertical-top"
        disabledBackground: "image://theme/color3-meegotouch-button"+__invertedString+"-background-disabled-vertical-top"
        checkedDisabledBackground: "image://theme/color3-meegotouch-button"+__invertedString+"-background-disabled-selected-vertical-top"
    }
    ButtonStyle {
        id: buttonStyleCenter
        property string __invertedString: theme.inverted ? "-inverted" : ""
        pressedBackground: "image://theme/color3-meegotouch-button-background-pressed-vertical-center"
        checkedBackground: "image://theme/color3-meegotouch-button-background-selected-vertical-center"
        disabledBackground: "image://theme/color3-meegotouch-button"+__invertedString+"-background-disabled-vertical-center"
        checkedDisabledBackground: "image://theme/color3-meegotouch-button"+__invertedString+"-background-disabled-selected-vertical-center"
    }
    ButtonStyle {
        id: buttonStyleBottom
        property string __invertedString: theme.inverted ? "-inverted" : ""
        pressedBackground: "image://theme/color3-meegotouch-button-background-pressed-vertical-bottom"
        checkedBackground: "image://theme/color3-meegotouch-button-background-selected-vertical-bottom"
        disabledBackground: "image://theme/color3-meegotouch-button"+__invertedString+"-background-disabled-vertical-bottom"
        checkedDisabledBackground: "image://theme/color3-meegotouch-button"+__invertedString+"-background-disabled-selected-vertical-bottom"
    }

    QueryDialog {
        id: chatHistoryDelete
        titleText: qsTr("Confirm Delete")
        message: qsTr("Are you sure you want to delete this conversation and all its messages?")
        acceptButtonText: qsTr("Yes")
        rejectButtonText: qsTr("No")
        onAccepted: {
            deleteConversation(profileUser)
            removeChatItem(profileUser)
        }
    }

    Connections {
        target: appWindow
        onRefreshSuccessed: statusButton.enabled=true
        onRefreshFailed: statusButton.enabled=true
        /*onOnContactPictureUpdated: {
            if (profileUser == ujid) {
                getInfo("NO")
                picture.imgsource = ""
                picture.imgsource = contactPicture
                bigImage.source = ""
                bigImage.source = WAConstants.CACHE_PROFILE + "/" + profileUser.split('@')[0] + ".jpg"
            }
        }*/
        /*onContactStatusUpdated: {
            if (contactForStatus == profileUser) {
                contactStatus = nstatus
                statuslabel.text = Helpers.emojify(contactStatus)
            }
        }*/
    }

    Image {
        id: bigImage
        visible: false
        source: contactPicture//WAConstants.CACHE_PROFILE + "/" + profileUser.split('@')[0] + ".jpg"
        cache: false
    }

    Column {
        id: column1
        width: parent.width -32
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        anchors.topMargin: 12
        spacing: 12

        Row {
            width: parent.width
            height: col1.heigth + 48
            spacing: 10

            ProfileImage {
                id: picture
                size: 80
                height: size
                width: size
                y: 0
                imgsource: contactPicture
                onClicked: {
                    if (bigImage.width>0) {
                        Qt.openUrlExternally(bigImage.source)
                    }
                }
            }

            Column {
                id: col1
                width: parent.width - picture.size -10
                anchors.verticalCenter: parent.verticalCenter

                Label {
                    text: contactName
                    font.bold: true
                    font.pixelSize: 26
                    width: parent.width
                    elide: Text.ElideRight
                }

                Label {
                    id: statuslabel
                    font.pixelSize: 22
                    color: "gray"
                    visible: contactStatus!==""
                    text: Helpers.emojify(contactStatus)
                    width: parent.width
                }
            }
        }

        Separator {
            width: parent.width
        }
    }

    Flickable {
        id: flickArea
        anchors.top: column1.bottom
        anchors.topMargin: 12
        width: parent.width
        height: parent.height - column1.height
        contentWidth: parent.width
        contentHeight: buttonColumn.height+separator1.height+blockLabel.height+telephonyItem.height+separator2.height+groupsList.height+separator3.height+mediaList.height
        clip: true

        Label {
            id: blockLabel
            text: qsTr("Contact blocked")
            font.bold: true
            font.pixelSize: 26
            color: "red"
            width: parent.width
            visible: blockedContacts.indexOf(profileUser)!=-1
            height: visible ? 50 : 0
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }

        ButtonColumn{
            id: buttonColumn
            width: parent.width
            anchors.top: blockLabel.bottom

            Button {
                id: statusButton
                platformStyle: buttonStyleTop
                height: 50
                width: parent.width
                font.pixelSize: 22
                text: qsTr("Update status")
                visible: profileUser.indexOf("g.us")==-1
                onClicked: {
                        updateSingleStatus=true
                        statusButton.enabled=false
                        contactForStatus = profileUser
                        refreshContacts("STATUS", profileUser.split('@')[0])
                }
            }

            Button {
                id: blockButton
                platformStyle: buttonStyleCenter
                height: 50
                width: parent.width
                font.pixelSize: 22
                text: blockedContacts.indexOf(profileUser)==-1? qsTr("Block contact") : qsTr("Unblock contact")
                onClicked: {
                    if (blockedContacts.indexOf(profileUser)==-1)
                        blockContact(profileUser)
                    else
                        unblockContact(profileUser)
                }
            }

            Button {
                height: 50
                platformStyle: buttonStyleCenter
                width: parent.width
                font.pixelSize: 22
                text: qsTr("Add to contacts")
                visible: !inContacts
                onClicked: Qt.openUrlExternally("tel:"+contactNumber)
            }

            Button {
                id: sendChatButton
                platformStyle: buttonStyleCenter
                height: 50
                width: parent.width
                font.pixelSize: 22
                text: qsTr("Send chat history")
                onClicked: { exportConversation(profileUser); }
            }

            Button {
                id: deleteChatButton
                platformStyle: buttonStyleBottom
                height: 50
                width: parent.width
                font.pixelSize: 22
                text: qsTr("Delete chat history")
                onClicked: {
                    chatHistoryDelete.open()
                }
            }
        }

        GroupSeparator {
            id: separator3
            anchors.top: buttonColumn.bottom
            anchors.left: parent.left
            anchors.leftMargin: 16
            width: parent.width - 44
            height: 50
            title: qsTr("Media")
        }

        //'SELECT mediatype_id,preview,local_path FROM media WHERE id IN (SELECT media_id FROM messages WHERE key LIKE "%385977012270@s.whatsapp.net%" AND NOT media_id=0) ORDER BY id DESC;'
        //'SELECT mediatype_id,preview,local_path FROM media WHERE id IN (SELECT media_id FROM messages WHERE key LIKE "%'+profileUser+'%" AND NOT media_id=0) ORDER BY id DESC;'
        ListView {
            id: mediaList
            Component.onCompleted: {
                //getContactMediaByJid(profileUser)
                //for (var i=0; i<result.length;i++) {
                //    console.log(i,result[i].local_path)
                //}
            }
            orientation: ListView.Horizontal
            width: parent.width -32
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.top: separator3.bottom
            height: 96
            //delegate: Image {source: local_path}
        }

        GroupSeparator {
            id: separator2
            anchors.top: mediaList.bottom
            anchors.left: parent.left
            anchors.leftMargin: 16
            width: parent.width - 44
            height: 50
            title: qsTr("Groups")
        }

        ListView {
            id: groupsList
            orientation: ListView.Vertical
            width: parent.width -32
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.top: separator2.bottom
            height: 200
        }

        GroupSeparator {
            id: separator1
            anchors.top: groupsList.bottom
            anchors.left: parent.left
            anchors.leftMargin: 16
            width: parent.width - 44
            height: 50
            title: qsTr("Phone")
        }

        Item {
            id: telephonyItem
            anchors.top: separator1.bottom
            height: 84
            width: parent.width
            x: 0

            BorderImage {
                height: 84
                width: parent.width -80
                x: 0; y: 0
                source: "pics/buttons/button-left"+(theme.inverted?"-inverted":"")+(bArea.pressed? "-pressed" : "")+".png"
                border { left: 22; right: 22; bottom: 22; top: 22; }

                Label {
                    x: 20; y: 14
                    width: parent.width
                    font.pixelSize: 20
                    text: qsTr("Mobile phone")
                }
                Label {
                    x: 20; y: 40
                    width: parent.width
                    font.bold: true
                    font.pixelSize: 24
                    text: contactNumber
                }
                MouseArea {
                    id: bArea
                    anchors.fill: parent
                    onClicked: makeCall(contactNumber)
                }
            }

            BorderImage {
                height: 84
                anchors.right: parent.right
                width: 80
                x: 0; y: 0
                source: "pics/buttons/button-right"+(theme.inverted?"-inverted":"")+(bcArea.pressed? "-pressed" : "")+".png"
                border { left: 22; right: 22; bottom: 22; top: 22; }

                Image {
                    x: 18
                    anchors.verticalCenter: parent.verticalCenter
                    source: "image://theme/icon-m-toolbar-new-message"+(theme.inverted?"-white":"")
                }
                MouseArea {
                    id: bcArea
                    anchors.fill: parent
                    onClicked: sendSMS(contactNumber)
                }
            }
        }
    }
}
