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
    id:container

    property string picture:"none";
    property string name:"User";
    property string number:"number";
    property string lastMsg:"Hello World!";
    property string time:"00:00am"
    property string formattedDate;
    property int msgId;
    property int msgType;
    property string state_status
	property bool isGroup

    Component.onCompleted: {
        if(msgType ==0){
            state="received";
        }

    }

    state:state_status == 0?"sending":(state_status ==1?"pending":"delivered")

    signal clicked(string number);
    signal optionsRequested()


    height: 102;
    //width: parent.width
    //color: "#e6e6e6"
    color:"transparent"

    states: [
        State {
            name: "received"
            PropertyChanges {
                target: status
                visible:false
            }
        },

        State {
            name: "sending"
            PropertyChanges {
                target: status
                source: "pics/indicators/sending.png"
            }
            PropertyChanges {
                target: status
                visible:true
            }
        },
        State {
            name: "pending"
            PropertyChanges {
                target: status
                source: "pics/indicators/pending.png"
                 visible:true
            }
        },
        State {
            name: "delivered"
            PropertyChanges {
                target: status
                source: "pics/indicators/delivered.png"
                visible:true
            }
        }
    ]

    MouseArea{

        id:mouseArea
        anchors.fill: parent
        //onClicked: {controls.opacity=1;container.height=80}
        onClicked: container.clicked(number)
        onPressAndHold: optionsRequested()
    }

	Rectangle {
		anchors.fill: parent
		color: theme.inverted? "darkgray" : "lightgray"
		opacity: theme.inverted? 0.2 : 0.8
		visible: mouseArea.pressed
	}

    Row
    {
        anchors.fill: parent
        spacing: 10
        anchors.topMargin: 10
        anchors.leftMargin: 10
        anchors.rightMargin: 10
		height: 80
		width: parent.width
		anchors.verticalCenter: parent.verticalCenter

        //contact image
		RoundedImage {
            id:contact_picture
            width:80
            height: 80
            size:72
            imgsource: isGroup? "pics/group.png" : picture
            x: 2;
			anchors.verticalCenter: parent.verticalCenter
			opacity:appWindow.stealth?0.2:1
			//onClicked: mouseArea.clicked()
			//onPressAndHold: mouseArea.pressAndHold()
        }

        Column{
			id:last_msg_wrapper
		    width:parent.width - 100
			spacing: 0

		    Label{
		        id: contact_name
		        text:name
				font.bold: true
				font.pointSize: 18
				height: 30
		    }
            Row{
                spacing:5
                width:parent.width

                Image {
                    id: status
                    height: 18; width: 18
					smooth: true
                    y:5
 				}
                Label{
                    id:last_msg
		            text: lastMsg.indexOf("wazappmms:")===0 ? lastMsg.substr(-4)==".vcf" ? lastMsg.replace("wazappmms:","").replace(".vcf","") : 
							qsTr("Multimedia message") : lastMsg.indexOf("wazapplocation:")===0 ? qsTr("My location") : lastMsg
                   	//width:parent.width
                    elide: Text.ElideRight
                    font.pixelSize: 20
                    height: 30
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Label{
                id:last_msg_time
                text:formattedDate;
                font.pixelSize: 16
				color: "gray"
				height: 30
                //horizontalAlignment: Text.AlignRight
                //anchors.right: parent.right
                width:parent.width
                //horizontalAlignment: Text.AlignRight

            }
		    
        }
    }



}
