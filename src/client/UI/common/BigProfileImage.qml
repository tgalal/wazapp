import QtQuick 1.1
import com.nokia.meego 1.0

WAPage {
    id:container

    tools: ToolBarLayout {
        id: toolBar
        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }
    }

	WAHeader{
        title: qsTr("Picture")
        anchors.top:parent.top
        width:parent.width
		height: appWindow.inPortrait? 73 : 0
    }


	Rectangle {
		anchors.fill: parent
		color: "transparent"

		Image {
			anchors.centerIn: parent
			source: bigProfileImage
			width: parent.width -10
			height: parent.height -10
			fillMode: Image.PreserveAspectFit
		}

	}

}
