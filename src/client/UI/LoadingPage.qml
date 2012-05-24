import QtQuick 1.1
import com.nokia.meego 1.0

Page{
    property string operation: "Loading"
    property alias buttonOneText: buttonOne.text
    property alias buttonTwoText: buttonTwo.text

    property int timeout:0;

    signal buttonOneClicked()
    signal buttonTwoClicked();

    function startTimer(msecs){

        timeout_timer.interval = msecs
        timeout_timer.start();
    }

    Component.onCompleted: {

        if(timeout !=0){
            timeout_timer.interval = timeout

        }

    }


    Timer {
        id:timeout_timer
        running: false;
        repeat: false
        onTriggered: {
            timout_text.visible = true
            timout_buttons.state="visible"
            }
    }


    WAHeader{
        title: "Refreshing"
        anchors.top:parent.top
        width:parent.width
    }
    Column{
        spacing:5;
        anchors.left:parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter


        Label{
            text:operation
            horizontalAlignment: Text.AlignHCenter
            width:parent.width
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        ProgressBar{
            indeterminate: true
            width:parent.width-32
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Label{
            id:timout_text
            text:"Taking too long?"
            width:parent.width
            horizontalAlignment: Text.AlignHCenter
            visible: false
        }

        Column{
            id:timout_buttons
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10

            states: [
                State {
                    name: "visible"
                    PropertyChanges {
                        target: buttonOne
                        visible:buttonOne.text!="";
                    }
                    PropertyChanges {
                        target: buttonTwo
                        visible:buttonTwo.text!="";
                    }
                }
            ]

            Button{
                id:buttonOne
                visible:false
                onClicked:buttonOneClicked()
                //text:"Button one"
            }

            Button{
                id:buttonTwo
                visible:false
                onClicked: buttonTwoClicked()
                //text:"Button two"
            }
        }
    }


}
