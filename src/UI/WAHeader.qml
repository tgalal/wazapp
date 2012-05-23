import QtQuick 1.1
import com.nokia.meego 1.0

Rectangle{
    width:parent.width
    height:100;
   // anchors.top:parent.top
    property alias title:pageTitle.text
    color:"transparent"

    Image{
        id:wazapp_icon
        anchors.left: parent.left
		anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        height:72
        width:height
		smooth: true
        source:'pics/wazapp80.png'
    }

    Label{
        id:mainTitle
        text: "Wazapp"
        color:"#27a01b"
        font.pixelSize: 32
        y: 12
        anchors.left: wazapp_icon.right
        anchors.leftMargin: 12
    }

    Label{
        id: pageTitle
        color: theme.inverted? "white" : "darkgray"
        anchors.left: wazapp_icon.right
        anchors.leftMargin: 12
        font.pixelSize: 24
        y: 52		
    }

	Rectangle {
		x: 0; y: 98
		width: parent.width
		height: 1
		color: "gray"
		opacity: 0.6
	}
    /*Separator{
        bottom_margin: 5
        top_margin: 10

        anchors.bottom: parent.bottom
        width:parent.width

    }*/
}
