import QtQuick 1.1
import com.nokia.meego 1.0

Item {
    id: container

    property string imgsource
    property int size
    property bool rounded: imgsource.indexOf("image://")!=0
	property string istate: "Loading..."
    property alias  asynchronous: image1.asynchronous
	property bool showVideo: false

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

			Rectangle {
				id: rec
				color: "black"
				height: 20
				width: parent.width
				anchors.bottom: parent.bottom
				opacity: 0.4
				visible: showVideo
			}
			Image {
				anchors.centerIn: rec
				height: 16
				width: 16
				smooth: true
				source: "../common/images/video-white.png"
				visible: showVideo
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
