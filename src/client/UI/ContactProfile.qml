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
import QtMobility.contacts 1.1

Page {
    id:container

	//anchors.fill: parent


    tools: ToolBarLayout {
        id: toolBar
        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }
    }

	ContactModel { id:myContacts }

	property string cNumber

	Component.onCompleted: {
        for(var i =0; i<contactsModel.count; i++)
        {
            if(contactsModel.get(i).jid == activeWindow) {
                picture.imgsource = contactsModel.get(i).picture
				contact_name.text = contactsModel.get(i).name
				contact_status.text = contactsModel.get(i).status
				cNumber = contactsModel.get(i).number
				break;
			}
        }
		console.log("CONTACTS: " + myContacts.count)
        for(var i =0; i<myContacts.count; i++)
        {
			console.log("CONTACT: " + myContacts.get(i).contact.name + " - NUMBER: " + myContacts.get(i).contact.number)
            if(myContacts.get(i).contact.number == cNumber) {
				contact_name.text = myContacts.get(i).contact.name
				break;
			}
        }


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

			RoundedImage {
				id: picture
				size: 80
				height: size
				width: size
				imgsource: "pics/user.png"
			}

			Column {
				width: parent.width - picture.size -10
				anchors.verticalCenter: picture.verticalCenter

				Label {
					id: contact_name
					font.bold: true
					font.pixelSize: 26
				}

				Label {
					id: contact_status
					font.pixelSize: 22
					color: "gray"
					text: qsTr("Hi there I'm using Wazapp")
				}
			}
		}

		Separator {
			width: parent.width
		}

	}

}
