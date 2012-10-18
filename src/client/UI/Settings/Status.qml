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
import "../common/js/settings.js" as MySettings
import "../common/js/Global.js" as Helpers
import "../common"
import "../EmojiDialog"

Item {

	id: content
	height: column1.height

	property alias text: status_text.text
	property string tempStatus: ""
    property bool requested:false


	Connections {
		target: appWindow

        onProfileStatusChanged: {

            if(requested) {
                MySettings.setSetting("Status", tempStatus)
                myStatus.text = Helpers.emojify2(tempStatus)
                send_button.text=qsTr("Done")
                send_button.enabled = true
                status_text.enabled = true
                emoji_button.enabled = true

                showNotification(qsTr("Status updated"))

                requested = false

            }
        }
	}
	
    Column {
		id: column1
        spacing: 16
        anchors { top: parent.top; left: parent.left; right: parent.right; }
        //anchors.leftMargin: 16
        //anchors.rightMargin: 16

        WATextArea {
		    id: status_text
		    width:parent.width
			wrapMode: TextEdit.Wrap
			textFormat: Text.RichText
            textColor: "black"
			onActiveFocusChanged: { 
				lastPosition = status_text.cursorPosition 
				consoleDebug("LAST POSITION: " + lastPosition)
			}
		}

		Rectangle {
			id: input_button_holder
			anchors.left: parent.left
			width: parent.width
			height: 50
			color: "transparent"
			clip: true
							
			Button
			{
				id:emoji_button
				//platformStyle: ButtonStyle { inverted: true }
				width:50
				height:50
                iconSource: "../common/images/emoji/32/E415.png"
				anchors.left: parent.left
				anchors.leftMargin: 0
				anchors.verticalCenter: send_button.verticalCenter
                onClicked: {
                    emojiDialog.openDialog(status_text);
                }
			}

		
			Button
			{
				id:send_button
				platformStyle: ButtonStyle { inverted: true }
				width:160
				height:50
				text: qsTr("Done")
				anchors.right: parent.right
                anchors.rightMargin: 0
				y: 0
				onClicked:{
                    var toSend = status_text.getCleanText();
                    var res = toSend[0];
					if ( res.trim() != "")
                    {
                        requested = true;
						tempStatus = res.trim();
						var cleanedmessage = Helpers.getCode(status_text.text);
						changeStatus(cleanedmessage);
                        send_button.text = qsTr("Updating") + "..."
                        send_button.enabled = false
                        status_text.enabled = false
                        emoji_button.enabled = false
					}
				}
			}
		}
    }

    
}
