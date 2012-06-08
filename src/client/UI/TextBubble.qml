// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0

SpeechBubble {
    property string message;
	childrenWidth: msg_text.paintedWidth
	msg_image: ""

	Component.onCompleted: {
		if (message.indexOf("wazappmms:")===0) {
			msg_image = "pics/user.png"
		}
		if (message.indexOf("wazapplocation:")===0) {
			msg_image = "pics/content-location.png"
		}


	}

	bubbleContent: Label {
		id:msg_text

		text: message.indexOf("wazappmms:")===0 ?message.replace("wazappmms:","").replace(".vcf","") : 
				message.indexOf("wazapplocation:")===0 ? qsTr("My location") : message
	    color: from_me ? "black" : "white"
	    width: (appWindow.inPortrait ? 380 : 754) - (msg_image=="" ? 0 : 66)
	    wrapMode: "WrapAtWordBoundaryOrAnywhere"
	    anchors.left: parent.left
		anchors.leftMargin: from_me ? 20 : 80
		font.family: "Nokia Pure Light"
	    font.weight: Font.Light
	    font.pixelSize: 23
		horizontalAlignment: from_me? Text.AlignLeft : Text.AlignRight
	    onLinkActivated: Qt.openUrlExternally(link);
	}

}
