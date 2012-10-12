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

    property string myName
    property string myNumber
    property string myPicture: currentProfilePicture?currentProfilePicture:defaultProfilePicture
    property string myStatus: currentStatus

	Component.onCompleted: {
		MySettings.initialize()
		profileUser = myAccount
		getInfo()
	}

    /*onStatusChanged: {
        if(status == PageStatus.Activating){
            myStatus = MySettings.getSetting("Status", "")
        }
    }*/

	function getInfo() {
        myName = qsTr("My Profile")
        myStatus = MySettings.getSetting("Status", "")
        myNumber = myAccount.split('@')[0]
        myPicture = WAConstants.CACHE_CONTACTS + "/" + myNumber + ".png"
		bigImage.source = ""
        bigImage.source = WAConstants.CACHE_PROFILE + "/" + profileUser.split('@')[0] + ".jpg"
		getPicture(myAccount, "image")

	}

    /*Connections {
		target: appWindow
        onOnXContactPictureUpdated: {
			if (myAccount == ujid) {
              //  myPicture = WAConstants.CACHE_CONTACTS + "/" + myNumber + ".png"
				picture.imgsource = ""
                picture.imgsource = myPicture
				bigImage.source = ""
                bigImage.source = WAConstants.CACHE_PROFILE + "/" + myAccount.split('@')[0] + ".jpg"
			}
		}
		onStatusChanged: {
            myStatus = MySettings.getSetting("Status", "")
		}
    }*/

	Image {
		id: bigImage
		visible: false
        source: myPicture
		//source: contactPicture.replace(".png",".jpg").replace("contacts","profile")
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
                imgsource: myPicture
				onClicked: { 
					if (bigImage.width>0) {
                        //bigProfileImage = WAConstants.CACHE_PROFILE + "/" + profileUser.split('@')[0] + ".jpg"
						//pageStack.push (Qt.resolvedUrl("../common/BigProfileImage.qml"))
                        Qt.openUrlExternally(myPicture.replace(".png",".jpg").replace("contacts","profile"))
					}
				}
			}

			Column {
				width: parent.width - picture.size -10
				anchors.verticalCenter: picture.verticalCenter

				Label {
                    text: myName
					font.bold: true
					font.pixelSize: 26
					width: parent.width
					elide: Text.ElideRight
				}

				Label {
					font.pixelSize: 22
					color: "gray"
                    visible: myStatus!==""
                    text: Helpers.emojify(myStatus)
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

    SelectPicture {
        id:setProfilePicture
        onSelected: {
            pageStack.pop()
            setPicture(jid, path)
        }
    }

}
