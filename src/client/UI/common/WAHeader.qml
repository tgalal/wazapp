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

Rectangle{
    width:parent.width
    height:100;
   // anchors.top:parent.top
    property alias title:pageTitle.text
    color:"transparent"
	clip: true

    Component.onCompleted: {

        var d = new Date()

        if(d.getMonth() == 11 && d.getDate() > 17) {
            wazapp_icon.source = 'images/icons/wazanta80.png'
        }
    }

    Image{
	    id:wazapp_icon
	    anchors.left: parent.left
		anchors.leftMargin: 16
	    anchors.top: parent.top
		anchors.topMargin: 18
        height:50//parent.height
	    width:height
		smooth: true
        source:'images/icons/wazapp80.png'
        fillMode: Image.PreserveAspectFit
	}

	Label{
	    id: pageTitle
	    color:"#27a01b"
	    font.pixelSize: 34
        anchors.verticalCenter: wazapp_icon.verticalCenter
	    anchors.left: wazapp_icon.right
	    anchors.leftMargin: 14
	}

	Rectangle {
		height: 1
		width: parent.width
		x:0; y: 71
		color: "gray"
		opacity: 0.6
	}
	Rectangle {
		height: 1
		width: parent.width
		x:0; y: 72
		color: theme.inverted ? "lightgray" : "white"
		opacity: 0.8
    }
}
