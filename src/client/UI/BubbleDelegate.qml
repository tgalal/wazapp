// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import "Global.js" as Helpers
import com.nokia.meego 1.0

Item {

    id:delegateContainer
    width:bubbleDisplay.width
    height:bubbleDisplay.height;

    property int mediatype_id:1
    property string message;
    property string picture;
    property bool from_me;
    property bool isGroup;
    property string date;
    property string name;
    property int msg_id;
    property string state_status;
    property int inboundBubbleColor: 1
    property int outboundBubbleColor: 1
    property string thumb
    property variant media
    property variant author
    property int progress: 0

    signal optionsRequested()


    anchors.right: from_me?this.right:parent.right
    anchors.left: !from_me?this.left:parent.left
    anchors.rightMargin: 0
    anchors.leftMargin: 0



    function getBubble(){

        switch(mediatype_id){
		    case 1: return textDelegate
		    case 2: case 3: case 4: case 5: case 6: return mediaDelegate
			case 10: return textAreaDelegate
        }
    }

    Component {
       id: textDelegate

       TextBubble{
           id:textBubble
           message:Helpers.emojifyBig(Helpers.linkify(delegateContainer.message));
           date:Helpers.getDateText(delegateContainer.date).replace("Today", qsTr("Today")).replace("Yesterday", qsTr("Yesterday"))
           from_me:delegateContainer.from_me
           name:delegateContainer.name
           state_status:delegateContainer.state_status

           onOptionsRequested: {
               delegateContainer.optionsRequested()
           }


       }
     }

    Component {
       id: mediaDelegate

       MediaBubble{

           id:mediaBubble
         //  mediatype_id: delegateContainer.mediatype_id
           /* state: delegateContainer.media.transfer_status==2?"success"
                                                       :(delegateContainer.from_me?""
                                                                                  :"download")


           state:delegateContainer.media.transfer_status == 2?"success":
                    (delegateContainer.media.transfer_status == 1?"failed":
                        (delegateContainer.from_me?"":"download")) */



           transferState:delegateContainer.media.transfer_status == 2?"success":
                             (delegateContainer.media.transfer_status == 1?"failed":"init")


           date:Helpers.getDateText(delegateContainer.date).replace("Today", qsTr("Today")).replace("Yesterday", qsTr("Yesterday"))
           from_me:delegateContainer.from_me
           progress:delegateContainer.progress
           name: delegateContainer.name
           state_status:delegateContainer.state_status
           media: delegateContainer.media//.preview?delegateContainer.media.preview:""

           onOptionsRequested: {
               delegateContainer.optionsRequested()
           }
           onDownloadClicked: {

               if(delegateContainer.isGroup){

                   appWindow.fetchGroupMedia(delegateContainer.media.id);
               }else{

                   appWindow.fetchMedia(delegateContainer.media.id);
               }
           }

       }
     }


	Component {
		id: textAreaDelegate

		Rectangle {
			id: spacer
			color: "transparent"
			height: input_holder.height + 10
			width: appWindow.inPortrait? 480 : 854

			Component.onCompleted: { delegateContainer.height= spacer.height }


			Connections {
				target: appWindow
				onSendCurrentMessage: {
					if (activeConvJId==conversation_view.user_id) {
						chat_text.forceActiveFocus()
						var toSend = cleanText(chat_text.text);
						toSend = toSend.trim();
						if ( toSend != "")
						{
						    sendMessage(user_id,toSend);
							chat_text.text = "";
						}
					}
				}
				onSetFocusToChatText: {
					if (activeConvJId==conversation_view.user_id) {
						chat_text.forceActiveFocus()
					}
				}
				onAddEmojiToChat: {
					if (activeConvJId==conversation_view.user_id) {
						chat_text.text += addedEmojiCode
						chat_text.forceActiveFocus()
					}
		    	}
			}

			function cleanText(txt) {
				var repl = "p, li { white-space: pre-wrap; }";
				var res = txt;
				res = Helpers.getCode(res);
				res = res.replace(/<[^>]*>?/g, "").replace(repl,"");
				return res;
			}	

	
			Rectangle {
				id: input_holder
				anchors.top: parent.top
				anchors.topMargin: 10
				anchors.left: parent.left
				width: parent.width
				height: Math.max(chat_text.height, 65)
				color: theme.inverted? "#1A1A1A" : "white"

				Image {
					x: 16; y: 12; 
					height: 36; width: 36; smooth: true
					source: "pics/wazapp48.png"
				}

				MouseArea {
					id: input_holder_area
					anchors.fill: parent
					onClicked: { 
						showSendButton=true; 
						chat_text.forceActiveFocus()
						goToEndOfList()
					}
				}

				TextFieldStyle {
					id: myTextFieldStyle
					backgroundSelected: ""
					background: ""
					backgroundDisabled: ""
					backgroundError: ""
				}

				MyTextArea {
					id: chat_text
					width:parent.width -60
					x: 54
					y: 0
					placeholderText: (showSendButton|| cleanText(chat_text.text).trim()!="") ? "" : qsTr("Write your message here")
					platformStyle: myTextFieldStyle
					wrapMode: TextEdit.Wrap
					textFormat: Text.RichText

					property bool alreadyFocused: false
			
					onTextChanged: {
						if(!iamtyping)
						{
						    console.log("TYPING");
						    typing(user_id);
						}
						iamtyping = true;
						typing_timer.restart();
					}

					platformSipAttributes: SipAttributes { 
						actionKeyEnabled: true
						actionKeyIcon: "image://theme/icon-m-toolbar-send-chat-white"
						actionKeyLabel: qsTr("Send")
					}
				    onEnterKeyClicked: { console.log("ENTER PRESSED!"); sendCurrentMessage(); setFocusToChatText() }

					onActiveFocusChanged: {
				        showSendButton = chat_text.focus || input_button_holder_area.focus || emoji_button.focus
						if (showSendButton) {
							if (!alreadyFocused) {
								alreadyFocused = true
								goToEndOfList()
							} 
						} else
							alreadyFocused = false
						
				    }

					onHeightChanged: {
						var ant = delegateContainer.height
						delegateContainer.height= Math.max(chat_text.height, 65) +10
						if (pageIsActive && ant<delegateContainer.height) goToEndOfList()
					}
			
				}
			}

		}

	}

    Loader {
      id: bubbleDisplay
      sourceComponent: getBubble()
     // width:bubbleDisplay.children[0].width
      //height:bubbleDisplay.children[0].height


    }
}
