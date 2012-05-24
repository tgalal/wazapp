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


    height:msg_text.height+msg_date.height+margin1.height+margin2.height+margincenter.height+10;
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

    MouseArea{
        anchors.fill: parent
        /*onClicked: {
            console.log("CLICKED!!!");
             optionsRequested();
        }*/

        onPressAndHold:{
            console.log("pressed and held!")
            optionsRequested();
        }



    }

    /*Column{
        visible: !from_me
        width:80;
        height:80;
        anchors.right: realBubble.left
        anchors.top: realBubble.top
        anchors.rightMargin: 15

        Rectangle{

            height:parent.width
            width:parent.width
            color:"transparent"
            Image{
                id:sender_picture
                width:parent.width
                height:parent.height
                fillMode: Image.PreserveAspectFit
                opacity:appWindow.stealth?0.2:1
                Component.onCompleted: {
                    if(!from_me)
                        sender_picture.source=picture
                }
            }
        }
    }*/


    Rectangle
    {
        id:realBubble
        radius: 5
        width: parent.width
        height: parent.height
        color: "transparent" //appWindow.stealth?"transparent":(from_me?"#cfd2d4":"#42b6f2");
        opacity:theme.inverted?0.8:1

		function sizefy() {
			var result = Math.max(msg_text.paintedWidth, msg_date.paintedWidth+(from_me?40:0)) + 30
			return result+20;
		}

        anchors.right: from_me?this.right:parent.right
        anchors.left: from_me?parent.left:this.left
        anchors.rightMargin: 10
        anchors.leftMargin: from_me? 10 : parent.width-sizefy()-10

		Image { id: img1; anchors.top:parent.top; anchors.left:parent.left; 
				anchors.leftMargin: from_me ? 0 : parent.width - img2.width - 30
				source: "pics/bubbles/"+(from_me?"white":"blue")+"-1.png"; 
				anchors.topMargin:from_me?10:0; }
		Image { id: img2; anchors.top:img1.top; 
				anchors.left:img1.right; 
				source: "pics/bubbles/"+(from_me?"white":"blue")+"-2.png"; 
				width: Math.max(msg_text.paintedWidth, msg_date.paintedWidth+(from_me?24:0))
				height:img1.height; smooth: true }
		Image { id: img3; anchors.top:img1.top; anchors.left:img2.right; source: "pics/bubbles/"+(from_me?"white":"blue")+"-3.png"; }

		Image { id: img4; anchors.top:img1.bottom; anchors.left:img1.left; source: "pics/bubbles/"+(from_me?"white":"blue")+"-4.png";
				height:parent.height-img1.height-img6.height-10 }
		Image { id: img5; anchors.top:img3.bottom; anchors.left:img3.left; source: "pics/bubbles/"+(from_me?"white":"blue")+"-5.png"; 
				height:img4.height}
		Image { id: img6; anchors.bottom:parent.bottom; anchors.left:img1.left; source: "pics/bubbles/"+(from_me?"white":"blue")+"-6.png"; 
				anchors.bottomMargin:from_me?0:10; }
		Image { id: img7; anchors.bottom:parent.bottom; anchors.left:img6.right; source: "pics/bubbles/"+(from_me?"white":"blue")+"-7.png"; 
				width:img2.width; height:img6.height; smooth:true; anchors.bottomMargin:from_me?0:10; }
		Image { id: img8; anchors.bottom:parent.bottom; anchors.left:img3.left; source: "pics/bubbles/"+(from_me?"white":"blue")+"-8.png";
				anchors.bottomMargin:from_me?0:10; }

		Rectangle { 
				id: imgC; 
				anchors.top:img1.bottom; anchors.topMargin:0; anchors.left:img1.right; color:(from_me?"#f5f5f5":"#09a7cc"); 
				width:img2.width; height:img4.height; 
				gradient: Gradient {
					GradientStop { position: 0.0; color: (from_me?"#fafafa":"#1aadd0") }
					GradientStop { position: 1.0; color: (from_me?"#f5f5f5":"#09a7cc") }
				}
		}


        Image {
            id: status
            visible: from_me
            anchors.left: parent.left
            anchors.leftMargin: msg_date.paintedWidth + 24
            anchors.bottom:parent.bottom
            anchors.bottomMargin: 22
			height: 16; width: 16
			smooth: true
        }

        Column{
            id:content
            //anchors.fill: parent;
            height:parent.height
            width:parent.width

			Rectangle {
                id: margin1; height: from_me? 14 : 14
				width: parent.width; color: "transparent"
			}

            /*Label{
                id:sender_name
                width:parent.width -20
                color:appWindow.stealth?colorPicker.color:(from_me?"black":"white")
                text:from_me?"You":name
                font.pixelSize: 20
                font.bold: true
                anchors.left: parent.left
                anchors.leftMargin: 10
				horizontalAlignment: from_me? Text.AlignLeft : Text.AlignRight
            }*/

            Label{
                id:msg_text
                text: message;//Helpers.linkify(message);
                color:appWindow.stealth?colorPicker.color:(from_me?"black":"white")
                width: parent.width -80
                wrapMode: "WrapAtWordBoundaryOrAnywhere"
                anchors.left: parent.left
				anchors.leftMargin: from_me ? 15 : 65
				font.family: "Nokia Pure Light"
                font.pixelSize: 22
				horizontalAlignment: from_me? Text.AlignLeft : Text.AlignRight
                onLinkActivated: Qt.openUrlExternally(link);

            }

            /*Separator{
                top_margin: 5;
                bottom_margin: 2;
                visible:!appWindow.stealth
            }*/

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
                font.pixelSize: 15
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

