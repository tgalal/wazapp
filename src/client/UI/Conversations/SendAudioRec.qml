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

	property bool recording: false
	property bool recorded: false

    tools: ToolBarLayout {
        id: toolBar
        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: {
				deleteRecording()
				pageStack.pop()
			}
        }
		ToolButton
	    {
			anchors.centerIn: parent
			width: 300
	        text: qsTr("Send")
			enabled: recorded
	        onClicked: { 
				sendMediaRecordedFile(currentJid)
				pageStack.pop()
			}
	    }
    }

	WAHeader{
        title: qsTr("Audio recorder")
        anchors.top:parent.top
        width:parent.width
		height: 73
    }

	Column {
		width: 384
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.bottom: parent.bottom
		anchors.bottomMargin: 20
		spacing: 16

		Button {
			height: 72
			width: 384
			platformStyle: ButtonStyle { inverted: true }
			iconSource: "images/rec.png"
			enabled: !recording && !recorded
			onClicked: {
				recording = true
				startRecording()
			}
		}

		Row {
			spacing: 16

			Button {
				height: 72
				width: 120
				platformStyle: ButtonStyle { inverted: true }
				iconSource: "images/play.png"
				enabled: recorded
				onClicked: {
					playRecording()
				}
			}

			Button {
				height: 72
				width: 120
				platformStyle: ButtonStyle { inverted: true }
				iconSource: "images/stop.png"
				enabled: recording
				onClicked: {
					recording = false
					recorded = true
					stopRecording()
				}
			}

			Button {
				height: 72
				width: 120
				platformStyle: ButtonStyle { inverted: true }
				iconSource: "images/delete.png"
				enabled: recorded
				onClicked: {
					recorded = false
					deleteRecording()
				}
			}


		}

	}


}
