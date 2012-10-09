import QtQuick 1.1
import com.nokia.meego 1.0
import "js/settings.js" as MySettings

Item {
	id: container

    property alias title: title.text
	property string subtitle
    property string initialValue

    signal clicked()

    x: 0
    width: parent.width
    height: 72

	Component.onCompleted: {
		MySettings.initialize()
		getSubtitle()
	}

	Connections {
		target: appWindow
		onSetBackground: {
			var result = backgroundimg.replace("file://","")
			myBackgroundImage = result
			initialValue = result
			getSubtitle()
			MySettings.setSetting("Background", result)
		}
	}

	function getSubtitle() {
		var res = initialValue.split('/')
		res = res[res.length-1]
		subtitle = res.charAt(0).toUpperCase() + res.slice(1);
		//subtitle = subtitle.split('.')[0]
		if (subtitle=="None") subtitle = qsTr("(no background)")
	}



    Column {

        anchors { left: parent.left; leftMargin: 0; verticalCenter: parent.verticalCenter }

        Label {
            id: title
		    font.pixelSize: 24
		    font.bold: true
            color: theme.inverted? "white" : "black"
            verticalAlignment: Text.AlignVCenter
        }

        Label {
            id: subTitle
            color: "gray"
            verticalAlignment: Text.AlignVCenter
            text: subtitle=="none" ? qsTr("(no background)") : subtitle
            font.pixelSize: 22
        }
    }

    Image {
        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
        source: "../common/images/next" + (theme.inverted? "-inverted" : "") + ".png"
        height: 36
        width: 36
		smooth: true
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: container.clicked()
    }


}
