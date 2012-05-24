import QtQuick 1.0

Rectangle {
    property string status: "offline"
    id:indicator
    width: 15
    height: 15
    radius:20

    color: "transparent"

    states: [
        State {
            name: "online"
            PropertyChanges {
                target: indicator
                color:"green"
            }
        },

        State {
        name: "offline"
        PropertyChanges {
        target: indicator
        color:"red"
     }
    },

        State {
        name: ""
        PropertyChanges {
        target: indicator
        color:"gray"
     }
    }
    ]
}
