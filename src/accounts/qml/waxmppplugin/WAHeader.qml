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
        anchors.verticalCenter: parent.verticalCenter
        height:80
        width:height
       // source:'/usr/share/icons/hicolor/80x80/apps/waxmppplugin80.png'
        source:'images/wazapp80.png'
    }

    Label{
        id:mainTitle
        text: "Wazapp"
        color:"#27a01b"
        font.pixelSize: 40
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: wazapp_icon.right
        anchors.leftMargin: 10
    }

    Label{
        id:pageTitle
        color:"gray"
        anchors.left: mainTitle.right
        anchors.leftMargin: 5
        font.pixelSize: mainTitle.font.pixelSize
        anchors.verticalCenter: parent.verticalCenter
       // anchors.bottom:parent.bottom
        //anchors.bottomMargin: 20
       // font.italic: true
    }

    Separator{
        bottom_margin: 5
        top_margin: 10

        anchors.bottom: parent.bottom
        width:parent.width

    }
}
