import QtQuick 1.1
import com.nokia.meego 1.0

import "conversations.js" as ConvScript
import "Global.js" as Helpers
//import QtMobility.systeminfo 1.1
//import QtMobility.feedback 1.1
//import QtMultimediaKit 1.1

Page {
    id:conversation_view

    onStatusChanged: {
        if(status == PageStatus.Deactivating){
            appWindow.setActiveConv("")
        }
        else if(status == PageStatus.Active){
            appWindow.conversationActive(user_id);
            appWindow.setActiveConv(user_id)
			pageIsActive = true
		}
        
    }

	
	TextFieldStyle {
        id: myTextFieldStyle
        backgroundSelected: ""
        background: ""
		backgroundDisabled: ""
		backgroundError: ""
    }

	property bool loadFinished: false
	property bool pageIsActive: false
	property bool showSendButton
    property string user_id;
    property string user_name;
    property string user_picture;
    property string prev_state:"chats"
    property bool iamtyping:false
    property string pageIdentifier:"conversation_page" //used in notification hiding process


    Component.onCompleted:{
        console.log("opened chat window");
        //requestPresence(user_id);
    }

    signal sendMessage(string user_id,string message);
   // signal conversationUpdated(int msgId, int msgType, string number,string lastMsg,string time,string formattedDate);
    signal conversationUpdated(variant message);
    signal typing(string user_id);
    signal paused(string user_id);


    function notifyReceived(){
        /*console.log('hello notify');
        //set volume

        devinfo.activeProfileDetails()

        var profile = devinfo.activeProfileDetails;

        console.log(profile.messageRingtoneVolume)
        console.log(profile.vibrationActive);

       /* snd_msg_received.volume = profile.messageRingtoneVolume()
        snd_msg_received.play();


        if(profile.vibrationActive())
            vibra_msg_received.start();*/
    }



    function setOnline(){
        ustatus.setOnline();
    }

    function setTyping(){
        ustatus.setTyping();
    }

    function setPaused(){
        ustatus.setPaused();
    }

    function setOffline(seconds){
        if(seconds)
            ustatus.setOffline(seconds);
        else
            ustatus.setOffline();
    }




    function getBubble(msg_id){

        for(var i =0; i < conv_data.count; i++){
            var bubble = conv_data.get(i);
            if(bubble.msg_id == msg_id)
                return bubble;
        }

        return 0;
    }

    function getBubbleIndex(msg_id){
        for(var i =0; i < conv_data.count; i++){
            var bubble = conv_data.get(i);
            if(bubble.msg_id == msg_id)
                return i;
        }

        return -1;
    }

    function messageSent(msg_id){


        var bubbleIndex = getBubbleIndex(msg_id);

        if(bubbleIndex > -1){
           // conv_items.view.model.setData(bubbleIndex,"state_status","pending");
            conv_data.setProperty(bubbleIndex,"status","pending");
        }
    }

    function messageDelivered(msg_id){

        var bubble = getBubble(msg_id);
        if(bubble){
            bubble.status= "delivered";
        }

    }


    function newMessage(message){
        //ConvScript.addMessage(message.id,message.content,message.type,message.formattedDate,message.timestamp,message.status);
        ConvScript.addMessage(message);
    }

    function getNameForBubble(uname)
    {
        var arr = uname.split(' ');
        return arr[0];
    }


	Rectangle{
        	id:top_bar
        	//onClicked: {conversation_view.visible=false;conversation_view.parent.parent.state=prev_state;}
        	width:parent.width
		color: "transparent"
        	height: visible ? 73 : 0
		visible: screen.currentOrientation == Screen.Portrait ? true : ((screen.keyboardOpen || inputContext.softwareInputPanelVisible) ? false : true)	
        	Rectangle {
            		anchors.verticalCenter: parent.verticalCenter
            		width: parent.width 
            		anchors.left: parent.left
			color: "transparent"
			height: 50

			ToolIcon
			{
				id: goBack
				//platformStyle: ButtonStyle { inverted:appWindow.stealth  || theme.inverted }
				//width: 50
				//height: 48
				iconId: "toolbar-back"
				anchors.left: parent.left
				anchors.verticalCenter: parent.verticalCenter
				onClicked: { appWindow.pageStack.pop() }
			}
					
	        	Label {
	            		id: username
	            		text: user_name
				width: parent.width - goBack.width - userimage.width - 8 
	            		horizontalAlignment: Text.AlignRight
				verticalAlignment: Text.AlignTop
				anchors.top: parent.top
				anchors.right: userimage.left
				anchors.rightMargin: 8
	            		font.bold: true
				height: 28
	        }
		UserStatus {
		        id:ustatus
		        height: 22
		        itemwidth: parent.width - goBack.width - userimage.width - 8*3
			anchors.top: username.bottom
			anchors.left: goBack.right
			anchors.leftMargin: 8
			horizontalAlignment: Text.AlignRight
			
		}
            RoundedImage {
                id:userimage
                size:50
                imgsource: user_picture
                anchors.verticalCenter: parent.verticalCenter
		anchors.right: parent.right
		anchors.rightMargin: 8
            }

        }
		Rectangle {
			height: 1
			width: parent.width
			x:0; y: 71
			color: "gray"
			opacity: 0.6
		}
		Rectangle {
			height: 1
			width: parent.width
			x:0; y: 72
			color: theme.inverted ? "lightgray" : "white"
			opacity: 0.8
		}	
    }

    ListModel{
        id: conv_data
    }

    Component{
       id:myDelegate

Column {
width: parent.width
 	Rectangle {
           id: margin_top
           width: parent.width
           height: 8
           color: "transparent"
       }

       SpeechBubble{
           message: Helpers.emojifyBig(Helpers.newlinefy(Helpers.linkify(model.message)));
           date:model.timestamp
           from_me:model.type==1
           //picture: user_picture
           name: getNameForBubble(user_name)
           state_status:model.status
           onOptionsRequested: {
               console.log("options requested")
               copy_facilitator.text = model.message;
               bubbleMenu.open();
           }
       }

Rectangle {
           id: margin_bottom
           width: parent.width
           height: 4
           color: "transparent"
       }
}

    }

	Timer {
		id:typing_timer
		interval: 2000; running: false; repeat: false
		onTriggered: {
		    console.log("STOPPED TYPING");
		    iamtyping = false;
		    paused(user_id);
	    }
	}

    function getListSize () {
		var s = 0;
		for ( var i=0; i<conv_items.count; ++i )
		{
			conv_items.currentIndex = i;
		    s = s + conv_items.currentItem.height
			//console.log("INC SIZE: " + s);
		}
		loadFinished=true
		return s;
	}

	Flickable {
        id: flickArea
        anchors.bottom: input_button_holder.top
    anchors.top: top_bar.bottom
		width: parent.width
        contentWidth: width
        contentHeight: column1.height
		clip: true

		Column {
            id: column1
            anchors.topMargin: 0
            anchors { top: parent.top; left: parent.left; margins: 0;}
            width: parent.width
            spacing: 0

			Rectangle {
				id: spacer_top
				color: "transparent"
				width: parent.width
				visible: top_bar.visible
                height: conv_items.height<(flickArea.height-input_holder.height-10) ?
                        flickArea.height-input_holder.height-conv_items.height-10 : 0

		        Label{
		            anchors.centerIn: parent;
		            text: "Loading conversation..."
                    font.pointSize: 22
					color: "gray"
		            width: parent.width
		            horizontalAlignment: Text.AlignHCenter
					visible: !loadFinished
		        }

			}
			
			ListView{
				id:conv_items

				width:parent.width
				delegate: myDelegate
				model: conv_data
				interactive: false
                height: pageIsActive ? getListSize() : 0
				visible: loadFinished
                //onCountChanged: { flickArea.contentY = conv_items.height }
                onHeightChanged: {
                    var s = 0;
                                                       if (conv_items.height > (flickArea.height-input_holder.height-73-10) )
                                                                 s = conv_items.height - flickArea.height +75
                                                         else
                                                                 s = conv_items.height
                                                          flickArea.contentY = s


                }
				
			}

			Rectangle {
				id: spacer_bottom
				width: parent.width
				height: 10
				color: "transparent"
			}
			
			Rectangle {
				id: input_holder
				anchors.left: parent.left
				width: parent.width
				height: chat_text.height
				color: "white"

                property bool alreadyFocused: false

				Image {
					id: logoW
					x: 16
					y: 22
					height: 42; width: 42; smooth: true
					source: "pics/wazapp48.png"
					anchors.verticalCenter: parent.verticalCenter
				}


				FontLoader { id: wazappFont; source: "/opt/waxmppplugin/bin/wazapp/UI/fonts/WazappPureRegular.ttf" }

				TextArea {
				    id: chat_text
					anchors.left: logoW.right
					 
				    height: 65
					width: parent.width-logoW.width-32
					anchors.verticalCenter: parent.verticalCenter
					placeholderText: "Write your message here"
					platformStyle: myTextFieldStyle
					wrapMode: TextEdit.Wrap
		                        textFormat: Text.PlainText
					font.family: wazappFont.name
					font.pixelSize: 24

				    onTextChanged: {										

				        if(!iamtyping)
				        {
				            console.log("TYPING");
				            typing(user_id);
				        }
				        iamtyping = true;
                        typing_timer.restart();
					}



                    onActiveFocusChanged: {
                        showSendButton = chat_text.focus || input_button_holder_area.focus
                        if (showSendButton) {
                            if (!input_holder.alreadyFocused) {
                               input_holder.alreadyFocused = true
                                //flickArea.contentY = input_button_holder.height+chat_text.height
                            }
                        } else
                            input_holder.alreadyFocused = false


                    }

					onHeightChanged: {
                        flickArea.contentY = flickArea.contentHeight
					}
					
				}
			}
		}
	}


    Rectangle {
        id: input_button_holder
       // anchors.left: parent.left
        width: parent.width
        height: (showSendButton)? 65 : 0
        anchors.bottom:parent.bottom
        color: "white"
        clip: true

        MouseArea {
            id: input_button_holder_area
            anchors.fill: parent
            onClicked: {
                showSendButton=true;
                flickArea.contentY = flickArea.contentY
                chat_text.forceActiveFocus()
            }
        }


        Rectangle {
            height: 1
            width: parent.width
            x:0; y:0
            color: "gray"
            opacity: 0.6
        }

        Button
        {
            id: emoji_button

            platformStyle:  ButtonStyle{
               inverted: false
            }
            width: height
            height: send_button.height
            iconSource: "pics/emoji/emoji-E415.png"
            anchors.left: parent.left
        anchors.leftMargin: 16
            anchors.verticalCenter: send_button.verticalCenter
            onClicked:{
        var component = Qt.createComponent("Emojidialog.qml");
            var sprite = component.createObject(conversation_view, {origin: "chat"});

            }
        }


        Button
        {
            id:send_button
            platformStyle: ButtonStyle { inverted: true }
            iconSource:"image://theme/icon-m-toolbar-send-chat-white"
            width:160
            height:45
            text: "Send"
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            //enabled: chat_text.text.trim() != ""
            onClicked:{
                chat_text.text = chat_text.text+"\n"; //cheap hack to stabilize flickArea when regaining focus
                chat_text.focus = true;
                 var toSend = chat_text.text.trim();
                 if ( toSend != "")
                 {
                    sendMessage(user_id,toSend);
                    chat_text.text = "";
                 }
                 //chat_text.focus = true;
                 //flickArea.contentY = input_button_holder.y+input_button_holder.height
            }
        }
    }

    TextField{
        id:copy_facilitator
        visible:false
    }

    Menu {
        id: bubbleMenu

            MenuLayout {

            MenuItem{
                text:qsTr("Copy")
                onClicked:{
                    copy_facilitator.selectAll()
                    copy_facilitator.copy();}
            }
        }
    }
}
