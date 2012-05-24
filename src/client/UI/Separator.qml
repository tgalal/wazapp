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
// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1

Rectangle {
    width: parent.width
    height:top_margin.height+bottom_margin.height+1;
    color:"transparent"
    property alias top_margin:top_margin.height
    property alias bottom_margin:bottom_margin.height

    Column
    {
        anchors.fill: parent;
        Rectangle{
            id:top_margin
            width:parent.width
            color:"transparent"
        }


        Rectangle{
            width:parent.width
            height:1
            color:"white"
			opacity: 0.7
        }

        Rectangle{
            id:bottom_margin
            width:parent.width
            color:"transparent"
        }
    }
}
