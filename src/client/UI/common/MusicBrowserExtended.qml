import QtQuick 1.1
import com.nokia.meego 1.0

WAPage {

	id: dialog

    Component.onCompleted: {
        dialogOpened = false
		appWindow.browseFiles("/home/user/MyDocs", "mp3, MP3, wav, WAV");
    }

    signal valueChosen(string value)

	property int currentSelected	

    SheetButtonAccentStyle {
        id: mySheetButtonAccentStyle
        background: "image://theme/color3-meegotouch-sheet-button-accent-background"
        disabledBackground: "image://theme/color3-meegotouch-sheet-button-accent-disabled"
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
			enabled: currentSelected>-1 && (browserModel.get(currentSelected).filetype=="send-audio")
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
		var newValue = browserModel.get(currentSelected).value
		if (ringtoneModel.get(1).value.indexOf("/home/user/MyDocs")>-1)
			ringtoneModel.remove(1)

		var res = browserModel.get(currentSelected).fileName
		res = res.charAt(0).toUpperCase() + res.slice(1);
		consoleDebug("APPENDING CUSTOM RINGTONE: " + res)
		ringtoneModel.insert(1,{ "name": res.split('.')[0], "value": browserModel.get(currentSelected).filepath })
		customRingtoneSelected()
		stopSoundFile()
		pageStack.pop()
    }

    function reject() {
        stopSoundFile()
		pageStack.pop()
		dialogOpened = true
    }

	Component {
		id: myDelegate

		Rectangle {
			property string title: model.fileName
			property string value: model.filepath
			property string filetype: model.filetype
			
			color: "transparent"

			height: 72
			width: appWindow.inPortrait? 480:854

			Rectangle {
				anchors.fill: parent
				color: theme.inverted? "darkgray" : "lightgray"
				opacity: theme.inverted? 0.2 : 0.8
				visible: mouseArea.pressed || currentSelected==index
			}

			Image {
				x: 16
			    height: 62; width: 62; smooth: true
			    source: "images/" + model.filetype + (theme.inverted?"-white":"") + ".png"
				anchors.verticalCenter: parent.verticalCenter
			}

			Text {
				x: 92
				width: parent.width -106
				anchors.verticalCenter: parent.verticalCenter
		        text: title
				font.pointSize: 18
				elide: Text.ElideRight
				font.bold: true
				color: theme.inverted? "white" : "black"
			}

			MouseArea{
				id:mouseArea
				anchors.fill: parent
				onClicked:{
					stopSoundFile()
					if (model.filetype=="folder") {
						appWindow.browseFiles(model.filepath, "mp3, MP3, wav, WAV");
					} else {
						currentSelected = index
						playSoundFile(model.filepath)
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
	    model: browserModel
		onCountChanged: currentSelected=-1
		delegate: myDelegate
		clip: true
	}

    tools: ToolBarLayout {
        id: toolBar
        ToolIcon {
            platformIconId: "toolbar-up";
			enabled: enableBackInBrowser
			opacity: enabled? 1 : 0.4
            onClicked: {
				var i = currentBrowserFolder.lastIndexOf("/");
				var f = currentBrowserFolder.slice(0,i)
				appWindow.browseFiles(f, "mp3, MP3, wav, WAV");
			}
        }
    }

}
