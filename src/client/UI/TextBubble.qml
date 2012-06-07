// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0

SpeechBubble {
    property string message;

    //width: calcBubbleWidth()

    function calcTextWidth() {
        return Math.max(calcLabel.width+10, dataRow.width+20)
    }

    function calcLabelWidth() {
        return Math.min(calcLabel.width, (screen.currentOrientation == Screen.Landscape?screen.displayWidth:screen.displayHeight)-30);
    }

    function calcBubbleWidth() {
        return Math.min(calcTextWidth(), bubble.parent.width-60);
    }



    Label {
        id: calcLabel
        text: message
        visible: false
        font.family: textFieldStyle.textFont
        font.pixelSize: textFieldStyle.textFont.pixelSize
    }


    TextFieldStyle {
        id: textFieldStyle
    }

   bubbleContent:  Label{
                        id:msg_text

                        text:message
                        color: from_me?"black":"white"
                        width: calcLabelWidth()
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                       // x: dataRow.width+20 > width ? (dataRow.width-width)/2 : 0
                        textFormat: Text.RichText
                        font.pixelSize: 22
                        font.family: textFieldStyle.textFont
                        //horizontalAlignment: from_me? Text.AlignLeft : Text.AlignRight
                        onLinkActivated: Qt.openUrlExternally(link);
                    }


}
