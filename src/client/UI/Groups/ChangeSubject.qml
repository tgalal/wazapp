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

WAPage {

	id: content
    property string jid;
    property string currentSubject;

	signal emojiSelected(string emojiCode);

    Component.onCompleted: {
        subject_text.forceActiveFocus();
    }

	function cleanText(txt) {
        var repl = "p, li { white-space: pre-wrap; }";
        var res = txt;
        res = Helpers.getCode(res);
        res = res.replace(/<[^>]*>?/g, "").replace(repl,"");
        return res.replace(/^\s+/,"");
	}	

	tools: statusTool

    WAHeader{
        title: qsTr("Change subject")
        anchors.top:parent.top
        width:parent.width
		height: 73
    }

	Rectangle {
        anchors.top: parent.top
		anchors.topMargin: 90
		width: parent.width
		height: parent.height
        color: "transparent"

        Column {
            spacing: 16
            anchors { top: parent.top; left: parent.left; right: parent.right; }
            anchors.leftMargin: 16
            anchors.rightMargin: 16

            Label {
                color: theme.inverted ? "white" : "black"
                text: qsTr("Enter new subject:")
            }

            WATextArea {
			    id: subject_text
			    width:parent.width
				wrapMode: TextEdit.Wrap
				textFormat: Text.RichText
				textColor: "black"
                text: currentSubject
				onActiveFocusChanged: { 
					lastPosition = subject_text.cursorPosition 
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
					//enabled: cleanText(subject_text.text).trim() !=""
					y: 0
					onClicked: {
						var toSend = cleanText(subject_text.text);
						consoleDebug("Setting subject: " + toSend)
						toSend = toSend.trim();
						if ( toSend != "") {
                            setGroupSubject(jid, toSend)
							pageStack.pop()
						}
					}
				}
			}
        }

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

		   	var str = cleanText(subject_text.text)
			var pos = str.indexOf("&quot;")
			var newPosition = subject_text.lastPosition
			while(pos>-1 && pos<subject_text.lastPosition) {
				subject_text.lastPosition = subject_text.lastPosition +5
				pos = str.indexOf("&quot;", pos+1)
			}
			pos = str.indexOf("&amp;")
			while(pos>-1 && pos<subject_text.lastPosition) {
				subject_text.lastPosition = subject_text.lastPosition +4
				pos = str.indexOf("&amp;", pos+1)
			}

			var emojiImg = '<img src="/opt/waxmppplugin/bin/wazapp/UI/common/images/emoji/20/emoji-E'+emojiCode+'.png" />'
			str = str.substring(0,subject_text.lastPosition) + cleanText(emojiImg) + str.slice(subject_text.lastPosition)
			subject_text.text = Helpers.emojify2(str)
			subject_text.cursorPosition = newPosition + 1
			subject_text.forceActiveFocus()
		}
    }

	ToolBarLayout {
        id:statusTool
        ToolIcon{
            platformIconId: "toolbar-back"
       		onClicked: pageStack.pop()
        }
       
    }

}
