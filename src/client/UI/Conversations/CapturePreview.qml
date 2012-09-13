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

import QtQuick 1.1
import com.nokia.meego 1.0
import Qt 4.7
import QtMultimediaKit 1.1

import "../common"

Page {

	property string imgsource
	property int oriented

	Rectangle {
		anchors.centerIn: parent
		height: oriented==0? parent.height : parent.width
		width: oriented==0? parent.width : parent.height
		color: "black"
		clip: true
		rotation: oriented

		Image {
			id: preview
			anchors.fill: parent
			fillMode: Image.PreserveAspectFit
			source: imgsource
			smooth: true
		}
	}

	Connections {
		target: appWindow
		onThumbnailUpdated: {
			if (preview.sourceSize.width<1) {
				preview.source = ""
				preview.source = "/home/user/.thumbnails/screen/" + Qt.md5(imgsource) + ".jpeg"
			}
		}
	}

    ToolBar {
		id: toolBar
        height: appWindow.inPortrait? 62 : 54
		width: parent.width
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
		opacity: 0.6

        platformStyle: ToolBarStyle { inverted: true }

        tools: ToolBarLayout {

			ToolButton
		    {
				anchors.verticalCenter: parent.verticalCenter
				anchors.left: parent.left
				anchors.leftMargin: 16
				width: (parent.width -48) /2
		        text: qsTr("Cancel")
				platformStyle: ToolButtonStyle { inverted: true }
		        onClicked: {
					removeFile(imgsource)
					pageStack.pop()
				}
		    }

			ToolButton
		    {
				anchors.verticalCenter: parent.verticalCenter
				anchors.right: parent.right
				anchors.rightMargin: 16
				width: (parent.width -48) /2
		        text: qsTr("Send")
				platformStyle: ToolButtonStyle { inverted: true }
		        onClicked: { 
					sendMediaImageFile(currentJid, decodeURIComponent(imgsource))
					pageStack.pop()
				}
		    }


		}

    }

}
