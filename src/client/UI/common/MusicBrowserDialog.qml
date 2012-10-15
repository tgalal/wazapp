import QtQuick 1.1
import com.nokia.meego 1.0
import "js/createobject.js" as ObjectCreator

WAPage {
	id: dialog
	x:0; y:0

    Component.onCompleted: {
        dialogOpened = true
		var currentValue = ""
		consoleDebug("TONE: " + currentSelectionProfileValue)
		if (currentSelectionProfileValue.indexOf("/home/user/MyDocs/")>-1) {
			var res = currentSelectionProfileValue.split('/')
			res = res[res.length-1]
			res = res.charAt(0).toUpperCase() + res.slice(1);
			consoleDebug("APPENDING CUSTOM RINGTONE: " + res)
			ringtoneModel.insert(1, {"name":res.split('.')[0], "value":currentSelectionProfileValue});
		} else {
			if (ringtoneModel.get(1).value.indexOf("/home/user/MyDocs")>-1)
				ringtoneModel.remove(1)
		}
		for (var i=0; i<ringtoneModel.count; i++) {
			if (ringtoneModel.get(i).value==currentSelectionProfileValue) {
				currentSelected = i
				break;
			}
		}
    }

	Connections {
		target: appWindow
		onCustomRingtoneSelected: currentSelected = 1
	}

    signal valueChosen(string value)

	property int currentSelected	

    SheetButtonAccentStyle {
        id: mySheetButtonAccentStyle
        background: "image://theme/color3-meegotouch-sheet-button-accent-background"
        disabledBackground: "image://theme/color3-meegotouch-sheet-button-accent-background-disabled"
        pressedBackground: "image://theme/color3-meegotouch-sheet-button-accent-background-pressed"
    }


    Item {
        id: myButtons
        width: parent.width
		y: 0
        height: 66

        SheetButton {
            id: rejectButton
            text:  qsTr("Cancel")
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            onClicked: reject()
        }
        SheetButton {
            id: acceptButton
            text:  qsTr("Done")
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            platformStyle: mySheetButtonAccentStyle
            onClicked: accept()
			enabled: currentSelected>0
        }

		Rectangle {
			height: 1
			width: parent.width
			x:0; y: 65
			color: "gray"
			opacity: 0.6
		}
		Rectangle {
			height: 1
			width: parent.width
			x:0; y: 66
			color: theme.inverted ? "lightgray" : "white"
			opacity: 0.8
		}	
    }


    function accept() {
		var newValue = ringtoneModel.get(currentSelected).value
		currentSelectionProfileValue = newValue
		setRingtone(newValue)
		stopSoundFile()
	    dialogOpened = false
		if (ringtoneModel.get(1).value.indexOf("/home/user/MyDocs")>-1)
			ringtoneModel.remove(1)
		pageStack.pop()
   }

    function reject() {
        dialogOpened = false
		if (ringtoneModel.get(1).value.indexOf("/home/user/MyDocs")>-1)
			ringtoneModel.remove(1)
		pageStack.pop()
    }

	Component {
		id: myDelegate

		Rectangle {
			property string title: model.name
			property string value: model.value
			color: "transparent"

			height: model.value=="browse" ? 80 : 72
			width: appWindow.inPortrait? 480:854

			Rectangle {
				x:0; y: 0; height: 72; width: parent.width
				color: theme.inverted? "darkgray" : "lightgray"
				opacity: theme.inverted? 0.2 : 0.8
				visible: mouseArea.pressed || currentSelected==index
			}

			Text {
				x: 13
				width: parent.width -32
				anchors.verticalCenter: parent.verticalCenter
		        text: title
				font.pointSize: 18
				elide: Text.ElideRight
				font.bold: true
				color: theme.inverted? "white" : "black"
			}

			Image {
				source: "image://theme/icon-m-common-drilldown-arrow" + (theme.inverted ? "-inverse" : "")
				height: 36
				width: 36
				smooth: true
				anchors.right: parent.right
				anchors.rightMargin: 16
				y: 18
				visible: model.value=="browse"
			}

			Rectangle {
				x: 10; y: 76; width: parent.width; height: 1
				color: theme.inverted? "gray" : "lightgray"
				visible: model.value=="browse"
			}

			MouseArea{
				id:mouseArea
				anchors.fill: parent
				onClicked:{
					if (value=="browse") {
			 	        //brDialog = ObjectCreator.createObject(Qt.resolvedUrl("MusicBrowserExtended.qml"), appWindow.pageStack);
						//brDialog.open();
						pageStack.push(Qt.resolvedUrl("MusicBrowserExtended.qml"))
					} else {
						currentSelected = index
						playSoundFile(model.value)
					}
				}
			}

		}
	}


	ListView {
		y: 67
		anchors.left: parent.left
		height: parent.height -67
		width: parent.width
	    model: ringtoneModel
		delegate: myDelegate
		clip: true
	}

}
