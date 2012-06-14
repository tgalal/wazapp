import QtQuick 1.1
import com.nokia.meego 1.0



import "conversations.js" as ConvScript
import "Global.js" as Helpers
//import QtMobility.systeminfo 1.1
//import QtMobility.feedback 1.1
//import QtMultimediaKit 1.1

Page {
    id:conversation_view

	orientationLock: myOrientation==2 ? PageOrientation.LockLandscape:
			myOrientation==1 ? PageOrientation.LockPortrait : PageOrientation.Automatic

	property bool loaded: false

	property int convLoaded: 0
	property bool loadConvsReverse: false

    onStatusChanged: {
        if(status == PageStatus.Deactivating){
            appWindow.setActiveConv("")
        }
        else if(status == PageStatus.Active){
			if (!loaded) {
				loaded = true
				loadConvsReverse = true
				convLoaded = 0
				appWindow.loadConversationsThread(user_id, 1, 14);
				loadConvsReverse = false
				if (conv_data.count>15) 
					conv_items.header = readMoreDelegate
				else
					conv_items.header = readMoreDelegateEmpty
				conv_items.positionViewAtEnd()
			}
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
    property bool isGroup:user_id.split('-').length > 1
    property string user_name;
    property string user_picture;
    property string prev_state:"chats"
    property bool typingEnabled:false
    property bool iamtyping:false
    property string pageIdentifier:"conversation_page" //used in notification hiding process


    Component.onCompleted:{
        console.log("opened chat window");

    	conv_data.insert(0,{"msg_id":"", "message":"", "type":0,
                            "timestamp":"", "status":"","author":"",
                            "mediatype_id":10, "media":"", "progress":0})


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

    function mediaTransferProgressUpdated(progress,message_id){
        var bubble = getBubble(message_id);
        if(bubble){
            console.log("FOUND BUBBLE TO PUSH PROGRESS")
            bubble.progress = progress
            console.log("PUSHED!")
        }
    }

    function mediaTransferSuccess(message_id,mediaObject){
        console.log("transfer success in convo")
        var bubble = getBubble(message_id);
        if(bubble){
            console.log("FOUND BUBBLE TO PUSH PROGRESS")
            bubble.media = mediaObject
            bubble.progress =0
            console.log("Media Bubble Updated")
        }
    }

    function mediaTransferError(message_id,mediaObject){
        var bubble = getBubble(message_id);
        if(bubble){
            console.log("FOUND BUBBLE TO PUSH PROGRESS")
            bubble.media = mediaObject
            bubble.progress = 1;
            bubble.progress--;//to trigger fail->fail state change
            console.log(mediaObject.transfer_status)
            console.log("Media bubble updated to error")
        }
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
		color: theme.inverted? "#161616" : "transparent"
        height: appWindow.inPortrait ? 73 : (showSendButton ? 0 : 73)
		clip: true
		
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 32
            anchors.left: parent.left
            anchors.leftMargin: 16
			color: "transparent"
			height: 50

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
                    text: qsTr("Back")
				}
				MouseArea {
					id: bcArea
					anchors.fill: parent
					onClicked: { 
                        //chatsTabButton.clicked()
						appWindow.pageStack.pop(1)
					}
				}

			}


	        Label {
	            id: username
                text: user_name.indexOf("-")>0 ? 
						qsTr("Group (%1)").arg(getAuthor(user_name.split('-')[0]+"@s.whatsapp.net")) : user_name
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
                imgsource: user_name.indexOf("-")>0 ? "pics/group.png" : user_picture
                anchors.verticalCenter: parent.verticalCenter
				anchors.right: parent.right
            }

        }

		Rectangle {
			height: 1
			width: parent.width
			x:0; y: 71
			color: "gray"
			opacity: theme.inverted ? 0.8 : 0.6
		}
		Rectangle {
			height: 1
			width: parent.width
			x:0; y: 72
			color: theme.inverted ? "darkgray" : "white"
			opacity: theme.inverted ? 0.0 : 0.8
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

        BubbleDelegate{
            mediatype_id: model.mediatype_id
            message: model.message
            media:model.media
            date: model.timestamp
			from_me:model.type==1
            progress:model.progress
			//picture: user_picture
            name: mediatype_id==10 || from_me || user_name.indexOf("-")==-1 ? "" : getAuthor(model.author.jid)
            author:model.author
			state_status:model.status
            isGroup: conversation_view.isGroup
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

	Component {
		id: readMoreDelegate
		Rectangle {
			width: appWindow.inPortrait ? 480 : 854
			height: 65
			color: "transparent"
			Button {
				height: 45
				width: parent.width - 120
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.verticalCenter: parent.verticalCenter
				text: qsTr("Read more messages")
                font.pixelSize: 20
				onClicked: {
					loadConvsReverse = true
					convLoaded = 0
					var cInt = conv_data.count+14
					appWindow.loadConversationsThread(user_id, conv_data.count-1, 15);
					loadConvsReverse = false
					if ( cInt > conv_data.count )
						conv_items.header = readMoreDelegateEmpty
					else
						conv_items.header = readMoreDelegate
				}
			}
		}
	}

	Component {
		id: readMoreDelegateEmpty
		Rectangle {
			color: "transparent"
			height: 0
			width: appWindow.inPortrait ? 480 : 854
		}
	}


	Rectangle {
		color: theme.inverted? "transparent" : "#dedfde"
		anchors.top: parent.top
		anchors.topMargin: top_bar.height
		width: parent.width
		height: parent.height - top_bar.height - input_button_holder.height
		clip: true

		Label{
			anchors.centerIn: parent;
			text: qsTr("Loading conversation...")
			font.pointSize: 22
			color: "gray"
			width: parent.width
			horizontalAlignment: Text.AlignHCenter
			visible: !loaded
		}

		Rectangle {
			id: topMargin
			color: "transparent"
			width: parent.width
			height: Math.max(0, parent.height-(conv_items.count>3?input_button_holder.height:0)-conv_items.contentHeight)
			visible: loaded
		}

		ListView{
			id:conv_items
			spacing: 6
			delegate: myDelegate
			model: conv_data
			anchors.top: parent.top
			anchors.topMargin: topMargin.height
			height: parent.height - topMargin.height
			anchors.left: parent.left
			width: parent.width
			cacheBuffer: 10000
			visible: loaded
			onCountChanged: {
				if (conv_data.count>1) convLoaded = convLoaded+1
			}
		}
	}

	Rectangle {
		id: input_button_holder
		anchors.bottom: parent.bottom
		anchors.left: parent.left
		width: parent.width
		height: (showSendButton)? 76 : 0
		color: theme.inverted? "#1A1A1A" : "white"
		clip: true
		
	    MouseArea {
			id: input_button_holder_area
			anchors.fill: parent
			onClicked: { 
				showSendButton=true; 
				goToEndOfList()
				setFocusToChatText()
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
		    id: emoji_button
		    //platformStyle: ButtonStyle { inverted: true }
		    width:50
		    height:50
			iconSource: "pics/emoji-32/emoji-E415.png"
		    anchors.left: parent.left
			anchors.leftMargin: 16
		    anchors.verticalCenter: send_button.verticalCenter
		    onClicked: {
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
			text: qsTr("Send")
		    anchors.right: parent.right
			anchors.rightMargin: 16
			y: 10
			//enabled: cleanText(chat_text.text).trim()!=""
		    onClicked:{
				showSendButton=true; 
				sendCurrentMessage()
				setFocusToChatText()
		    }
		}
	}

	Connections {
		target: appWindow
		onGoToEndOfList: {
			//console.log("GETTING END OF LIST")
			conv_items.positionViewAtIndex(conv_items.count-1, ListView.Contain)
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
