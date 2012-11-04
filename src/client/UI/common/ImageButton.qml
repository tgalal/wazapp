// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1

Image {
    id:root
    opacity:pressed?0.5:1
    //property string pressedSource

    //property string _source
    signal clicked()

    property alias pressed:mouseArea.pressed

    MouseArea{
        id:mouseArea
        anchors.fill: parent
        onClicked: {
            root.clicked();
        }

    }
}
