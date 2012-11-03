// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0

import "../common"

WAPage {

    id:imgviewerRoot

    tools:imgtools

    property string imagePath;
    property string defaultImage:defaultProfilePicture
    property int imageWidth:width;
    //property int imageHeight:height;
    state:"loaded"

    states: [

        State {
            name: "loaded"
            PropertyChanges {
                target:imloading
                visible:false;
            }

            PropertyChanges{
                target:externalOpenBtn
                visible:imagePath!=""
            }
        },

        State {
            name: "updating"
            PropertyChanges {
                target: imloading
                visible: true;
            }
            PropertyChanges {
                target:externalOpenBtn
                visible:false
            }
        }
    ]


    Image {
        id: currIm
        source: imagePath?imagePath:defaultImage

        anchors.centerIn: parent
        //anchors.horizontalCenter: parent.horizontalCenter
        //anchors.top: parent.top
        width:currIm.sourceSize.width < imageWidth?currIm.sourceSize.width : currIm.sourceSize.width
        //height:imageHeight
        asynchronous: true
        fillMode: Image.PreserveAspectFit
    }

    BusyIndicator{
        id:imloading
        platformStyle: BusyIndicatorStyle { size: "large";}
        anchors.centerIn: parent
        z:1
        visible:false
        running: imloading.visible
    }



    ToolBarLayout {
        id:imgtools

        ToolIcon{
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }

        ToolButton
        {
            id:externalOpenBtn
            anchors.centerIn: parent
            text: qsTr("Open in Gallery")
            onClicked: {
                Qt.openUrlExternally(imagePath)
            }

        }


    }
}
