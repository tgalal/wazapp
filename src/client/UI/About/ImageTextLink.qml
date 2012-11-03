// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0
import "../common"


Button{
    id:root
    property alias source:img.source
    property alias text:linktext.text
    property string url;
    height:img.height + 10
    property bool inverted


    platformStyle: ButtonStyle{inverted: root.inverted;}

    Row{
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 5

        spacing: 10
        Image{
            id:img
            height:50
            fillMode: Image.PreserveAspectFit
        }
        Label{
            id:linktext
            anchors.verticalCenter: img.verticalCenter
            platformStyle: LabelStyle{inverted: root.inverted}
        }

    }

    onClicked: {
        if(url){
            Qt.openUrlExternally(url)
        }
    }
}
