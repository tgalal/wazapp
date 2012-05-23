// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1

Rectangle {

    height: 20
    width:60
    opacity: 0.5

    color:"transparent"

    Rectangle
    {
        width: 1
        height:parent.height
        color:"white"
        anchors.left: parent.left
    }

    Rectangle
    {
        width: 1
        height:parent.height
        color:"white"
        anchors.right: parent.right
    }
}
