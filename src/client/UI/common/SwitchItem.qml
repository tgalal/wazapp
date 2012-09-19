import QtQuick 1.1
import com.nokia.meego 1.0

Item {
    id: itemcontainer
    property string title
    property bool check
    signal checkChanged(string value)

    SwitchStyle {
        id: mySwitchStyle
        switchOn: "image://theme/color3-meegotouch-switch-on"+__invertedString
    }

    width: parent.width
    height: 50

    Label {
        text: title
        horizontalAlignment: Text.AlignRight
        font.pixelSize: 24
        font.bold: true
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        color: theme.inverted ? "white" : "black"
    }
    Switch {
        id: sw
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        checked: check
		platformStyle: mySwitchStyle
        onCheckedChanged: {
            itemcontainer.checkChanged(sw.checked? "Yes" : "No")
        }
    }


}
