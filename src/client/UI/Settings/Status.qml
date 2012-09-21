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

	property alias text: status_text.text
	property string tempStatus: ""
	
	signal emojiSelected(string emojiCode);

	function cleanText(txt) {
        var repl = "p, li { white-space: pre-wrap; }";
        var res = txt;
        res = Helpers.getCode(res);
        res = res.replace(/<[^>]*>?/g, "").replace(repl,"");
        return res.replace(/^\s+/,"");
	}	

    Emojidialog{
        id:emojiDialog

        Component.onCompleted: {
            emojiDialog.emojiSelected.connect(content.emojiSelected);
        }

    }

	Connections {
		target: content
		onEmojiSelected: {
		    consoleDebug("GOT EMOJI "+emojiCode);

		   	var str = cleanText(status_text.text)
			var pos = str.indexOf("&quot;")
			var newPosition = status_text.lastPosition
			while(pos>-1 && pos<status_text.lastPosition) {
				status_text.lastPosition = status_text.lastPosition +5
				pos = str.indexOf("&quot;", pos+1)
			}
			pos = str.indexOf("&amp;")
			while(pos>-1 && pos<status_text.lastPosition) {
				status_text.lastPosition = status_text.lastPosition +4
				pos = str.indexOf("&amp;", pos+1)
			}

			var emojiImg = '<img src="/opt/waxmppplugin/bin/wazapp/UI/common/images/emoji/20/emoji-E'+emojiCode+'.png" />'
			str = str.substring(0,status_text.lastPosition) + cleanText(emojiImg) + str.slice(status_text.lastPosition)
			status_text.text = Helpers.emojify2(str)
			status_text.cursorPosition = newPosition + 1
			status_text.forceActiveFocus()
		}
    }

	Connections {
		target: appWindow

		onStatusChanged: {
			MySettings.setSetting("Status", tempStatus)
			myStatus.text = Helpers.emojify(tempStatus)
			send_button.enabled = true
			status_text.enabled = true
			emoji_button.enabled = true
		}
	}
	
    Rectangle {
        //anchors.top: parent.top
		//anchors.topMargin: 90
		width: parent.width
		height: parent.height
        color: "transparent"

        Column {
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
                    iconSource: "../common/images/emoji/32/emoji-E415.png"
					anchors.left: parent.left
					anchors.leftMargin: 0
					anchors.verticalCenter: send_button.verticalCenter
					onClicked: emojiDialog.openDialog()
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
					//enabled: cleanText(status_text.text).trim() !=""
					y: 0
					onClicked:{
						var toSend = cleanText(status_text.text);
						toSend = toSend.trim();
						if ( toSend != "")
						{
							tempStatus = toSend;
							changeStatus(toSend);
							send_button.enabled = false
							status_text.enabled = false
							emoji_button.enabled = false
						}
					}
				}
			}
        }

    }
    
}
