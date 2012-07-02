import QtQuick 1.1
import com.nokia.meego 1.0
import "../common/js/Global.js" as Helpers

Dialog {
	id: emojiSelector
	
	width: parent.width
	height: parent.height


    property string titleText: qsTr("Select Emoji")
    property string emojiPath:"../common/images/emoji/";

    signal emojiSelected(string emojiCode);

    function get32(code){
        var c = ""+code;
        if(c.length == 2)
            c="0"+code;

        return emojiPath+"32/emoji-E"+c+".png";
    }

    function get20(code){
        var c = ""+code;
        if(c.length == 2)
            c="0"+code;

         return emojiPath+"20/emoji-E"+c+".png";
    }

    function openDialog(){

        emojiSelector.open();
        emojiSelector.loadEmoji(0,109);

    }

	SelectionDialogStyle { id: selectionDialogStyle }

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
                iconSource: get32(415);
			 	onClicked: emojiSelector.loadEmoji(0,109);
		    }

		    Button {
		        id: natureEmoji
                iconSource: get32(303);
			 	onClicked: emojiSelector.loadEmoji(109,162)
		    }

		    Button {
		        id: eventsEmoji
                iconSource: get32(325)
			 	onClicked: emojiSelector.loadEmoji(162,297)
		    }
		
			Button {
		        id: placesEmoji
                iconSource: get32(36)
			 	onClicked: emojiSelector.loadEmoji(297,367)
		    }

		    Button {
		        id: symbolsEmoji
                iconSource: get32(210)
			 	onClicked: emojiSelector.loadEmoji(367,466)
		    }
		}

        Rectangle {
            width: emojiSelector.width-40
            height: emojiSelector.height-200
            radius: 20
            x: 20
            y: 70
            color: "#1a1a1a"

			GridView {
				id: emojiGrid
				width: emojiCategory.width - (appWindow.inPortrait ? 20 : 10)
		        height: appWindow.inPortrait ? parent.height-25 : parent.height-50
		        x: appWindow.inPortrait ? 26 : 14
		        y: appWindow.inPortrait ? emojiCategory.height-40 : emojiCategory.height-20
				cacheBuffer: 2000
				cellWidth: 80
				cellHeight: 60
				clip: true
				model: emojiModel

				delegate: Component {

					 Rectangle {
						id: emojiDelegate
						radius: 20
						property string codeS: emojiCode 
						width: 70
						height: 50
						//color: "#202020"
						gradient: Gradient {
							GradientStop { position: 0.0; color: "#505050" }
							GradientStop { position: 1.0; color: "#101010" }
						}
						Rectangle {
							x:1; y:1; width:68; height:48; radius: 20
							gradient: Gradient {
								GradientStop { position: 0.0; color: "#3c3c3b" }
								GradientStop { position: 1.0; color: "#1c1c1c" }
							}
						}
						Image {
							source: emojiPath
							anchors.horizontalCenter: parent.horizontalCenter
							anchors.verticalCenter: parent.verticalCenter
							width: 32
							height: 32
						}
						MouseArea {
							anchors.fill: parent

							onClicked: {
								var codeX = emojiDelegate.codeS;
                                //addedEmojiCode = '<img src="/opt/waxmppplugin/bin/wazapp/UI/common/images/emoji/20/emoji-E'+codeX+'.png" />'

                                console.log("SELECTED INSIDE DIALOG "+codeX);

                                selectEmoji(codeX)
							}
						}
					} 
				}
			}

			ScrollDecorator {
				flickableItem: emojiGrid
			}

			ListModel {
				id: emojiModel
			}
		}
	}



	Component.onCompleted: {
       // emojiSelector.open();
        //emojiSelector.close();
        //emojiSelector.loadEmoji(0,109)
	}




    function selectEmoji(emojiCode){

        emojiSelected(emojiCode);
        emojiSelector.accept();
    }

	function loadEmoji(s,e) {
		var start = s; var end = e;
		emojiGrid.model.clear();
		for(var n = start; n < end; n++)
		{
            emojiGrid.model.append({"emojiPath": get32(Helpers.emoji_code[n]), "emojiCode": Helpers.emoji_code[n]});
		}
		
	}

}
