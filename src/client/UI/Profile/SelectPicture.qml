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
        title: qsTr("Select picture")
        anchors.top:parent.top
        width:parent.width
		height: 73
    }

	Component.onCompleted: {
		galleryModel.filter = myFilters
	}

	GalleryFilterUnion {
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
	}

	GridView {
		id: view
		clip: true
        anchors.top: parent.top
        anchors.topMargin: 73
        height: parent.height -73
		width: parent.width
		cellWidth: 160
		cellHeight: 160
	    cacheBuffer: 1600
	    pressDelay: 100
	    maximumFlickVelocity: 3500

		model: galleryModel

		delegate: Image {
			source: "/home/user/.thumbnails/grid/" + Qt.md5(url) + ".jpeg"
			width: 158
			height: 158
			smooth: true

			Rectangle {
				id: rec
				color: "black"
				height: 40
				width: parent.width
				anchors.bottom: parent.bottom
				opacity: 0.6
			}
			Label {
				anchors.centerIn: rec
				height: 32
				width: 152
				color: "white"
				font.pixelSize: 14
				text: fileName
				wrapMode: Text.WrapAnywhere
				horizontalAlignment : Text.AlignHCenter
				verticalAlignment : Text.AlignVCenter
			}

			MouseArea {
	            id: mouseArea
	            anchors.fill: parent
	            onClicked: {
					//selectedPicture = url //"/home/user/.thumbnails/grid/" + Qt.md5(url) + ".jpeg" //url
					//pageStack.replace(Qt.resolvedUrl("SetPicture.qml"))

	                setPicture(profileUser, decodeURIComponent(url))
					pageStack.pop()
	            }
	        }
		}
	}

    ScrollDecorator {
        flickableItem: view
    }


}
