// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0
import "Global.js" as Helpers
Rectangle{
    id:container

	property variant myData
    property string picture:"none";
    property string name:"User";
    property string number:"number";
    property string status:"Hi there I'm using whatsapp";
    property string jid;
    property bool hasPicture;
    signal clicked();

    height:80;
    width: parent.width;
   // color: "#e6e6e6"
    color:"transparent"

	Rectangle {
		anchors.fill: parent
		color: theme.inverted? "darkgray" : "lightgray"
		opacity: theme.inverted? 0.2 : 0.8
		visible: mouseArea.pressed
	}

    MouseArea{
        id:mouseArea
        anchors.fill: parent
        //onClicked: {controls.opacity=1;container.height=80}
        onClicked: container.clicked(number)//{console.log("EXPANDING");container.state=container.state=="opened"?"":"opened"}
    }

    states: State{

        name:"opened";
        PropertyChanges{target:container; height:136;}
        PropertyChanges {
            target: controls
            opacity:1

        }
    }

    transitions: Transition{
        from:"";to:"opened";reversible:true
        SequentialAnimation
        {
         NumberAnimation { property: "height";duration: 300;easing.type: Easing.InOutQuad }
         NumberAnimation {  property: "opacity"; duration: 200 }
        }
    }

    Row
    {
        anchors.fill: parent
        spacing: 12
        anchors.topMargin: 10
        anchors.leftMargin: 10
		height: 62
		anchors.verticalCenter: parent.verticalCenter

        RoundedImage {
            id:contact_picture
            size:62
            imgsource: picture
            opacity:appWindow.stealth?0.2:1
        }

        Column{
			width: parent.width -80
		    Label{
				y: 2
		        id: contact_name
		        text:name
		        font.pointSize: 18
				font.bold: true
		    }

		    /*Label{
		        id:contact_number
		        text:number
		        //anchors.
		        font.pointSize: 14
		        height: 25
		    }*/

		   Label{
		        id:contact_status
                text:Helpers.emojify(status)
		        font.pixelSize: 20
		        color: "gray"
				width: parent.width - 16
				elide: Text.ElideRight
		   }

        }
    }

    Row
    {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        spacing:5
        anchors.bottomMargin: 5
        opacity:0
        id:controls

        WAButton{
            button_color: "#0b83c8";
            button_text: "Chat"
            MouseArea{
                anchors.fill: parent;
                onClicked: container.clicked(number)
            }
        }
        WAButton{
            button_color: "#2ea11b";
            button_text: "Call"
        }

        WAButton{
            button_color: "#dc0a0a";
            button_text: "Block"
        }

    }


}
