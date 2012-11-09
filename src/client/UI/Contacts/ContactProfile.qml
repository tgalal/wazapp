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
    property string contactPicture
    property string contactStatus
    property bool inContacts


    onStatusChanged: {
        if(status == PageStatus.Activating){
             getPictureIds(contactJid)
        }
    }

    function findChatIem(jid){ //@@PURGE
        for (var i=0; i<conversationsModel.count;i++) {
            var chatItem = conversationsModel.get(i);
            if(chatItem.conversation.jid == jid)
                   return  i;
        }
        return -1;
    }

    function removeChatItem(jid){ //@@PURGE
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
            deleteConversation(contactJid)
            removeChatItem(contactJid)
        }
    }

    Connections {
        target: appWindow
        onRefreshSuccessed: statusButton.enabled=true
        onRefreshFailed: statusButton.enabled=true
    }

    Image {
        id: bigImage
        visible: false
        source: contactPicture == defaultProfilePicture?"":contactPicture.replace(".png",".jpg").replace("contacts","profile");
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
                     pageStack.push(contactPictureViewer)
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
                    text: Helpers.emojify2(contactStatus)
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
        height: parent.height - column1.height - 32 //toolbar
        contentWidth: parent.width
        contentHeight: buttonColumn.height+separator1.height+blockLabel.height+telephonyItem.height+separator2.height+groupsList.height+separator3.height+mediaList.height
        clip: true
        
        Column{
	    width: parent.width

        Label {
            id: blockLabel
            text: qsTr("Contact blocked")
            font.bold: true
            font.pixelSize: 26
            color: "red"
            width: parent.width
            visible: blockedContacts.indexOf(contactJid)!=-1
            height: visible ? 50 : 0
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }

        ButtonColumn{
            id: buttonColumn
            width: parent.width

            Button {
                id: statusButton
                platformStyle: buttonStyleTop
                height: 50
                width: parent.width
                font.pixelSize: 22
                text: qsTr("Update status")
                onClicked: {
                        updateSingleStatus=true //@@retarded
                        statusButton.enabled=false
                        contactForStatus = contactJid //@@retarded
                        refreshContacts("STATUS", contactJid.split('@')[0]) //@@retarded
                }
            }

            Button {
                id: blockButton
                platformStyle: buttonStyleCenter
                height: 50
                width: parent.width
                font.pixelSize: 22
                text: blockedContacts.indexOf(contactJid)==-1? qsTr("Block contact") : qsTr("Unblock contact")
                onClicked: {
                    if (blockedContacts.indexOf(contactJid)==-1)
                        blockContact(contactJid)
                    else
                        unblockContact(contactJid)
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
                onClicked: { exportConversation(contactJid); }
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
		        anchors.left: parent.left
			anchors.right: parent.right
			anchors.rightMargin: 5
		        height: conversationMediaModel.count>0? 36 : 0
		        title: qsTr("Media")
			visible: conversationMediaModel.count>0
		    }

		    ListView {
		        id: mediaList

				function mediaTypePicker(type) {
					var thumb = ""
					switch(type){
						case 3: {
							thumb = "image://theme/icon-m-content-audio"+(theme.inverted?"-inverse":"")
							break
						}
						case 4: {
							thumb = "image://theme/icon-m-content-videos"+(theme.inverted?"-inverse":"")
							break
						}
						case 5: {
							thumb = "../common/images/content-location.png"
							break
						}
						case 6: {
							thumb = "image://theme/icon-m-content-avatar-placeholder"+(theme.inverted?"-inverse":"")
							break
							}
					}
					return thumb
				}

				cacheBuffer: 100
				orientation: ListView.Horizontal
				width: parent.width -32
				anchors.left: parent.left
				anchors.leftMargin: 16
				height: conversationMediaModel.count>0 ? 90 : 0
				model: conversationMediaModel

				delegate: Rectangle {
					id: mediaDelgate
					property int prefixType: mediatype_id
					color: mediaMouseArea.pressed ? (theme.inverted? "darkgray" : "lightgray") : "transparent"
					opacity: mediaMouseArea.pressed ? (theme.inverted? 0.2 : 0.8) : 1.0
					height: parent.height
					width: height
					RoundedImage {
						id: mediaPreview
						x: mediaList.height-height
						y: x
						 width: istate=="Loaded!" ? 86 : 0
						 size: istate=="Loaded!" ? 80 : 0
						 height: width
						//opacity: mediaMouseArea.pressed ? 0.8 : 1.0
						imgsource: preview ? "data:image/jpg;base64,"+preview : mediaList.mediaTypePicker(mediatype_id)
					}
					MouseArea {
						id: mediaMouseArea
						anchors.fill: parent
						onClicked: {
							var prefix = ""
							if (parent.prefixType == 5) {
								prefix = "geo:"
							} else {
								prefix = "file://"
							}
							Qt.openUrlExternally(prefix+local_path)
						}
					}
				}
			}

			GroupSeparator {
				id: separator2
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.rightMargin: 5
				visible: groupsRepeater.model.count==0 ? false : true
				height: visible ? 36 : 0
				title: qsTr("Groups")
			}

			Column {
				id: groupsList
				width: parent.width
				clip: true
				anchors.left: parent.left

				Repeater {
					id: groupsRepeater
					model: conversationGroupsModel

					Item {
						property string jidString: jid
						height: 80
						width: groupsList.width

						Rectangle {
							anchors.fill: parent
							color: groupMouseArea.pressed? (theme.inverted?"darkgray":"lightgray"):"transparent"
							opacity: groupMouseArea.pressed? (theme.inverted? 0.2 : 0.8) : 1.0
						}

						RoundedImage {
							id:picture
							width:62
							height: 62
							size:62
							imgsource: "file://"+pic
							anchors.verticalCenter: parent.verticalCenter
							anchors.left: parent.left
							anchors.leftMargin: 12
							//opacity:appWindow.stealth?0.2:1
						}

						Column{
							width: parent.width -100
							x: 86; y: 12;
							Label {
								y: 2
								id: subjectItem
								text: Helpers.emojify(subject)
								font.pointSize: 18
								elide: Text.ElideRight
								width: parent.width -16
								font.bold: true
								//color: isNew? "green" : (theme.inverted? "white":"black")
							}
							Label {
								id: contactsItem
								text: contacts
								font.pixelSize: 20
								color: "gray"
								width: parent.width -16
								elide: Text.ElideRight
								height: 24
								clip: true
								visible: contactStatus!==""
							}
						}


						MouseArea {
							id: groupMouseArea
							anchors.fill: parent
							onClicked: {
								var conversation = waChats.getConversation(parent.jidString);
								conversation.open();
							}
						}
					}
				}
			}

        GroupSeparator {
		id: separator1
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.rightMargin: 5
		height: 50
		title: qsTr("Phone")
        }

        Item {
            id: telephonyItem
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
                    text: "+"+contactNumber
                }
                MouseArea {
                    id: bArea
                    anchors.fill: parent
                    onClicked: makeCall("+"+contactNumber)
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
                    onClicked: sendSMS("+"+contactNumber)
                }
            }
        }
	}
    }

    WAImageViewer{
        id:contactPictureViewer
        imagePath: bigImage.width?bigImage.source:(contactPicture != defaultProfilePicture?contactPicture:"")
    }
}