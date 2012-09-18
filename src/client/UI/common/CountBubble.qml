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

Rectangle {

	property string title

	color: "#27a01b" //"gray"
	radius: 12
	smooth: true
	width: text.paintedWidth + 22
	height: 26
	//scale: title=="0" || title==""? 0 : 1
	//border.color: "gray"
	//border.width: 1
	visible: parseInt(title)>0

	//Fucking animation! It breaks the chats when app is unfocused
	//Behavior on scale {
	//    NumberAnimation { duration: 200 }
	//}

	Label {
		id: text
		color: "white"
		font.pixelSize: 15
		anchors.centerIn: parent
        text: title
	}

}

