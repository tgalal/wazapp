import QtQuick 1.1
import com.nokia.meego 1.0

Item {
    property string title

    width: parent.width
    height: 50
	clip: true

        Rectangle {
            id: sortingDivisionLine
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 0
            anchors.left: parent.left
            anchors.rightMargin: 20
            anchors.right: sortingLabel.left
            height: 1
            color: "gray"
            opacity: 0.3
        }

		Rectangle {
            anchors.top: sortingDivisionLine.bottom
            anchors.left: sortingDivisionLine.left
            width: sortingDivisionLine.width
            height: 1
            color: theme.inverted? "darkgray" : "white"
            opacity: theme.inverted? 0.3 : 0.5
        }

        Text {
            id: sortingLabel
            text: title
            font.pointSize: 14
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
            anchors.topMargin: 28
            anchors.right: parent.right
            anchors.rightMargin: 0
            color: "gray"
        }

}
