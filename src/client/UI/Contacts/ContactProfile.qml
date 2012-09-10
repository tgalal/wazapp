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

	//anchors.fill: parent


    tools: ToolBarLayout {
        id: toolBar
        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }
    }

	property string contactName
	property string contactNumber
	property string contactPicture: "../common/images/user.png"
	property string contactStatus

	Component.onCompleted: {
		getInfo()
	}

	function getInfo() {
        for(var i =0; i<contactsModel.count; i++) {
            if(contactsModel.get(i).jid == profileUser) {
                contactPicture = contactsModel.get(i).picture
				contactName = contactsModel.get(i).name
				contactStatus = contactsModel.get(i).status
				contactNumber = contactsModel.get(i).number
				break;
			}
        }
		if (contactName == "") {
			contactName = qsTr("Unknown contact")
			contactNumber = profileUser.split('@')[0]
		}
		//getPictureIds(profileUser) USELESS!
		getPicture(profileUser, "image")

	}

	Connections {
		target: appWindow
		onRefreshSuccessed: { getInfo(); statusButton.enabled=true; }
		onRefreshFailed: { statusButton.enabled=true; }
		onOnPictureUpdated: {
			if (profileUser == ujid) {
				picture.imgsource = ""
				picture.imgsource = contactPicture
				bigImage.source = ""
				bigImage.source = contactPicture.replace(".png",".jpg").replace("contacts","profile")
			}
		}	
	}

	Image {
		id: bigImage
		visible: false
		source: contactPicture.replace(".png",".jpg").replace("contacts","profile")
	}

    Flickable {
        id: flickArea
        anchors.fill: parent
		anchors.topMargin: 12
        contentWidth: parent.width
        contentHeight: column1.height +20

        Column {
            id: column1
			width: parent.width -32
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
					imgsource: contactPicture=="none" ? "../common/images/user.png" : contactPicture
					onClicked: { 
						if (bigImage.height>0)
							bigProfileImage = contactPicture.replace(".png",".jpg").replace("contacts","profile")
							pageStack.push (Qt.resolvedUrl("../common/BigProfileImage.qml"))
							//Qt.openUrlExternally(contactPicture.replace(".png",".jpg").replace("contacts","profile"))
					}
				}

				Column {
					width: parent.width - picture.size -10
					anchors.verticalCenter: picture.verticalCenter

					Label {
						text: contactName
						font.bold: true
						font.pixelSize: 26
						width: parent.width
						elide: Text.ElideRight
					}

					Label {
						font.pixelSize: 22
						color: "gray"
						visible: contactStatus!==""
						text: Helpers.emojify(contactStatus)
						width: parent.width
						elide: Text.ElideRight
					}
				}
			}

			Separator {
				width: parent.width
			}

			Button {
				id: statusButton
				height: 50
				width: parent.width
				font.pixelSize: 22
				text: qsTr("Update status")
				visible: contactStatus!==""
				onClicked: { 
					updateSingleStatus=true
					statusButton.enabled=false
					refreshContacts(contactNumber)
				}
			}

			Label {
				font.pixelSize: 26
				text: qsTr("Phone:")
				width: parent.width
			}

			Rectangle {
				height: 84
				width: parent.width
				color: "transparent"
				x: 0

				BorderImage {
					height: 84
					width: parent.width -80
					x: 0; y: 0
					source: "pics/buttons/button-left"+(theme.inverted?"-inverted":"")+
							(bArea.pressed? "-pressed" : "")+".png"
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
					source: "pics/buttons/button-right"+(theme.inverted?"-inverted":"")+
							(bcArea.pressed? "-pressed" : "")+".png"
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

			Separator {
				width: parent.width
				visible: contactName==qsTr("Unknown contact")
			}

			Button {
				height: 50
				width: parent.width
				font.pixelSize: 22
				text: qsTr("Add to contacts")
				visible: contactName==qsTr("Unknown contact")
		        onClicked: Qt.openUrlExternally("tel:"+contactNumber)
			}

			Separator {
				width: parent.width
			}

			Label {
				text: qsTr("Contact blocked")
				font.bold: true
				font.pixelSize: 26
				color: "red"
				width: parent.width
				visible: blockedContacts.indexOf(profileUser)!=-1
				elide: Text.ElideRight
			}

			Button {
				id: blockButton
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

		}
	}

}
