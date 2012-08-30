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
import "../common/js/settings.js" as MySettings
import "../common"

WAPage {
    id: root

	signal syncClicked();

    //property int bubbleColor:1
    property int orientation

    Component.onCompleted: {
		MySettings.initialize()
		orientation = parseInt(MySettings.getSetting("Orientation", "0"))
        syncClicked.connect(onSyncClicked)
    }

    tools: ToolBarLayout {
        id: toolBar

        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }

        /*ToolButton
        {
			anchors.horizontalCenter: parent.horizontalCenter
			width: 300
            text: qsTr("Quit Wazapp")
            onClicked: appWindow.quitInit()
        }

		ToolIcon
        {
            iconSource: "../common/images/about" + (theme.inverted ? "-white" : "") + ".png";
            onClicked: { aboutDialog.open() }
        }*/
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
        icon: "../common/images/icons/wazapp80.png"
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

			/*GroupSeparator {
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
            
			}*/
			/*Button {
				width: parent.width
				text: qsTr("Sync contacts")
				onClicked: { console.log("SYNC"); syncClicked(); }
			}

			GroupSeparator {
				title: qsTr("Status")
			}
			Button {
				width: parent.width
				onClicked: pageStack.push (Qt.resolvedUrl("../ChangeStatus/ChangeStatus.qml"))
				text: qsTr("Change status")
            }*/

			GroupSeparator {
				title: qsTr("Appearance")
			}
			Label {
				verticalAlignment: Text.AlignBottom
				text: qsTr("Orientation:")
				height: 30
			}
			ButtonRow {
                Button {
                    text: qsTr("Automatic")
                    checked: orientation==0
                    onClicked: {
						MySettings.setSetting("Orientation", "0")
                        orientation=0
                    }
                }
                Button {
                    text: qsTr("Portrait")
                    checked: orientation==1
                    onClicked: {
						MySettings.setSetting("Orientation", "1")
                        orientation=1
                    }
                }
                Button {
                    text: qsTr("Landscape")
                    checked: orientation==2
                    onClicked: {
						MySettings.setSetting("Orientation", "2")
                        orientation=2
                    }
                }
            }

			Label {
				verticalAlignment: Text.AlignBottom
				text: qsTr("Theme color:")
				height: 50
			}
			ButtonRow {
                id: br1
                Button {
                    text: qsTr("White")
                    checked: theme.inverted ? false : true
                    //platformStyle: myButtonStyleLeft
                    onClicked: {
						MySettings.setSetting("ThemeColor", "White")
                        theme.inverted = false
                    }
                }
                Button {
                    text: qsTr("Black")
                    checked: theme.inverted ? true : false
                    //platformStyle: myButtonStyleRight
                    onClicked: {
						MySettings.setSetting("ThemeColor", "Black")
                        theme.inverted = true
                    }
                }
            }
			Label {
				verticalAlignment: Text.AlignBottom
				text: qsTr("Bubble color:")
				height: 50
			}
			ButtonRow {
                id: br2
				height: 70
                Button {
                    text: qsTr("Cyan")
                    checked: mainBubbleColor==1
                    onClicked: {
						MySettings.setSetting("BubbleColor", "1")
                        mainBubbleColor=1
                    }
                }
                Button {
                    text: qsTr("Green")
                    checked: mainBubbleColor==4
                    onClicked: {
						MySettings.setSetting("BubbleColor", "4")
                        mainBubbleColor=4
                    }
                }
                Button {
                    text: qsTr("Pink")
                    checked: mainBubbleColor==3
                    onClicked: {
						MySettings.setSetting("BubbleColor", "3")
                        mainBubbleColor=3
                    }
                }
                Button {
                    text: qsTr("Orange")
                    checked: mainBubbleColor==2
                    onClicked: {
						MySettings.setSetting("BubbleColor", "2")
                        mainBubbleColor=2
                    }
                }
            }

			GroupSeparator {
				title: qsTr("Chats")
			}
			SwitchItem {
				title: qsTr("Enter key sends the message")
				check: sendWithEnterKey
				onCheckChanged: {
					MySettings.setSetting("SendWithEnterKey", value)
					sendWithEnterKey = value=="Yes"
				}
			}

			GroupSeparator {
				title: qsTr("Media sending")
			}
			SwitchItem {
				title: qsTr("Resize images before sending")
				check: resizeImages
				onCheckChanged: {
					MySettings.setSetting("ResizeImages", value)
					resizeImages = value=="Yes"
					setResizeImages(resizeImages)
				}
			}

		}

    }

    ScrollDecorator {
        flickableItem: flickArea
    }

}

