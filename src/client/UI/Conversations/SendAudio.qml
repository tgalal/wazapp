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

	WAHeader{
        title: qsTr("Select audio")
        anchors.top:parent.top
        width:parent.width
		height: 73
    }

    onStatusChanged: {
        if(status == PageStatus.Inactive) {
			browserModel.clear()
		}
        if(status == PageStatus.Active) {
			appWindow.browseFiles("/home/user/MyDocs", "mp3, MP3, wav, WAV");
		}
    }

	property int currentSelected	


	Component {
		id: myDelegate

		Rectangle {
			property string title: model.fileName
			property string value: model.filepath
			property string filetype: model.filetype
			
			color: "transparent"

			height: 72
			width: appWindow.inPortrait? 480:854

			Rectangle {
				anchors.fill: parent
				color: theme.inverted? "darkgray" : "lightgray"
				opacity: theme.inverted? 0.2 : 0.8
				visible: mouseArea.pressed || currentSelected==index
			}

			Image {
				x: 16
			    height: 62; width: 62; smooth: true
			    source: "../common/images/" + model.filetype + (theme.inverted?"-white":"") + ".png"
				anchors.verticalCenter: parent.verticalCenter
			}

			Text {
				x: 92
				width: parent.width -106
				anchors.verticalCenter: parent.verticalCenter
		        text: title
				font.pointSize: 18
				elide: Text.ElideRight
				font.bold: true
				color: theme.inverted? "white" : "black"
			}

			MouseArea{
				id:mouseArea
				anchors.fill: parent
				onClicked:{
					stopSoundFile()
					if (model.filetype=="folder") {
						appWindow.browseFiles(model.filepath, "mp3, MP3, wav, WAV");
					} else {
						currentSelected = index
						playSoundFile(model.filepath)
					}
				}
			}

		}
	}

	ListView {
		y: 74
		anchors.left: parent.left
		height: parent.height -74
		width: parent.width
	    model: browserModel
		onCountChanged: currentSelected=-1
		delegate: myDelegate
		clip: true
	}

    tools: ToolBarLayout {
        id: toolBar
        ToolIcon {
            platformIconId: "toolbar-up";
			enabled: enableBackInBrowser
			opacity: enabled? 1 : 0.4
            onClicked: {
				var i = currentBrowserFolder.lastIndexOf("/");
				var f = currentBrowserFolder.slice(0,i)
				stopSoundFile()
				appWindow.browseFiles(f, "mp3, MP3, wav, WAV");
			}
        }
		ToolButton
	    {
			text: qsTr("Send")
			enabled: currentSelected>-1 && (browserModel.get(currentSelected).filetype=="send-audio")
	        onClicked: { 
                stopSoundFile()
				sendMediaAudioFile(currentJid, browserModel.get(currentSelected).filepath)
				pageStack.pop()
			}
	    }
		ToolButton
	    {
			anchors.right: parent.right
			anchors.rightMargin: 16
			text: qsTr("Cancel")
	        onClicked: {
				stopSoundFile()
				pageStack.pop()
			}
	    }
    }

}
