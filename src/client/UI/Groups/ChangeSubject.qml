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

    Component.onCompleted: {
        subject_text.forceActiveFocus();
    }


    onStatusChanged: {
        if(status == PageStatus.Activating){
            subject_text.text = Helpers.emojify2(currentSubject) //reset unsaved modifications
        }
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
                text: Helpers.emojify2(currentSubject)
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
                    iconSource: "../common/images/emoji/32/E415.png"
					anchors.left: parent.left
					anchors.leftMargin: 0
					anchors.verticalCenter: send_button.verticalCenter
                    onClicked: {
                        emojiDialog.openDialog(subject_text);
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
					onClicked: {
                        var toSend = subject_text.getCleanText();
                        var res = toSend[0].trim();
                        if (res != "") {
                            setGroupSubject(jid, Helpers.unicodeEscape(res))
                            pageStack.pop()
                        }
					}
				}
			}
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
