// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1

Rectangle {


    id:container
    color:"transparent"

    states: [
        State {
            name: "connecting"
            PropertyChanges {
                target: curr_operation
                text:"Connecting"
            }

        },

        State {
            name: "refreshing"
            PropertyChanges {
                target: curr_operation
                text:"Refreshing Favorites"

            }
        },

        State {
            name: "connected"
            PropertyChanges {
                target: curr_operation
                text:"Connected"

            }
        },

        State {
            name: "disconnected"
            PropertyChanges {
                target: curr_operation
                text:"Disconnected"

            }
        }
    ]


    Text{

        id:curr_operation
        anchors.centerIn: parent;
        text:"Connecting"
        font.pointSize: 12

    }
}
