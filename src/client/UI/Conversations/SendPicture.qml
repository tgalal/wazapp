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

    onStatusChanged: {
        if(status == PageStatus.Inactive) {
			galleryModel.clear()
		}
        if(status == PageStatus.Active) {
			galleryModel.clear()
			getImageFiles()
		}
	}

    BusyIndicator {
        id: busyIndicatorGridCollection
        implicitWidth: 96
        anchors.centerIn: parent
        visible: view.count==0
        running: visible
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
		x: appWindow.inPortrait? 1 : 27

		model: galleryModel

		delegate: Item {
			width: 158
			height: 158

			Image {
				id: image
				source: thumb // "/home/user/.thumbnails/grid/" + Qt.md5(url) + ".jpeg"
				width: 158
				height: 158
				fillMode: Image.PreserveAspectCrop
				clip: true
				smooth: true
				cache: false
				asynchronous: true

				states: [
				    State {
				        name: 'loaded'; when: image.sourceSize.width>1
				        PropertyChanges { target: image; scale: 1; opacity: 1; }
				    },
				    State {
				        name: 'loading'; when: image.sourceSize.width<1
				        PropertyChanges { target: image; scale: 1; opacity: 0; }
				    }
				]

				transitions: Transition {
				    NumberAnimation { properties: "scale, opacity"; easing.type: Easing.InOutQuad; duration: 1000 }
				}

				Connections {
					target: appWindow
					onThumbnailUpdated: {
						if (image.sourceSize.width<1) {
							image.source = ""
							image.source = thumb
						}
					}
				}

			}

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
					sendMediaImageFile(currentJid, decodeURIComponent(url))
					pageStack.pop()
		        }
		    }
		}
	}

    ScrollDecorator {
        flickableItem: view
    }


}
