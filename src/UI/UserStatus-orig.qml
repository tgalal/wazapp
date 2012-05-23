import QtQuick 1.1
import com.nokia.meego 1.0

Rectangle {
    id:container

    property string lastSeenOn;
    property string prevState;
    property int itemwidth

    state: "default"
    color:"transparent"

    function setOnline(){

        container.state="online"
    }

    function setOffline(secondsAgo){


        var d = new Date();

        if(secondsAgo){
            d.setSeconds(Qt.formatDateTime ( d, "ss" )-secondsAgo)


            if(container.state != "online" && container.state!="typing"){
                 lastSeenOn = Qt.formatDateTime(d,"hh:mm ap dd.MM.yyyy");
                 container.state="offline"
            }
        }
        else{
             lastSeenOn = Qt.formatDateTime(d,"hh:mm ap dd.MM.yyyy");
             container.state="offline"
        }

       // d = secondsAgo?d.addSecs(-secondsAgo):d


    }

    function setTyping(){
        prevState = container.state;
        container.state="typing";
    }

    function setPaused(){
        if(prevState == "online")
            container.state = prevState;
        else
            setOffline();
    }

    Label{
        id:userstatus
        anchors.verticalCenter: parent.verticalCenter;
        font.pixelSize: 18
	wrapMode: Text.WordWrap
	width: itemwidth
    }

    states: [
        State {
            name: "online"

            PropertyChanges {
                target: userstatus
                text: "Online"
            }
        },

        State {
            name: "default"

            PropertyChanges {
                target: userstatus
                text: ""
            }
        },

        State{
            name:"offline"
            PropertyChanges {
                target: userstatus
                text: "Last seen on "+lastSeenOn

            }
        },
        State{
            name:"typing"
            PropertyChanges{
                target: userstatus
                text:"Typing"
            }
        }

    ]
}
