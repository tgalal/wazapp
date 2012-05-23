// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0

Rectangle{
    id:status_indicator
   // anchors.top: parent.top
    width:parent.width;
    height:50;
    color: "transparent";
    state:"offline"

    Label{
        id:current_state
        horizontalAlignment: Text.AlignHCenter
		anchors.bottom: parent.bottom
		anchors.bottomMargin: 8
        width:parent.width
    }

	Rectangle {
		height: 1
		width: parent.width
		anchors.left: parent.left
		anchors.bottom: parent.bottom
		color: "gray"
		opacity: 0.6
	}

    states: [

        State {
            name: "online"
            PropertyChanges {

                target: current_state
                text:"Online"
            }
            PropertyChanges{
                target:status_indicator
                //visible:false
                height:0;
            }

        },

        State {
            name: "connecting"
            PropertyChanges {
                target: current_state
                text:"Connecting..."

            }

            PropertyChanges{
                target:status_indicator
                //visible:true
                height:50;
            }
        },

        State {
            name: "reregister"
            PropertyChanges {
                target: current_state
                text:"Login failed. Either account expired or you need to remove your account from accounts manager and re-register"

            }

            PropertyChanges{
                target:status_indicator
                //visible:true
                height:70;
            }
        },
        State {
            name: "offline"
            PropertyChanges {
                target: current_state
                text:"Offline"

            }

            PropertyChanges{
                target:status_indicator
                //visible:true
                height:50;
            }
        },

        State {
            name: "sleeping"
            PropertyChanges {
                target: current_state
                text:""
            }
            PropertyChanges{
                target:status_indicator
                //visible:false
                height:0
            }
        }
    ]
	transitions: Transition {
        NumberAnimation { properties: "height"; easing.type: Easing.InOutQuad; duration: 500 }
    }

}
