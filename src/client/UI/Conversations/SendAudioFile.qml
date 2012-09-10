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
import QtMobility.gallery 1.1
import "../common/js/settings.js" as MySettings
import "../common/js/Global.js" as Helpers
import "../common"

WAPage {
    id:container

    tools: ToolBarLayout {
        id: toolBar
        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }
    }

	WAHeader{
        title: qsTr("Select audio")
        anchors.top:parent.top
        width:parent.width
		height: 73
    }

	Component.onCompleted: {
		//console.log("SELECT DIALOG OPENED")
		//galleryVideoModel.filter = myFilters
	}

	/*GalleryFilterUnion {
		id: myFilters
    	filters: [
			GalleryWildcardFilter {
				property: "fileName";
				value: "*.jpg";
			},
			GalleryWildcardFilter {
				property: "fileName";
				value: "*.png";
			}
		]
	}*/


	ListView {
		id: view
		clip: true
        anchors.top: parent.top
        anchors.topMargin: 73
        height: parent.height -73
		width: parent.width
	    maximumFlickVelocity: 3500

		model: galleryAudioModel

		delegate: Rectangle {
			color: "transparent"
			width: parent.width
			height: 80
			smooth: true

			Image {
				id: icon
				source: "image://theme/icon-m-content-audio"
				height: 64
				width: 64
				smooth: true
				anchors.left: parent.left
				anchors.leftMargin: 16
				anchors.verticalCenter: parent.verticalCenter
			}
			Label {
				width: parent.width - 96
				color: theme.inverted? "white" : "black"
				font.pixelSize: 24
				font.bold: true
				text: title
				elide: Text.ElideRight
				anchors.left: icon.right
				anchors.leftMargin: 12
				y: 10
			}
			Label {
				width: parent.width - 96
				color: theme.inverted? "lightgray" : "darkgray"
				font.pixelSize: 20
				text: artist
				elide: Text.ElideRight
				anchors.left: icon.right
				anchors.leftMargin: 12
				y: 42
			}

			MouseArea {
	            id: mouseArea
	            anchors.fill: parent
	            onClicked: {
					sendMediaAudioFile(currentJid, decodeURIComponent(url))
					pageStack.pop()
	            }
	        }
		}
	}

    ScrollDecorator {
        flickableItem: view
    }


}
