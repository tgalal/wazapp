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
import QtMobility.feedback 1.1
import com.nokia.meego 1.0

Menu {
    id: myMenu
    property bool updateVisible:false
   // visualParent: pageStack

    signal syncClicked();
    signal aboutClicked();

        MenuLayout {

		MenuItem {
            text: qsTr("Create group");
            //enabled: connectionStatus=="online"
            onClicked: {

                runIfOnline(function(){pageStack.push (Qt.resolvedUrl("../Groups/CreateGroup.qml"))}, true);
			}
        }

		/*MenuItem {
            text: qsTr("My profile");
			//enabled: connectionStatus=="online"
            onClicked: pageStack.push (Qt.resolvedUrl("../Profile/Profile.qml"))
        }*/

        MenuItem {
            id:sync_item
            text: qsTr("Sync Contacts");
            //onClicked: { console.log("SYNC"); syncClicked(); }
			onClicked: {
				//shareSyncContacts.mode = "sync"
				//pageStack.push(shareSyncContacts)
                runIfOnline(function(){appWindow.onSyncClicked()}, true);
				//openContactPicker("true", qsTr("Sync Contacts"))
			}
        }

        MenuItem{
            text: qsTr("Settings")
            onClicked:  pageStack.push(settingsPage);
        }


        MenuItem {
           text: qsTr("About")
           onClicked: aboutDialog.open()
        }

        MenuItem{
            text:qsTr("Quit")
            onClicked: appWindow.quitInit();
        }



    }
}
