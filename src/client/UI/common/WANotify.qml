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

Rectangle{
    id:status_indicator
   // anchors.top: parent.top
    width:parent.width;
    height:50;
    color: "transparent";
    state:"offline"
	clip: true

    Row {
        spacing: 10
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        Label{
            id:current_state
            horizontalAlignment: Text.AlignHCenter
            anchors.verticalCenter: parent.verticalCenter
            //width:accmgrbtn.visible?current_state.paintedWidth:status_indicator.width
        }

        Button{
            id:accmgrbtn
            anchors.verticalCenter: parent.verticalCenter
            visible: false
            text: qsTr("Edit account")
            onClicked:{
                showNotification(qsTr("Launching Account Editor"))
                appWindow.openAccount();
                accmgrbtn.enabled = false
                accmgrbtntimer.start()
            }
        }
    }

    Timer{
        id:accmgrbtntimer
        repeat: false
        interval: 6000
        onTriggered: {accmgrbtn.enabled = true}
    }

	Rectangle {
		height: 1
		width: parent.width
		anchors.left: parent.left
		anchors.bottom: parent.bottom
		color: "gray"
		opacity: 0.6
	}

    states: [

        State {
            name: "online"
            PropertyChanges {

                target: current_state
                text: qsTr("Online")
            }
            PropertyChanges{
                target:status_indicator
                //visible:false
                height:0;
            }

        },

        State {
            name: "connecting"
            PropertyChanges {
                target: current_state
                text: qsTr("Connecting...")

            }

            PropertyChanges{
                target:status_indicator
                //visible:true
                height:50;
            }
        },

        State {
            name: "reregister"
            PropertyChanges {
                target: current_state
                text:"Login failed!"

            }

            PropertyChanges {
                target: accmgrbtn
                visible: true

            }

            PropertyChanges{
                target:status_indicator
                //visible:true
                height:70;
            }
        },
        State {
            name: "offline"
            PropertyChanges {
                target: current_state
                text: qsTr("Offline")

            }

            PropertyChanges{
                target:status_indicator
                //visible:true
                height:50;
            }
        },

        State {
            name: "sleeping"
            PropertyChanges {
                target: current_state
                text:""
            }
            PropertyChanges{
                target:status_indicator
                //visible:false
                height:0
            }
        }
    ]
	transitions: Transition {
        NumberAnimation { properties: "height"; easing.type: Easing.InOutQuad; duration: 500 }
    }

}
