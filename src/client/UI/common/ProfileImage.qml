import QtQuick 1.1
import com.nokia.meego 1.0

Item {
    id: container

    property string imgsource
    property int size
    property bool rounded: imgsource.indexOf("image://")!=0
	property string istate: "Loading..."
    property alias  asynchronous: image1.asynchronous

	signal clicked
	//signal pressAndHold

    height: size
    width: size

    states: [
        State {
            name: "loading"
            PropertyChanges {
                target: pictureLoadingIndicator
                visible: true

            }

            PropertyChanges {
                target: mask
                visible: false

            }


            PropertyChanges {
                target: img
                visible: false

            }
            PropertyChanges {
                target: mouseArea
                enabled: false

            }
        },

        State {
            name: ""
            PropertyChanges {
                target: pictureLoadingIndicator
                visible: false

            }

            PropertyChanges {
                target: mask
                visible: true

            }


            PropertyChanges {
                target: img
                visible: imgsource != "" && rounded

            }
            PropertyChanges {
                target: mouseArea
                enabled: true

            }
        }
    ]

    BusyIndicator{
        id:pictureLoadingIndicator
        implicitWidth: 96
        anchors.centerIn: parent
        visible:false
        running:visible
    }

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
            source: size>120? "images/usermask-large.png" : "images/usermask.png"
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
            source: imgsource.indexOf("@")>-1 ? "" : imgsource
			onStatusChanged: {
                if (image1.status==Image.Ready) istate="Loaded!";
				if (image1.status==Image.Error) istate=imgsource;
            }
        }
    }

    Image
    {
        id:img
        x:0; y:0
        width: size
        height: size
        smooth: true
        asynchronous: true
        fillMode: Image.Stretch
        source: size>120? "images/userborder-large.png" : "images/userborder.png"
        visible: imgsource != "" && rounded
    }

    MouseArea {
        id: mouseArea
		x:0; y:0
        width: size
        height: size
        onClicked: container.clicked()
		//onPressAndHold: container.pressAndHold()
    }

}
