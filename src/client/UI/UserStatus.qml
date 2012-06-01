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

Rectangle {
    id:container

    property string lastSeenOn;
    property string prevState;
    property int itemwidth

    state: "default"
    color:"transparent"

    function setOnline(){

        container.state="online"
    }

    function setOffline(secondsAgo){


        var d = new Date();

        if(secondsAgo){
            d.setSeconds(Qt.formatDateTime ( d, "ss" )-secondsAgo)


            if(container.state != "online" && container.state!="typing"){
                 lastSeenOn = Qt.formatDateTime(d,"hh:mm ap dd.MM.yyyy");
                 container.state="offline"
            }
        }
        else{
             lastSeenOn = Qt.formatDateTime(d,"hh:mm ap dd.MM.yyyy");
             container.state="offline"
        }

       // d = secondsAgo?d.addSecs(-secondsAgo):d


    }

    function setTyping(){
        prevState = container.state;
        container.state="typing";
    }

    function setPaused(){
        if(prevState == "online")
            container.state = prevState;
        else
            setOffline();
    }

    Label{
        id:userstatus
        horizontalAlignment: Text.AlignRight
		font.pixelSize: 18
		width: itemwidth
		opacity: 0.7
    }

    states: [
        State {
            name: "online"

            PropertyChanges {
                target: userstatus
                text: qsTr("Online")
            }
        },

        State {
            name: "default"

            PropertyChanges {
                target: userstatus
                text: qsTr("")
            }
        },

        State{
            name:"offline"
            PropertyChanges {
                target: userstatus
                text: qsTr("Last seen on %1").arg(lastSeenOn)

            }
        },
        State{
            name:"typing"
            PropertyChanges{
                target: userstatus
                text: qsTr("Typing")
            }
        }

    ]
}
