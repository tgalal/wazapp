import QtQuick 1.1
import com.nokia.meego 1.0


Sheet {

    Component.onCompleted: {
        //showToolbars = false
        titleInput.forceActiveFocus();
    }

    visualParent: parent

    
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
            //platformStyle: mySheetButtonAccentStyle
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
            enabled: titleInput.text!=""
        }
    }

    buttons: myButtons

	function setStatus(num,msg) {
        //final ProcessBuilder pb = new ProcessBuilder("/opt/waxmppplugin/bin/status ", num.toString(), "\""+ msg +"\"");
		//final Process p = pb.start();
		shell_exec("/opt/waxmppplugin/bin/status "+ num.toString() + " \"" + msg + "\"");
	}

    onAccepted: {
		setStatus(5491133302246, titleInput.text);
    }

    onRejected: {
        //showToolbars = true
    }


    content: Item {
        id: content
        anchors.fill: parent

        Rectangle {
            anchors.fill: parent
            color: theme.inverted ? "black" : "#f7f7ff"

            Column {
                spacing: 16
                anchors { top: parent.top; left: parent.left; right: parent.right; margins: 10 }
                anchors.leftMargin: 16
                anchors.rightMargin: 16

                Label {
                    color: theme.inverted ? "white" : "black"
                    text: qsTr("Enter new status")
                }

                TextField {
                    id: titleInput
                    text: ""
                    width: parent.width
                    platformStyle: myTextFieldStyle
                }
            }

        }
    }

    MouseArea {
        z: -1
        anchors.fill: parent
    }
}
