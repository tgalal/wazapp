import QtQuick 1.1
import com.nokia.meego 1.0

Page {
    tools: initType == 2?editTools:commonTools

    Label {
        id: label
        anchors.centerIn: parent
        text: qsTr("Hello world! "+initType)
        visible: false
    }

    Label{
        id:debugLabel
        anchors.top:button.bottom
        text:("Debug VAL: "+debug_data);
    }

    Button{
        id:button;
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: label.bottom
            topMargin: 10
        }
        text: qsTr("Click here!")
        onClicked: label.visible = true
    }
}
