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

Page{
    property string phoneNumber;

    //tools:editTools



    Column{
       anchors.fill: parent
       spacing:10

    WAHeader{
        width:parent.width
    }


   Label{
       text:qsTr("Click the next button to send the registration code to")
   }

    Button{
        text:"Save"
        onClicked: {
            if(push_field.value.trim() === ""){
                showNotification(qsTr("Push name cannot be left empty"))
            }
            else{
                actor.savePushName(push_field.value)
                showNotification(qsTr("Push name saved"));

            }
        }
    }
}
}
