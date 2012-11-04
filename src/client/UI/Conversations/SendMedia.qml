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

Item {

	signal selected(string value)

	BorderImage {
		id: panel
		anchors.fill: parent
		anchors.leftMargin: 12
		anchors.rightMargin: 12
		source: theme.inverted? "../common/images/back2.png" : "../common/images/back1.png"
		border { left: 22; right: 22; bottom: 22; top: 22; }
		smooth: true

		MouseArea {
			anchors.fill: parent
			//onClicked: selected("nothing")
		}

		GridView {
			anchors.fill: parent
			cellWidth: 100
			cellHeight: 76
			anchors.topMargin: 12
			anchors.leftMargin: appWindow.inPortrait? 26 : 14
			interactive: false

			model: ListModel {
                ListElement { name: "Picture"; value: "pic"; usable: true;}
                ListElement { name: "Picture2"; value: "campic"; usable: true;}
                ListElement { name: "Video"; value: "vid"; usable: true;}
                ListElement { name: "Video2"; value: "camvid"; usable: true;}
                ListElement { name: "Audio"; value: "audio"; usable: true;}
                ListElement { name: "Audio2"; value: "rec"; usable: false;}
                ListElement { name: "Location"; value: "location"; usable: true;}
                ListElement { name: "Contact"; value: "vcard"; usable: true;}
			}

			delegate: Item {
				width: 100
				height: 76

				Image {
					id: image
					source: "../common/images/send-" + value + (theme.inverted? "-white" : "") + ".png"
					width: 48
					height: 48
					smooth: true
					anchors.centerIn: parent
					opacity: usable? 1 : 0.5
				}

				/*Label {
					anchors.centerIn: rec
					height: 32
					width: 152
					color: "white"
					font.pixelSize: 14
					text: fileName
					wrapMode: Text.WrapAnywhere
					horizontalAlignment : Text.AlignHCenter
					verticalAlignment : Text.AlignVCenter
				}*/

				MouseArea {
				    id: mouseArea
				    anchors.fill: parent
				    onClicked: {
						if (usable) selected(value)
				    }
				}
			}


		}

	}

}

