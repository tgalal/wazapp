import QtQuick 1.0

Rectangle {
    id:container
    width: parent.width
    height: 30
    color: "#dedddd"
    signal clicked()
    z: 1

    WAButton{

        button_color: "white"
        button_text: "Back"
        text_color: "gray"
        height:25
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 5

        MouseArea{
            anchors.fill: parent;
            onClicked: container.clicked()
        }
    }

    //border
    Rectangle
    {
        width:parent.width
        anchors.top: parent.bottom
        height:2
        color:"white"
    }
}

