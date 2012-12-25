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

WAPage{

    id:container
    property string operation: qsTr("Loading")
    property alias buttonOneText: buttonOne.text
    property alias buttonTwoText: buttonTwo.text
    property string title:qsTr("Sync contacts")

    property int timeout:0;

    signal buttonOneClicked()
    signal buttonTwoClicked();

    function startTimer(msecs){

        timeout_timer.interval = msecs
        timeout_timer.start();
    }

    Component.onCompleted: {

        if(timeout !=0){
            timeout_timer.interval = timeout

        }

    }


    Timer {
        id:timeout_timer
        running: false;
        repeat: false
        onTriggered: {
            timout_text.visible = true
            timout_buttons.state="visible"
        }
    }


    WAHeader{
        title: container.title
        anchors.top:parent.top
        width:parent.width
		height: 73
    }

    Column{
        spacing:20;
        anchors.left:parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter


		BusyIndicator {
            platformStyle: BusyIndicatorStyle { size: "large";}
		    anchors.horizontalCenter: parent.horizontalCenter
		    visible: true
		    running: visible
		}

        Label{
            text:operation
            horizontalAlignment: Text.AlignHCenter
            width:parent.width
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        /*ProgressBar{
            indeterminate: true
            width:parent.width-32
            anchors.horizontalCenter: parent.horizontalCenter
        }*/

        Label{
            id:timout_text
            text: qsTr("Taking too long?")
            width:parent.width
            horizontalAlignment: Text.AlignHCenter
            visible: false
        }

        Column{
            id:timout_buttons
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10

            states: [
                State {
                    name: "visible"
                    PropertyChanges {
                        target: buttonOne
                        visible:buttonOne.text!="";
                    }
                    PropertyChanges {
                        target: buttonTwo
                        visible:buttonTwo.text!="";
                    }
                }
            ]

            Button{
                id:buttonOne
                visible:false
                onClicked:buttonOneClicked()
                //text:"Button one"
            }

            Button{
                id:buttonTwo
                visible:false
                onClicked: buttonTwoClicked()
                //text:"Button two"
            }
        }
    }


}
