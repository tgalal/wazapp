// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0

SpeechBubble {
    property string message;
	childrenWidth: msg_text.paintedWidth

    function getAuthor(inputText) {
		if (message==myAccount)
			return qsTr("You")
        var resp = inputText;
        for(var i =0; i<contactsModel.count; i++)
        {
            if(resp == contactsModel.get(i).jid) {
                resp = contactsModel.get(i).name;
				break;
			}
        }
        return resp
    }

	bubbleContent: Label {
		id:msg_text
		text: from_me==20 ? qsTr("<b>%1</b> has join the group").arg(getAuthor(message)) :
			  from_me==21 ? qsTr("<b>%1</b> has left the group").arg(getAuthor(message)) :
			  from_me==22 ? qsTr("<b>%1</b> has changed the subject to <b>%2</b>").arg(name).arg(message) : 
			  from_me==23 ? qsTr("<b>%1</b> has changed the group picture").arg(getAuthor(message)) : message
		color: from_me==1 ? "black" : from_me==0 ? "white" : "gray"
		width: (appWindow.inPortrait ? 380 : 754)
		wrapMode: "WrapAtWordBoundaryOrAnywhere"
		anchors.left: parent.left
		anchors.leftMargin: from_me==20||from_me==21||from_me==22||from_me==23? 50 : from_me ? 20 : 80
		textFormat: Text.RichText
		font.family: "Nokia Pure Light"
		font.weight: Font.Light
		font.pixelSize: from_me==20||from_me==21||from_me==22||from_me==23 ? 18 : 23
		horizontalAlignment: from_me==20||from_me==21||from_me==22||from_me==23? Text.AlignHCenter : from_me==1? Text.AlignLeft : Text.AlignRight
		onLinkActivated: Qt.openUrlExternally(link);
	}
}
