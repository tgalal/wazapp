import QtQuick 1.1
import com.nokia.meego 1.0


Sheet {

    Component.onCompleted: {
        dialogOpened()
        titleInput.forceActiveFocus();
        myTextFieldStyle.selectionColor = fileInfo.selColor(currentThemeColor)
    }


    visualParent: parent
    //rejectButtonText: qsTr("Cancel")
    //acceptButtonText: qsTr("Done")

    SheetButtonAccentStyle {
        id: mySheetButtonAccentStyle
        background: "image://theme/color"+currentThemeColor+"-meegotouch-sheet-button-accent-background"
        pressedBackground: "image://theme/color"+currentThemeColor+"-meegotouch-sheet-button-accent-background-pressed"
    }


    Item {
        id: myButtons
        width: parent.width
        height: 64
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
        }
    }

    buttons: myButtons

    onAccepted: {
 

        commonTools.enabled = true
        dialogClosed()
    }

    onRejected: {
        commonTools.enabled = true
        dialogClosed()
    }


    content: ListView {
        id: content
        anchors.fill: parent
        model: ringtoneModel
		delegate: myDelegate

    }

    Component{
        id: myDelegate

        Rectangle
		{
			property string name
			property string filetype

			property bool isSelected: false

			height: 72
			width: appWindow.inPortrait? 480:854
			color: "transparent"
			clip: true

			Rectangle {
				anchors.fill: parent
				color: theme.inverted? "darkgray" : "lightgray"
				opacity: theme.inverted? 0.2 : 0.8
				visible: mouseArea.pressed || isSelected
			}

		    Image {
		        id: contact_picture
				x: 16
		        size:62
		        imgsource: fileType=="folder"? "image://theme/icon-m-content-audio" : "image://theme/icon-m-content-folder"
		        anchors.topMargin: -2
				y: 8
		    }

		    Label {
				y: 9
				x: 90
				width: parent.width -100
				anchors.verticalCenter: parent.verticalCenter
	            text: name
			    font.pointSize: 18
				elide: Text.ElideRight
				width: parent.width -56
				font.bold: true

		    }

			MouseArea{
				id:mouseArea
				anchors.fill: parent
				onClicked:{
				    if (isSelected) {
						isSelected = false
					} else {
						isSelected = true
					}
				}
			}

		}
    }

    MouseArea {
        z: -1
        anchors.fill: parent
    }
}
