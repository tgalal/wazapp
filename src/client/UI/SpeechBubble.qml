// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0
import "Global.js" as Helpers

Rectangle {

    id: bubble

    property string picture;
    property string message;
    property bool from_me;
    property string date;
    property string name;
    property int msg_id;
    property string state_status;


    state: state_status;

    signal optionsRequested();

    width: parent.width
    height:msg_text.height+msg_date.height+margin1.height+margin2.height+
			margincenter.height+(sender_name.text!=""?sender_name.height:0);
    color: "transparent" //from_me? "gray" : "red"

    states: [
        State {
            name: "sending"
            PropertyChanges {
                target: status
                source: "pics/indicators/sending.png"
            }
        },
        State {
            name: "pending"
            PropertyChanges {
                target: status
                source: "pics/indicators/pending.png"
            }
        },
        State {
            name: "delivered"
            PropertyChanges {
                target: status
                source: "pics/indicators/delivered.png"
            }
        }
    ]

    Rectangle
    {
        id:realBubble
        radius: 5
        width: parent.width
        height: parent.height
        color: "transparent" //appWindow.stealth?"transparent":(from_me?"#cfd2d4":"#42b6f2");

		function sizefy() {
			var result = Math.max(msg_text.paintedWidth, msg_date.paintedWidth+(from_me?40:0)) + 30
			return result+20;
		}

        anchors.right: from_me?this.right:parent.right
        anchors.left: from_me?parent.left:this.left
        anchors.rightMargin: 10
        anchors.leftMargin: from_me? 10 : parent.width-sizefy()-10
		
		BorderImage {
			anchors.top: parent.top
			anchors.topMargin: from_me ? 8 : 0
			anchors.left: parent.left
			anchors.leftMargin: from_me ? 0 : parent.width - width
			width: Math.max(msg_text.paintedWidth, msg_date.paintedWidth+(from_me?24:0)) +30 + (mmsimage.size>0 ? mmsimage.size+5:0)
			height: parent.height + (from_me ? 2 : 0)

			source: from_me ? "image://theme/meegotouch-messaging-conversation-bubble-outgoing1-" + (mArea.pressed? "pressed" : "normal") :
					"image://theme/meegotouch-messaging-conversation-bubble-incoming" + parseInt(bubbleColor) + "-" + (mArea.pressed? "pressed" : "normal")

			border { left: 22; right: 22; bottom: 22; top: 22; }

			opacity:theme.inverted?0.8:1

			MouseArea{
				id: mArea
				anchors.fill: parent
				/*onClicked: {
				    console.log("CLICKED!!!");
				     optionsRequested();
				}*/

				onClicked: {
					if (message.indexOf("wazapplocation:")===0)
						Qt.openUrlExternally(message.replace("wazapplocation:", "geo:"))
					else if (message.indexOf("wazappmms:")===0)
						Qt.openUrlExternally(message.replace("wazappmms:", "file:///home/user/.cache/wazapp/"))
				}

				onPressAndHold:{
				    console.log("pressed and held!")
				    optionsRequested();
				}
			}

		}


        Image {
            id: status
            visible: from_me
            anchors.left: parent.left
            anchors.leftMargin: msg_date.paintedWidth + 24 +(mmsimage.width>0? mmsimage.width:0)
            anchors.bottom:parent.bottom
            anchors.bottomMargin: 12
			height: 16; width: 16
			smooth: true
        }

		
		RoundedImage {
			id: mmsimage
			width: istate=="Loaded!" ? 66 : 0 
			size: istate=="Loaded!" ? 60 : 0
			x: from_me ? 12 : parent.width - 72
			y: from_me ? 14 : 16
			visible: message.indexOf("wazappmms:")===0 || message.indexOf("wazapplocation:")===0
			imgsource: conversation_view.status==PageStatus.Inactive ? "" :
						message.indexOf("wazapplocation:")===0 ? "pics/content-location.png" :
						message.replace("wazappmms:", "file:///home/user/.cache/wazapp/")
			//onClicked: Qt.openUrlExternally(imgsource);
			
		}

        Column{
            id:content
            x: from_me ? 0+mmsimage.width : 0
            height:parent.height
            width:parent.width-mmsimage.width

			Rectangle {
                id: margin1; height: from_me? 14 : 16
				width: parent.width; color: "transparent"
			}

            Label{
                id:sender_name
                width:parent.width -30
                color:appWindow.stealth?colorPicker.color:(from_me?"black":"white")
                text: name
                font.pixelSize: 20
                font.bold: true
                anchors.left: parent.left
                anchors.leftMargin: 15
				horizontalAlignment: from_me? Text.AlignLeft : Text.AlignRight
				visible: name!=""
            }

            Label{
                id:msg_text
                text: message.indexOf("wazappmms:")===0 ? message.substr(-4)==".vcf" ? message.replace("wazappmms:","") : 
						qsTr("Multimedia message") : message.indexOf("wazapplocation:")===0 ? qsTr("My location") : message
                color:appWindow.stealth?colorPicker.color:(from_me?"black":"white")
                width: parent.width -100 -mmsimage.size
                wrapMode: "WrapAtWordBoundaryOrAnywhere"
                anchors.left: parent.left
				anchors.leftMargin: from_me ? 15 : 85 + (mmsimage.width>0? mmsimage.width-6:0)
				font.family: "Nokia Pure Light"
                font.weight: Font.Light
                font.pixelSize: 24
				horizontalAlignment: from_me? Text.AlignLeft : Text.AlignRight
                onLinkActivated: Qt.openUrlExternally(link);
            }

            Label{
                id:colorPicker
                visible:false
            }

            Rectangle {
                id: margincenter; height: 4
                width: parent.width; color: "transparent"
            }

            Label{
                id:msg_date
                color:appWindow.stealth?colorPicker.color:(from_me?"black":"white")
                text: date.replace(" ", " | ")
                anchors.left: parent.left
				anchors.leftMargin: 15
				width: parent.width-30
                font.pixelSize: 16
                font.weight: Font.Light
				horizontalAlignment: from_me? Text.AlignLeft : Text.AlignRight
				opacity: from_me && !theme.inverted? 0.5 : 0.7
            }

			Rectangle {
                id: margin2; height: 8
				width: parent.width; color: "transparent"
			}


        }

    }


}

