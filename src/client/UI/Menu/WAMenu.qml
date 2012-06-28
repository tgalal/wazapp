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
       // MenuItem { text: qsTr("Reset profile/Register") }
        //MenuItem { text: qsTr("Settings") }

		MenuItem {
            id:change_status
            text: qsTr("Change my status");

            onClicked: pageStack.push (Qt.resolvedUrl("ChangeStatus.qml"))
        }

         MenuItem{
                visible:updateVisible
                text:"Update Wazapp"
                onClicked:{appWindow.pageStack.push(updatePage)}
         }

        MenuItem {
            id:sync_item
            text: qsTr("Sync Contacts");
            onClicked: {console.log("SYNC");syncClicked();}
            }

        /*MenuItem{
            text:appWindow.stealth?qsTr("Normal Mode"):qsTr("Stealth Mode!");
            onClicked:appWindow.stealth?appWindow.normalMode():appWindow.stealthMode();
        }*/

        MenuItem{
            text:"Invert Colors"
            onClicked:{appWindow.normalMode();theme.inverted = !theme.inverted}
        }


        MenuItem {
               text: qsTr("About")
               onClicked: aboutClicked();
        }


        MenuItem{
            text:qsTr("Quit")
            onClicked:appWindow.quitInit();
        }



    }
}
