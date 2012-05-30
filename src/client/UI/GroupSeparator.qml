import QtQuick 1.1
import com.nokia.meego 1.0

Item {
    property string title

    width: parent.width
    height: 50

        Rectangle {
            id: sortingDivisionLine
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 0
            anchors.left: parent.left
            anchors.rightMargin: 16
            anchors.right: sortingLabel.left
            height: 1
            color: "gray"
            opacity: 0.3
        }
        Text {
            id: sortingLabel
            text: title
            font.pointSize: 14
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
            anchors.topMargin: 12
            anchors.right: parent.right
            anchors.rightMargin: 0
            color: "gray"
        }

}
