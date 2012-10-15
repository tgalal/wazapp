import QtQuick 1.1
import com.nokia.meego 1.0

Item {
	id: container

    property alias title: title.text
	property string subtitle

    signal clicked()

    x: 0
    width: parent.width
    height: 72

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
            text: subtitle
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
