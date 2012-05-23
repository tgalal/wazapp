import QtQuick 1.1
import com.nokia.meego 1.0

Item {
    id: container

    property string imgsource
    property int size
    property bool rounded: true

    //signal clicked

    height: size
    width: size

    MaskedItem {
        id: mask
        x:0; y:0
        width: size
        height: size
        visible: rounded

        mask: Image {
            width: size
            height: size
            smooth: true
            fillMode: Image.Stretch
            source: "pics/usermask.png"
        }

        Image
        {
            id: image1
            x:0; y:0
            width: size
            height: size
            smooth: true
            fillMode: Image.Stretch
            source: imgsource
        }
    }

    Image
    {
        x:0; y:0
        width: size
        height: size
        smooth: true
        fillMode: Image.Stretch
        source: "pics/userborder.png"
        visible: imgsource != "" && rounded
    }

    /*MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: container.clicked()
    }*/

}
