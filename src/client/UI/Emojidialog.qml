import QtQuick 1.1
import com.nokia.meego 1.0
import "Global.js" as Helpers

Dialog {
	id: emojiSelector
	
	width: parent.width
	height: parent.height

	property string titleText: "Select emoticon"

	SelectionDialogStyle {id: selectionDialogStyle}

	    title: Item {

        id: header
	

        height: selectionDialogStyle.titleBarHeight

        anchors.left: parent.left

        anchors.right: parent.right

        anchors.top: parent.top

        anchors.bottom: parent.bottom

        Item {

            id: labelField

            anchors.fill:  parent

            Item {

                id: labelWrapper

                anchors.left: labelField.left

                anchors.right: closeButton.left

                anchors.bottom:  parent.bottom

                anchors.bottomMargin: selectionDialogStyle.titleBarLineMargin

                //anchors.verticalCenter: labelField.verticalCenter

                height: titleLabel.height

                Label {

                    id: titleLabel

                    x: selectionDialogStyle.titleBarIndent

                    width: parent.width - closeButton.width

                    //anchors.baseline:  parent.bottom

                    font: selectionDialogStyle.titleBarFont

                    color: selectionDialogStyle.commonLabelColor

                    elide: selectionDialogStyle.titleElideMode

                    text: emojiSelector.titleText


                }

            }

            Image {

                id: closeButton

                anchors.bottom:  parent.bottom

                anchors.bottomMargin: selectionDialogStyle.titleBarLineMargin-6

                //anchors.verticalCenter: labelField.verticalCenter

                anchors.right: labelField.right

                opacity: closeButtonArea.pressed ? 0.5 : 1.0

                source: "image://theme/icon-m-common-dialog-close"

                MouseArea {

                    id: closeButtonArea

                    anchors.fill: parent

                    onClicked:  {emojiSelector.reject();}

                }

            }

        }

        Rectangle {

            id: headerLine

            anchors.left: parent.left

            anchors.right: parent.right

            anchors.bottom:  header.bottom

            height: 1

            color: "#4D4D4D"

        }
	

    }

	content: Item {
			width: emojiSelector.width < emojiSelector.height ? 360 : 480
			height: emojiSelector.height-200

	ButtonRow {
		id: emojiCategory
        checkedButton: peopleEmoji
		width: emojiSelector.width-30
		x: 15
		y: 10
        Button {
        	id: peopleEmoji
            iconSource: "pics/emoji-32/emoji-E415.png"
	     	onClicked: emojiSelector.loadEmoji(0,109);
        }

        Button {
            id: natureEmoji
            iconSource: "pics/emoji-32/emoji-E303.png"
	     	onClicked: emojiSelector.loadEmoji(109,162)
        }

        Button {
            id: eventsEmoji
            iconSource: "pics/emoji-32/emoji-E325.png"
	     	onClicked: emojiSelector.loadEmoji(162,297)
        }
		
		Button {
            id: placesEmoji
            iconSource: "pics/emoji-32/emoji-E036.png"
	     	onClicked: emojiSelector.loadEmoji(297,367)
        }

        Button {
            id: symbolsEmoji
            iconSource: "pics/emoji-32/emoji-E210.png"
	     	onClicked: emojiSelector.loadEmoji(367,466)
        }
     }

	GridView {
		id: emojiGrid
		width: emojiCategory.width
		height: parent.height
		x: appWindow.inPortrait ? 46 : 34
		y: 10+emojiCategory.height+10
		cacheBuffer: 2000
		cellWidth: 80
		cellHeight: 60
		clip: true
		model: emojiModel
		delegate: Component {
			 Button {
				id: emojiDelegate
				property string codeS: emojiCode 
				platformStyle: ButtonStyle { inverted: true }
				//iconSource: emojiPath; 
				width: 70
				height: 50
				Image {
					source: emojiPath
					anchors.horizontalCenter: parent.horizontalCenter
					anchors.verticalCenter: parent.verticalCenter
					width: 32
					height: 32
				}

				onClicked: {
					var codeX = emojiDelegate.codeS;
					//chat_text.text += Helpers.convertUnicodeCodePointsToString(['0xE'+codeX])  
					//chat_text.text = Helpers.emojify2(chat_text.text)
					chat_text.text += '<img src="/opt/waxmppplugin/bin/wazapp/UI/pics/emoji-20/emoji-E'+codeX+'.png" />'
					chat_text.cursorPosition = chat_text.positionAt(chat_text.paintedWidth,chat_text.paintedWidth,TextInput.CursorOnCharacter);
					emojiSelector.reject()

				}
			} 
		}
	}

	ListModel {
		id: emojiModel
	}
}

	onRejected: {
		showSendButton=true
		chat_text.forceActiveFocus()
		chat_text.positionAt = chat_text.text.lenght
		flickArea.contentY = flickArea.contentY
	}

	Component.onCompleted: {

		emojiSelector.open();
		emojiSelector.loadEmoji(0,109)
	}


	function loadEmoji(s,e) {
		var start = s; var end = e;
		emojiGrid.model.clear();
		for(var n = start; n < end; n++)
		{
            emojiGrid.model.append({"emojiPath": "pics/emoji-32/emoji-E"+Helpers.emoji_code[n]+".png", "emojiCode": Helpers.emoji_code[n]});
		}
		
	}

}
