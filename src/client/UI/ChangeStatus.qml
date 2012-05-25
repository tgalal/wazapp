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


Sheet {

    Component.onCompleted: {
        //showToolbars = false
        titleInput.forceActiveFocus();
    }

    visualParent: parent

    
    Item {
        id: myButtons
        width: parent.width
        height: 64
        SheetButton {
            id: rejectButton
            text:  qsTr("Cancel")
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            //platformStyle: mySheetButtonAccentStyle
            onClicked: reject()
        }
        SheetButton {
            id: acceptButton
            text:  qsTr("Done")
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            platformStyle: mySheetButtonAccentStyle
            onClicked: accept()
            enabled: titleInput.text!=""
        }
    }

    buttons: myButtons

	function setStatus(num,msg) {
        //final ProcessBuilder pb = new ProcessBuilder("/opt/waxmppplugin/bin/status ", num.toString(), "\""+ msg +"\"");
		//final Process p = pb.start();
		shell_exec("/opt/waxmppplugin/bin/status "+ num.toString() + " \"" + msg + "\"");
	}

    onAccepted: {
		setStatus(5491133302246, titleInput.text);
    }

    onRejected: {
        //showToolbars = true
    }


    content: Item {
        id: content
        anchors.fill: parent

        Rectangle {
            anchors.fill: parent
            color: theme.inverted ? "black" : "#f7f7ff"

            Column {
                spacing: 16
                anchors { top: parent.top; left: parent.left; right: parent.right; margins: 10 }
                anchors.leftMargin: 16
                anchors.rightMargin: 16

                Label {
                    color: theme.inverted ? "white" : "black"
                    text: qsTr("Enter new status")
                }

                TextField {
                    id: titleInput
                    text: ""
                    width: parent.width
                    platformStyle: myTextFieldStyle
                }
            }

        }
    }

    MouseArea {
        z: -1
        anchors.fill: parent
    }
}
