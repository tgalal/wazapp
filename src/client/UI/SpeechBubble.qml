// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0



BorderImage {
    id: bubble

    property string picture;
    property string message;
    property bool from_me;
    property string date;
    property string name;
    property int msg_id;
    property string state_status;

    property int inboundBubbleColor: 8
    property int outboundBubbleColor: 1

    QtObject {
        id: d
        property int inboundBubbleNumber: parseInt( (bubble.inboundBubbleColor / 2) + 0.5 )
        property int outboundBubbleNumber: parseInt( (bubble.outboundBubbleColor /2) + 0.5 )
        property string inboundBubbleState: (bubble.inboundBubbleColor % 2) == 0 ? "pressed" : "normal"
        property string outboundBubbleState: (bubble.outboundBubbleColor % 2) == 0 ? "pressed" : "normal"
    }

    anchors.right: from_me?this.right:parent.right
    anchors.left: !from_me?this.left:parent.left
    anchors.rightMargin: 10
    anchors.leftMargin: 10

    state: state_status;

    signal optionsRequested();

    width: calcBubbleWidth()
    //height:msg_text.height+msg_date.height+margin1.height+margin2.height+margincenter.height+10;
    height: content.height + 22
    //color: from_me? "gray" : "red"

    function calcTextWidth() {
        return Math.max(calcLabel.width, msg_date.width)
    }

    function calcLabelWidth() {
        return Math.min(calcLabel.width, bubble.maxWidth);
    }

    function calcBubbleWidth() {
        return Math.min(calcTextWidth()+10, bubble.maxWidth+10);
    }

    TextFieldStyle {
        id: textFieldStyle
    }

    Label {
        id: calcLabel
        text: bubble.message
        visible: false
        font.family: textFieldStyle.textFont
        font.pixelSize: textFieldStyle.textFont.pixelSize
    }

    border {
        left: 22
        right: 22
        bottom: bubble.direction == from_me ? 36 : 22
        top: bubble.direction == from_me ? 22 : 36
    }

    source: bubble.direction == from_me ?
                "image://theme/meegotouch-messaging-conversation-bubble-incoming" + d.inboundBubbleNumber + "-" + d.inboundBubbleState :
                "image://theme/meegotouch-messaging-conversation-bubble-outgoing" + d.outboundBubbleNumber + "-" + d.outboundBubbleState

    states: [
        State {
            name: "sending"
            PropertyChanges {
                target: status
                source: "pics/indicators/sending.png"
            }
        },
        State {
            name: "pending"
            PropertyChanges {
                target: status
                source: "pics/indicators/pending.png"
            }
        },
        State {
            name: "delivered"
            PropertyChanges {
                target: status
                source: "pics/indicators/delivered.png"
            }
        }
    ]

    MouseArea{
        anchors.fill: parent
        /*onClicked: {
            console.log("CLICKED!!!");
             optionsRequested();
        }*/

        onPressAndHold:{
            console.log("pressed and held!")
            optionsRequested();
        }
    }

    Image {
        id: status
        visible: from_me
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.bottom:parent.bottom
        anchors.bottomMargin: 22

    }
    Column{
        id:content

        Rectangle {
            id: margin1;
            height: from_me? 14 : 14
            width: parent.width;
            color: "transparent"
        }

        /*Label{
            id:sender_name
            width:parent.width -20
            color:appWindow.stealth?colorPicker.color:(from_me?"black":"white")
            text:from_me?"You":name
            font.pixelSize: 20
            font.bold: true
            anchors.left: parent.left
            anchors.leftMargin: 10
                            horizontalAlignment: from_me? Text.AlignLeft : Text.AlignRight
        }*/
        Label{
            id:msg_text
            text:message
            color:appWindow.stealth?colorPicker.color:(from_me?"black":"white")
            width: calcLabelWidth()
            wrapMode: "WrapAtWordBoundaryOrAnywhere"
            anchors.left: parent.left
            anchors.leftMargin: 10
            textFormat: Text.RichText
            font.pixelSize: 22
            font.family: textFieldStyle.textFont
            //horizontalAlignment: from_me? Text.AlignLeft : Text.AlignRight
            onLinkActivated: Qt.openUrlExternally(link);
        }

        /*Separator{
            top_margin: 5;
            bottom_margin: 2;
            visible:!appWindow.stealth
        }*/

        Label{
            id:colorPicker
            visible:false
        }

        Rectangle {
            id: margincenter;
            height: 4
            width: parent.width;
            color: "transparent"
        }

        Label{
            id:msg_date
            color:appWindow.stealth?colorPicker.color:(from_me?"black":"white")
            text: date
            width:parent.width - 20
            anchors.left: parent.left
            anchors.leftMargin: 10
            font.pixelSize: 18
            font.family: textFieldStyle.textFont
            horizontalAlignment: from_me? Text.AlignLeft : Text.AlignRight
            opacity: 0.8
        }

        Rectangle {
            id: margin2;
            height: 8
            width: parent.width;
            color: "transparent"
        }
    }
}
