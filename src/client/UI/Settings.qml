/***************************************************************************
**
** Copyright (c) 2012, Tarek Galal <tarek@wazapp.im>
**
** This file is part of Wazapp, an IM application for Meego Harmattan
** platform that allows communication with Whatsapp users.
**
** Wazapp is free software: you can redistribute it and/or modify it under
** the terms of the GNU General Public License as published by the
** Free Software Foundation, either version 2 of the License, or
** (at your option) any later version.
**
** Wazapp is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
** See the GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with Wazapp. If not, see http://www.gnu.org/licenses/.
**
****************************************************************************/
import QtQuick 1.1
import com.nokia.meego 1.0

Page {
    id: root

	signal syncClicked();

	orientationLock: myOrientation==2 ? PageOrientation.LockLandscape:
			myOrientation==1 ? PageOrientation.LockPortrait : PageOrientation.Automatic

	Component.onCompleted: {
        syncClicked.connect(onSyncClicked)
    }

    tools: ToolBarLayout {
        id: toolBar

        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }

        ToolButton
        {
			anchors.horizontalCenter: parent.horizontalCenter
			width: 300
            text: qsTr("Quit Wazapp")
            onClicked: appWindow.quitInit()
        }

		ToolIcon
        {
            iconSource: "pics/about" + (theme.inverted ? "-white" : "") + ".png";
            onClicked: { aboutDialog.open() }
        }
    }

	TextFieldStyle {
        id: myTextFieldStyle
        backgroundSelected: ""
        background: ""
		backgroundDisabled: ""
		backgroundError: ""
    }

    QueryDialog {
        property string phone_number;
        id:aboutDialog
        //anchors.fill: parent
		icon: "pics/wazapp80.png"
        titleText: "Wazapp" //This should not be translated!
        message: qsTr("version") + " " + waversion + "\n\n" + 
                 qsTr("This is a %1 version.").arg(waversiontype) + "\n" + 
				 qsTr("You are trying it at your own risk.") + "\n" + 
				 qsTr("Please report any bugs to") + "\n" + "tarek@wazapp.im"
 
    }

	WAHeader{
        title: qsTr("Settings")
        anchors.top:parent.top
        width:parent.width
		height: 73
    }

    Flickable {
        id: flickArea
        anchors.top: parent.top
        anchors.topMargin: 73
        height: parent.height -73
		width: parent.width
        contentWidth: width
        contentHeight: column.height + 40
		clip: true

        Column {
            id: column
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 16 }
            spacing: 10

			GroupSeparator {
				title: qsTr("Whatsapp")
			}

			Rectangle {
				color: "transparent"
				width: parent.width
				height: 40
				Label {
					width: parent.width
					anchors.verticalCenter: parent.verticalCenter
					text: qsTr("Server status:")
				}
				Label {
					width: parent.width
					anchors.verticalCenter: parent.verticalCenter
					horizontalAlignment: Text.AlignRight
					text: qsTr("Online")
					color: "green"
				}
            
			}
			Button {
				width: parent.width
				text: qsTr("Sync contacts")
				onClicked: { console.log("SYNC"); syncClicked(); }
			}

			GroupSeparator {
				title: qsTr("Status")
			}
			Button {
				width: parent.width
				onClicked: pageStack.push (Qt.resolvedUrl("ChangeStatus.qml"))
				text: qsTr("Change status")
            }

			GroupSeparator {
				title: qsTr("Appearance")
			}
			Label {
				text: qsTr("Orientation:")
			}
			ButtonRow {
                Button {
                    text: qsTr("Automatic")
                    checked: myOrientation==0
                    onClicked: {
                        myOrientation=0
                    }
                }
                Button {
                    text: qsTr("Portrait")
                    checked: myOrientation==1
                    onClicked: {
                        myOrientation=1
                    }
                }
                Button {
                    text: qsTr("Landscape")
                    checked: myOrientation==2
                    onClicked: {
                        myOrientation=2
                    }
                }
            }

			Label {
				text: qsTr("Theme color:")
			}
			ButtonRow {
                id: br1
                Button {
                    text: qsTr("White")
                    checked: theme.inverted ? false : true
                    //platformStyle: myButtonStyleLeft
                    onClicked: {
                        theme.inverted = false
                    }
                }
                Button {
                    text: qsTr("Black")
                    checked: theme.inverted ? true : false
                    //platformStyle: myButtonStyleRight
                    onClicked: {
                        theme.inverted = true
                    }
                }
            }
			Label {
				text: qsTr("Bubble color:")
			}
			ButtonRow {
                id: br2
                Button {
                    text: qsTr("Cyan")
                    checked: bubbleColor==1
                    onClicked: {
                        bubbleColor=1
                    }
                }
                Button {
                    text: qsTr("Green")
                    checked: bubbleColor==4
                    onClicked: {
                        bubbleColor=4
                    }
                }
                Button {
                    text: qsTr("Pink")
                    checked: bubbleColor==3
                    onClicked: {
                        bubbleColor=3
                    }
                }
                Button {
                    text: qsTr("Orange")
                    checked: bubbleColor==2
                    onClicked: {
                        bubbleColor=2
                    }
                }
            }


		}

    }

    ScrollDecorator {
        flickableItem: flickArea
    }

}

