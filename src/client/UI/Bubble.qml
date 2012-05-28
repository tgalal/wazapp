import QtQuick 1.0

Rectangle {

    Component.onCompleted: state="opened"
    id: bubble
    property string message
    property bool from_me
    property string date
    radius: 5

    width: 300

    states: State {
        name: "opened"
        PropertyChanges {
            target: bubble
            opacity:1

        }

        PropertyChanges {
            target: content
            opacity:1

        }
    }

    transitions: [
        Transition {
            from: ""
            to: "opened"

            SequentialAnimation{

                NumberAnimation { target: bubble; property: "opacity";  duration: 150; easing.type: Easing.InOutQuad  }
                NumberAnimation{target:content; property:"opacity"; duration:150}

            }

        }
    ]

    //height: msg_text.height+10+msg_date.height
    height: msg_text.height+10+msg_date.height
    opacity:0
    color: from_me?"#cfd2d4":"#42b6f2";

    anchors.right: from_me?this.right:parent.right
    anchors.left: !from_me?this.left:parent.left
    anchors.rightMargin: 5
    anchors.leftMargin: 5

    Column{
        id:content
        //anchors.fill: parent
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width:parent.width
        //anchors.right: parent.right
        anchors.margins: 5
        opacity: 0

        Text{
                id:msg_text
                text:message;
                color:from_me?"black":"white"
                width:parent.width
                wrapMode: "WrapAtWordBoundaryOrAnywhere"
                anchors.left: parent.left
                anchors.leftMargin: 5
        }

        Text{
                id:msg_date

                color:from_me?"black":"white"
                text: Qt.formatDateTime(new Date(), "hh:mm")
                anchors.right: parent.right
                anchors.rightMargin: 5
                font.pointSize: 7
        }

    }




}
