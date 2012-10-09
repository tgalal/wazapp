import QtQuick 1.1
import com.nokia.meego 1.0
import "js/createobject.js" as ObjectCreator
import "js/settings.js" as MySettings

Item {

    property alias title: title.text
	property string subtitle
    property string initialValue
	property string profile

    x: 0
    width: parent.width
    height: 72

	Component.onCompleted: {
		MySettings.initialize()
		getSubtitle()
	}

	function getSubtitle() {
		var res = initialValue.split('/')
		res = res[res.length-1]
		subtitle = res.charAt(0).toUpperCase() + res.slice(1);
		subtitle = subtitle.split('.')[0]
		if (subtitle=="No sound") subtitle = qsTr("(no sound)")
	}

	Connections {
		target: appWindow
		onSetRingtone: {
			if (currentSelectionProfile==profile) {
				initialValue = ringtonevalue
				getSubtitle()
				MySettings.setSetting(currentSelectionProfile, ringtonevalue)
				if (currentSelectionProfile=="GroupRingtone")
					setGroupRingtone(ringtonevalue)
				else
					setPersonalRingtone(ringtonevalue)
			}
		}
	}


    /*Rectangle {
        id: highlight

        anchors { fill: parent; bottomMargin: 1; topMargin: 1 }
        color: mouseArea.pressed ? "#4d4d4d" : "transparent"
        opacity: 0.5
        smooth: true
    }*/


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
            text: subtitle
            font.pixelSize: 22
        }
    }

    Image {
        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
        source: "file:///usr/share/themes/blanco/meegotouch/images/theme/basement/meegotouch-button/meegotouch-combobox-indicator" + (theme.inverted? "-inverted" : "") + ".png"
        sourceSize.width: width
        sourceSize.height: height
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        onClicked: {
			currentSelectionProfile = profile
			currentSelectionProfileValue = initialValue
 	        //bDialog = ObjectCreator.createObject(Qt.resolvedUrl("MusicBrowserDialog.qml"), appWindow.pageStack);
        	//bDialog.open();
			pageStack.push(Qt.resolvedUrl("MusicBrowserDialog.qml"))
		}
    }

}
