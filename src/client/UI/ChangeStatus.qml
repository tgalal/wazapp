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
import "Global.js" as Helpers


Page {

    id: content

    Component.onCompleted: {
        status_text.forceActiveFocus();
    }

    tools: statusTool

    WAHeader {
    id: changeStatusHeader
    anchors.top: parent.top
    title: "Change status"
    }

    Column {
        anchors.top: changeStatusHeader.bottom
    anchors.topMargin: 16
    spacing: 16

    width: parent.width


            Label {
        id: statusLabel
                color: theme.inverted ? "white" : "black"
                text: qsTr("Enter new status")
            }

        FontLoader { id: wazappFont; source: "/opt/waxmppplugin/bin/wazapp/UI/fonts/WazappPureRegular.ttf" }


            TextArea {
                id: status_text
                width:parent.width-32
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    placeholderText: "Write your message here"
                    wrapMode: TextEdit.Wrap
                    font.family: wazappFont.name
                    font.pixelSize: 24
                    textFormat: Text.PlainText

            }

            Button
            {
                    id:emoji_button
                    platformStyle: ButtonStyle { inverted: true }
                    width: height
                    height:45
                    iconSource: "pics/emoji-32/emoji-E415.png"
                    anchors.top: status_text.bottom
                    anchors.topMargin: 16
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: send_button.verticalCenter
                    onClicked:{
                            var component = Qt.createComponent("Emojidialog.qml");
                            var sprite = component.createObject(content, {origin: "status"});
                    }
            }
    }

    ToolBarLayout {
            id:statusTool
            ToolIcon{
                platformIconId: "toolbar-back"
                onClicked: pageStack.pop()
            }
        ToolButton{
                    id:send_button
                    enabled: status_text.text == "" ? false : true
                    text: qsTr("Change")
                    anchors.centerIn: parent
                    onClicked:{
                            var toSend = status_text.text.trim();
                            if ( toSend != "") {
                                    changeStatus(toSend);
                                    pageStack.pop()
                            }
                    }
            }
      }
}
