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
    width: parent.width
    height: 30
    color: "#dedddd"
    id:container

    TabItem{

        anchors.right: parent.right
        anchors.rightMargin: 5
        anchors.verticalCenter: parent.verticalCenter

        Image{

            anchors.centerIn: parent

            source: "pics/settings_icon.png"
        }

        MouseArea{

            anchors.fill: parent
            onClicked: container.parent.state="contacts"
        }

    }
    Row{
        id:tab_items
        anchors.left: parent.left
        anchors.leftMargin: 5
        spacing:0
        anchors.verticalCenter: parent.verticalCenter

        TabItem{

            Image{

                id:chat_icon
                anchors.centerIn: parent
                source: "pics/chats_icon.png"
            }

            MouseArea{

                anchors.fill: parent
                onClicked: container.parent.state="chats"
            }

        }

        TabItem{

            Image{

                anchors.centerIn: parent
                source: "pics/contacts_icon.png"
            }

            MouseArea{

                anchors.fill: parent
                onClicked: container.parent.state="contacts"
            }

        }
    }




}
