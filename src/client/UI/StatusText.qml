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

Rectangle {


    id:container
    color:"transparent"

    states: [
        State {
            name: "connecting"
            PropertyChanges {
                target: curr_operation
                text: qsTr("Connecting")
            }

        },

        State {
            name: "refreshing"
            PropertyChanges {
                target: curr_operation
                text: qsTr("Refreshing Favorites")

            }
        },

        State {
            name: "connected"
            PropertyChanges {
                target: curr_operation
                text: qsTr("Connected")

            }
        },

        State {
            name: "disconnected"
            PropertyChanges {
                target: curr_operation
                text: qsTr("Disconnected")

            }
        }
    ]


    Text{

        id:curr_operation
        anchors.centerIn: parent;
        text: qsTr("Connecting")
        font.pointSize: 12

    }
}
