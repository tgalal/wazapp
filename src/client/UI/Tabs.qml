// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1

Rectangle {
    width: parent.width
    height: 30
    color: "#dedddd"
    id:container

    TabItem{

        anchors.right: parent.right
        anchors.rightMargin: 5
        anchors.verticalCenter: parent.verticalCenter

        Image{

            anchors.centerIn: parent

            source: "pics/settings_icon.png"
        }

        MouseArea{

            anchors.fill: parent
            onClicked: container.parent.state="contacts"
        }

    }
    Row{
        id:tab_items
        anchors.left: parent.left
        anchors.leftMargin: 5
        spacing:0
        anchors.verticalCenter: parent.verticalCenter

        TabItem{

            Image{

                id:chat_icon
                anchors.centerIn: parent
                source: "pics/chats_icon.png"
            }

            MouseArea{

                anchors.fill: parent
                onClicked: container.parent.state="chats"
            }

        }

        TabItem{

            Image{

                anchors.centerIn: parent
                source: "pics/contacts_icon.png"
            }

            MouseArea{

                anchors.fill: parent
                onClicked: container.parent.state="contacts"
            }

        }
    }




}
