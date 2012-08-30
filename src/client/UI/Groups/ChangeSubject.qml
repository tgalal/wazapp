import QtQuick 1.1
import com.nokia.meego 1.0


Sheet {

    Component.onCompleted: {
        titleInput.forceActiveFocus();
		dialogOpened = true
    }

    visualParent: appWindow.pageStack

	//orientationLock: settingsPage.orientation==2 ? PageOrientation.LockLandscape:
    //            	settingsPage.orientation==1 ? PageOrientation.LockPortrait : PageOrientation.Automatic

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
            onClicked: accept()
            enabled: titleInput.text!=""
        }
    }

    buttons: myButtons

    onAccepted: {
		setGroupSubject(profileUser, titleInput.text)
		dialogOpened = false
    }

	onRejected: {
		dialogOpened = false
	}

    content: Item {
        id: content
        anchors.fill: parent

        Rectangle {
            anchors.fill: parent
            color: theme.inverted ? "black" : "#f7f7ff"
            anchors.topMargin: 0

            Column {
                spacing: 16
                anchors { top: parent.top; left: parent.left; right: parent.right; }
				anchors.topMargin: 26
                anchors.leftMargin: 16
                anchors.rightMargin: 16

                Label {
                    color: theme.inverted ? "white" : "black"
                    text: qsTr("Enter new subject:")
                }

                TextField {
                    id: titleInput
                    text: groupSubject
                    width: parent.width
                }
            }

        }
    }

    MouseArea {
        z: -1
        anchors.fill: parent
    }
}
