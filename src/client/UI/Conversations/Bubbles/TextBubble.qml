// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0

SpeechBubble {
    property string message;
	childrenWidth: msg_text.paintedWidth

	bubbleContent: Label {
		id:msg_text
		text: message
		color: from_me ? "black" : "white"
		width: (appWindow.inPortrait ? 380 : 754)
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
