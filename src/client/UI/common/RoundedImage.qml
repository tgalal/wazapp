import QtQuick 1.1
import com.nokia.meego 1.0

Item {
    id: container

    property string imgsource
    property int size
    property bool rounded: imgsource.indexOf("image://")!=0
	property string istate: "Loading..."
    property alias  asynchronous: image1.asynchronous

	//signal clicked
	//signal pressAndHold

    height: size
    width: size

    MaskedItem {
        id: mask
        x:0; y:0
        width: size
        height: size

        mask: Image {
            width: size
            height: size
            smooth: true
            fillMode: Image.Stretch
            source: "images/usermask.png"
        }

        Image
        {
            id: image1
            x:0; y:0
            width: size
            height: size
            smooth: true
            fillMode: Image.PreserveAspectCrop
			cache: false
            source: imgsource //imgsource.indexOf("@")>-1 ? "" : imgsource
			onStatusChanged: {
                if (image1.status==Image.Ready) istate="Loaded!";
				if (image1.status==Image.Error) istate=imgsource;
            }
        }
    }

    Image
    {
        x:0; y:0
        width: size
        height: size
        smooth: true
        asynchronous: true
        fillMode: Image.Stretch
        source: "images/userborder.png"
        visible: imgsource != "" && rounded
    }

    /*MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: container.clicked()
		onPressAndHold: container.pressAndHold()
    }*/

}
