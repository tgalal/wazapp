/***************************************************************************
**
** Copyright (c) 2012, Tarek Galal <tarek@wazapp.im>
**
** This file is part of Wazapp, an IM application for Meego Harmattan
** platform that allows communication with Whatsapp users.
**
** Wazapp is free software: you can redistribute it and/or modify it under
** the terms of the GNU General Public License as published by the
** Free Software Foundation, either version 3 of the License, or
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
import QtQuick 1.0

Rectangle {
    id:container
    width: parent.width
    height: 30
    color: "#dedddd"
    signal clicked()
    z: 1

    WAButton{

        button_color: "white"
        button_text: "Back"
        text_color: "gray"
        height:25
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 5

        MouseArea{
            anchors.fill: parent;
            onClicked: container.clicked()
        }
    }

    //border
    Rectangle
    {
        width:parent.width
        anchors.top: parent.bottom
        height:2
        color:"white"
    }
}

