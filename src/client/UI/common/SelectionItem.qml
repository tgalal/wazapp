import QtQuick 1.1
import com.nokia.meego 1.0

Item {
	id: container

    property alias title: title.text
    property string initialValue

    signal clicked()

    x: 0
    width: parent.width
    height: 72

    /*Rectangle {
        id: highlight

        anchors { fill: parent; bottomMargin: 1; topMargin: 1 }
        color: mouseArea.pressed ? "#4d4d4d" : "transparent"
        opacity: 0.5
        smooth: true
    }*/


    Column {

        anchors { left: parent.left; leftMargin: 0; verticalCenter: parent.verticalCenter }

        Label {
            id: title
		    font.pixelSize: 24
		    font.bold: true
            color: theme.inverted? "white" : "black"
            verticalAlignment: Text.AlignVCenter
        }

        Label {
            id: subTitle
            color: "gray"
            verticalAlignment: Text.AlignVCenter
            text: initialValue
            font.pixelSize: 22
        }
    }

    Image {
        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
        source: "../common/images/next" + (theme.inverted? "-inverted" : "") + ".png"
        height: 36
        width: 36
		smooth: true
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        onClicked: container.clicked()
    }


}
