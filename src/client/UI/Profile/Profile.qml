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
import "../common/js/settings.js" as MySettings
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
	property string contactPicture: "none"
	property string contactStatus

	Component.onCompleted: {
		MySettings.initialize()
		profileUser = myAccount
		getInfo()
	}

	onStatusChanged: {
        if(status == PageStatus.Activating){
            contactStatus = MySettings.getSetting("Status", "")
        }
	}

	function getInfo() {
		contactName = qsTr("My Profile")
		contactStatus = MySettings.getSetting("Status", "")
		contactNumber = myAccount.split('@')[0]
		contactPicture = "/home/user/.cache/wazapp/contacts/" + contactNumber + ".png"
		getPicture(myAccount, "image")

	}

	Connections {
		target: appWindow
		onOnPictureUpdated: {
			if (myAccount == ujid) {
				contactPicture = "/home/user/.cache/wazapp/contacts/" + contactNumber + ".png"
				picture.imgsource = ""
				picture.imgsource = contactPicture
				bigImage.source = ""
				bigImage.source = contactPicture.replace(".png",".jpg").replace("contacts","profile")
			}
		}
		onStatusChanged: {
			contactStatus = MySettings.getSetting("Status", "")
		}
	}

	Image {
		id: bigImage
		visible: false
		source: contactPicture.replace(".png",".jpg").replace("contacts","profile")
	}


	Column {
		anchors.fill: parent
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
			text: qsTr("Change status")
			//visible: contactStatus!==""
			onClicked: pageStack.push (Qt.resolvedUrl("../ChangeStatus/ChangeStatus.qml"))
		}

		Separator {
			width: parent.width
		}

		Button {
			height: 50
			width: parent.width
			font.pixelSize: 22
			text: qsTr("Change picture")
            onClicked: pageStack.push(setProfilePicture)
		}


	}

}
