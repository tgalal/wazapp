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
        height: appWindow.inPortrait ? 73 : (showSendButton ? 0 : 73)
		clip: true
		
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 32
            anchors.left: parent.left
            anchors.leftMargin: 16
			color: "transparent"
			height: 50

			/*ToolButton
			{
				width: 50
				height: 48
				iconSource: theme.inverted? "image://theme/icon-m-toolbar-previous-white" : "image://theme/icon-m-toolbar-previous"
				anchors.left: parent.left
				anchors.verticalCenter: parent.verticalCenter
				onClicked: { appWindow.pageStack.pop() }
			}*/

			BorderImage {
				width: 86
				height: 42
				anchors.verticalCenter: parent.verticalCenter
				source: "image://theme/meegotouch-sheet-button-"+(theme.inverted?"inverted-":"")+
						"background" + (bcArea.pressed? "-pressed" : "")
				border { left: 22; right: 22; bottom: 22; top: 22; }
				Label { 
					anchors.verticalCenter: parent.verticalCenter
					anchors.horizontalCenter: parent.horizontalCenter
					font.pixelSize: 22; font.bold: true
					text: "Chats"
				}
				MouseArea {
					id: bcArea
					anchors.fill: parent
					onClicked: appWindow.pageStack.pop()
				}

			}

					
	        Label {
	            id: username
	            text: user_name.indexOf("-")>0 ? "Group (" + 
						getAuthor( user_name.split('-')[0] + "@s.whatsapp.net" ) + ")" : user_name
				width: parent.width - 62
	            horizontalAlignment: Text.AlignRight
				verticalAlignment: Text.AlignTop
				anchors.top: parent.top
	            font.bold: true
				height: 28
	        }
			UserStatus {
		        id:ustatus
		        height:30
		        itemwidth: parent.width -62
				anchors.top: username.bottom
		    }
            RoundedImage {
                id:userimage
                size:50
                imgsource: username.text.indexOf("Group (")==0 ? "pics/group.png" : user_picture
                anchors.verticalCenter: parent.verticalCenter
				anchors.right: parent.right
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

	function getAuthor(inputText) {
		var resp;
		resp = inputText.split('@')[0];
		for(var i =0; i<contactsModel.count; i++)
		{
            var item = contactsModel.get(i).jid;
		    if(item == inputText)
		        resp = contactsModel.get(i).name;
		}
		return resp;
	}

    Component{
        id:myDelegate

		SpeechBubble{
			message: Helpers.emojify(Helpers.linkify(model.message));
			date:model.timestamp
			from_me:model.type==1
			//picture: user_picture
			name: conversation_view.getAuthor(model.author)
			state_status:model.status
			onOptionsRequested: {
				console.log("options requested")
				copy_facilitator.text = model.message;
				bubbleMenu.open();
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
		return s + (conv_items.count*6) + 6;
	}

	function cleanText(txt) {
		var repl = "p, li { white-space: pre-wrap; }";
		var res = txt;
		res = Helpers.getCode(res);
		res = res.replace(/<[^>]*>?/g, "").replace(repl,"");
		return res;
	}	

	
	Flickable {
        id: flickArea
        anchors.top: parent.top
		anchors.topMargin: top_bar.height
		height: parent.height - top_bar.height - input_button_holder.height
		width: parent.width
        contentWidth: width
        contentHeight: column1.height
		clip: true

		Column {
            id: column1
            anchors.topMargin: 0
            anchors { top: parent.top; left: parent.left; margins: 0 }
            width: parent.width
            spacing: 0

			Rectangle {
				id: spacer_top
				color: "transparent"
				width: parent.width
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
				spacing: 6
				width:parent.width
				delegate: myDelegate
				model: conv_data
				interactive: false
				height: pageIsActive ? getListSize() : 0
				visible: loadFinished
				//onCountChanged: { flickArea.contentY = conv_items.height }
				onHeightChanged: { 
					var s = 0;
					if (conv_items.height > (flickArea.height-input_holder.height) )
						s = conv_items.height - flickArea.height + input_holder.height +10
					else
						s = conv_items.height + input_holder.height
					//if (showSendButton)
					//	s = s + input_holder.height
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
				height: Math.max(chat_text.height, 65)
				color: theme.inverted? "#1A1A1A" : "white"

				property bool alreadyFocused: false

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
						flickArea.contentY = flickArea.contentY
						chat_text.forceActiveFocus()
					}
				}


				MyTextArea {
				    id: chat_text
				    width:parent.width -60
					x: 54
				    //height: 65
					anchors.verticalCenter: parent.verticalCenter
					placeholderText: (showSendButton|| cleanText(chat_text.text).trim()!="") ? "" : "Write your message here"
					platformStyle: myTextFieldStyle
					wrapMode: TextEdit.Wrap
					textFormat: Text.RichText
					

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
                        showSendButton = chat_text.focus || input_button_holder_area.focus || emoji_button.focus
						if (showSendButton) {
							if (!alreadyFocused) {
								alreadyFocused = true
								flickArea.contentY = flickArea.contentY + input_holder.height +10
							} 
						} else
							alreadyFocused = false

                    }

					onHeightChanged: {
						flickArea.contentY = flickArea.contentY + chat_text.height
					}
					
				}
			}

		}
	}

	Rectangle {
		id: input_button_holder
		anchors.bottom: parent.bottom
		anchors.left: parent.left
		width: parent.width
		height: (showSendButton)? 76 : 0
		color: input_holder.color
		clip: true
		
	    MouseArea {
			id: input_button_holder_area
			anchors.fill: parent
			onClicked: { 
				showSendButton=true; 
				flickArea.contentY = flickArea.contentY + input_button_holder.height
				chat_text.forceActiveFocus()
			}
		}

		
		Rectangle {
			height: 1
			width: parent.width
			x:0; y:0
			color: "gray"
			opacity: 0.4
		}

		Button
		{
		    id:emoji_button
		    //platformStyle: ButtonStyle { inverted: true }
		    width:50
		    height:50
			iconSource: "pics/emoji-32/emoji-E415.png"
		    anchors.left: parent.left
			anchors.leftMargin: 16
		    anchors.verticalCenter: send_button.verticalCenter
		    onClicked:{
				emojiDialogParent = "conversation"
				var component = Qt.createComponent("Emojidialog.qml");
		 		var sprite = component.createObject(conversation_view, {});
		    }
		}

		
		Button
		{
		    id:send_button
		    platformStyle: ButtonStyle { inverted: true }
		    width:160
		    height:50
			text: "Send"
		    anchors.right: parent.right
			anchors.rightMargin: 16
			y: 10
			//enabled: cleanText(chat_text.text).trim()!=""
		    onClicked:{
				showSendButton=true; 
		        chat_text.forceActiveFocus()
				flickArea.contentY = flickArea.contentY + input_button_holder.height
		        var toSend = cleanText(chat_text.text);
				toSend = toSend.trim();
		        if ( toSend != "")
		        {
		            sendMessage(user_id,toSend);
		        	chat_text.text = "";
		        }
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
