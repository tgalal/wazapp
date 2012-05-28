import QtQuick 1.0

Rectangle {
    property int tabsHeight: 50
    property int viewHeight:height-tabsHeight
    anchors.fill: parent

    //View window

    Rectangle{

        id:viewContainer
        width:parent.width
        anchors.top: parent.top
        anchors.bottom: parent.bottom


        Contacts{
            id:contactsView
        }

    }


    //tabs
    Rectangle{
        id:tabBar
        height:tabsHeight
        width: parent.width

        anchors.bottom: parent.bottom



        Row{
            spacing:1
            anchors.fill: parent
            Tab{
                name:"Chats"
                MouseArea{
                    anchors.fill: parent;
                    onClicked: contactsView.visible =false
                }
            }

            Tab{
                name:"Contacts"

                MouseArea{
                    anchors.fill: parent;
                    onClicked: contactsView.visible =true
                }

            }
        }


    }

    //tabs
}
