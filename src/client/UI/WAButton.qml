import QtQuick 1.0

Rectangle {
    property string button_color:"blue"
    property string button_text;
    property string text_color: "white"
    property string border_color:button_color
    width: 100
    height: 35
    color:button_color
    radius: 5
    //border.color: border_color


    Text{
        text:button_text;
        anchors.centerIn: parent;
        color:text_color
        font.pointSize: 14
    }

}
