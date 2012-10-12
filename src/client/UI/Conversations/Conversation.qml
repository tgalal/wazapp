import QtQuick 1.1
import com.nokia.meego 1.0

import "js/conversations.js" as ConvScript
import "../common/js/Global.js" as Helpers
import "js/conversation.js" as ConversationHelper
import "../common"
import "../Menu"
import "../EmojiDialog"
import "../Groups"
import "../Contacts"

WAPage {
    id:conversation_view


    onStatusChanged: {
        if(status == PageStatus.Deactivating){
            chat_text.visible = false
			sendMediaWindow.opacity = 0
        }
        else if(status == PageStatus.Activating){
            chat_text.visible = true
			if(!ustatus.lastSeenOn) //display last fetched one until new one is there, instead of blank
				ustatus.state = "default"
        }
        else if(status == PageStatus.Active){
            appWindow.conversationActive(jid);
            appWindow.setActiveConv(jid)
			currentJid = jid
			pageIsActive = true
			if(unreadCount){
				unreadCount =0;
				onChange();
			}
			if (!opened) {
				loadMoreMessages(19)
				opened = true
				conv_items.positionViewAtEnd()
			}
		}
		else if(status == PageStatus.Inactive){
			while (conv_data.count>19) conv_data.remove(0)
			conv_items.positionViewAtEnd()
			loadMoreMessages(1)
			//opened = false
		}   
    }

    function openProfile(){
        if(conversationProfile.progress == 0)
            bindProfile();

        pageStack.push(conversationProfile.item)
    }

    /****conversation info properties****/
    property int conversation_id;
    property string jid;
    property string title:getTitle();
    property string picture:getPicture();
    property variant contacts;
    property variant lastMessage;
    property string subject;
	property string owner;
    property string groupIcon;
    property string defaultGroupIcon:"../"+defaultGroupPicture
    property int unreadCount;
    property int remainingMessagesCount;
    property bool hasMore:remainingMessagesCount?true:false
	property bool opened: false
    /*******************************/

    property int inboundBubbleColor: mainBubbleColor //settingsPage.bubbleColor;
    property int outboundBubbleColor: 1

    property string groupSubjectNotReady:qsTr("Fetching group subject")+"...";
    property variant selectedMessage;
    property int selectedMessageIndex;
    property bool typingEnabled:false
    property bool iamtyping:false
    property string pageIdentifier:"conversation_page" //used in notification hiding process
    property bool pageIsActive: false
    property bool showSendButton;
	property bool showContactDetails
	property int currentTextHeight
	property bool loadReverse: false
	property int positionToAdd: conv_data.count
	
	signal textHeightChanged;
    signal sendButtonClicked;
	signal forceFocusToChatText;
    signal emojiSelected(string emojiCode);


    function pushParticipants(jids){
        console.log("REAL PUSH")
        conversationProfile.item.pushParticipants(jids)
    }

    function pushGroupInfo(gdata){
        console.log("GROUP INFO IN CONVERSATION TOOK OVER")
        if (gdata=="ERROR") {
        } else {
            var data = gdata.split("<<->>")
            subject = data[2]
            owner = data[1]
            title = getTitle()
        }
        getPicture(jid, "image")

        conversationProfile.item.pushGroupInfo(gdata);
    }


	Connections {
		target: appWindow

        /*onGroupInfoUpdated: {
			if (jid==gjid) {
				var data = gdata.split("<<->>")
				subject = data[2]
				owner = data[1]
				title = getTitle()
			}
        }*/
		onSelectedMedia: {
			if (activeConvJId == jid)
				sendMediaMessage(jid, url)
		}

		onUpdateContactName: {
			if (jid == ujid) {
				if (title = jid.split('@')[0]) {
					consoleDebug("Update push name in Conversation")
					conversationTitle.text = npush
				}
			}
		}

		onOnTyping: {
			if (jid == ujid) setTyping()
		}

		onOnPaused: {
			if (jid == ujid) setPaused()
		}

		onOpenPreviewPicture: {
			if (jid == ujid) {
				capturePreview.imgsource = "file://" + picturefile
				capturePreview.oriented = rotation
				capturePreview.capturetype = capturemode
				pageStack.push(capturePreview)
			}
		}

	}

	CapturePreview {
		id: capturePreview
	}

	function setPositionToAdd(value) {
		positionToAdd = value
	}

    function loadMoreMessages(value){
		loadReverse = true
        var firstMessage = conv_data.get(0);

        if(!firstMessage)
            return;

		positionToAdd = 0;

        consoleDebug("SHOULD LOAD MORE");
        appWindow.loadMessages(jid,firstMessage.msg_id,value);

		consoleDebug("END ADDING MESSAGES")
		positionToAdd = conv_data.count
		loadReverse = false
		appWindow.checkUnreadMessages()
    }

    function getContacts(){return ConversationHelper.contacts;}

    function getTitle(){
        var title="";

        if(isGroup())
            title = subject==""? groupSubjectNotReady : Helpers.emojify(subject)
        else if(contacts && contacts.length)
            title= getAuthor(jid);

        return title;
    }

    function getPicture(){
        var pic="";

        if(isGroup())
            pic = WAConstants.CACHE_CONTACTS + "/" + jid.split('@')[0] + ".png"
        else if(contacts && contacts.length)
            pic = getAuthorPicture(jid) //contacts[0].contactPicture;

        return pic;
    }

    function addObserver(o){

        for(var i=0;i<ConversationHelper.observers.length;i++){

            if(ConversationHelper.observers[i]==o){
                //consoleDebug("DUPLICATE OBSERVER!!!");
                return;
            }

        }

        ConversationHelper.observers.push(o);
        //consoleDebug("Added observer");
    }

    function onChange(){
        for(var i=0; i<ConversationHelper.observers.length; i++){
            //consoleDebug("REBIND")
            var o = ConversationHelper.observers[i];
            if(o && o.rebind)
                o.rebind();
        }
    }

    function rebind(){
        title:getTitle();
        picture:getPicture();
    }

    function bindProfile(){
       if(conversationProfile.progress == 0){
           if(isGroup()) {
               consoleDebug("PROFILE BINDED!")
                conversationProfile.sourceComponent=groupProfile
           }
       }
    }


    function isGroup(){
        return jid.split('-').length > 1;
    }

    function removeContact(contact){
        //consoleDebug("SHOULD REMOVE CONTACT WITH JID"+contact.jid);
        //consoleDebug(ConversationHelper.contacts.length);
        for(var i=0; i<ConversationHelper.contacts.length; i++){
            if(ConversationHelper.contacts[i].jid == contact.jid){
                //consoleDebug("REMOVED A CONTACT");
                ConversationHelper.contacts.splice(i,1);
                return;
            }
        }
    }

    function addContact(c){
        ConversationHelper.contacts.push(c);
        contacts = ConversationHelper.contacts;
        addObserver(c);
        onChange();
    }

    function updateLastMessage(){
        //consoleDebug("UPDATING LAST MESSAGE AND SHOULD REBIND ALL CONCERNED!");

        var m = conv_data.get(conv_data.count-1);

        if(!lastMessage || lastMessage.created != m.created)
        {
            lastMessage = conv_data.get(conv_data.count-1);
			title = getTitle()
            onChange();
        }
    }




    /*Component.onCompleted:{


       conv_data.insert(0,{"msg_id":"", "content":"", "type":0,
                            "timestamp":"", "status":"","author":"",
                            "mediatype_id":10, "media":"", "progress":0})


        //requestPresence(jid);
    }*/


    function open(){

        if(jid != appWindow.getActiveConversation()){
            appWindow.pageStack.push(conversation_view);
        }

        appWindow.conversationOpened(jid);

        if(unreadCount){
            //consoleDebug("OPENED,RESETTING COUNT")
            unreadCount =0;
            onChange();
            //consoleDebug("SHOULD REFLECT!")
        }
    }

    signal conversationUpdated(variant message);
    signal typing(string jid);
    signal paused(string jid);

    function setOnline(){ustatus.setOnline();}
    function setTyping(){ustatus.setTyping();}
    function setPaused(){ustatus.setPaused();}
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

    /*function mediaTransferProgressUpdated(progress,message_id){
        var bubble = getBubble(message_id);
        if(bubble){
            bubble.progress = progress
        }
    }

    function mediaTransferSuccess(message_id,mediaObject){
        var bubble = getBubble(message_id);
        if(bubble){
            bubble.media = mediaObject
            bubble.progress =0
        }
    }

    function mediaTransferError(message_id,mediaObject){
        var bubble = getBubble(message_id);
        if(bubble){
            bubble.media = mediaObject
            bubble.progress = 1;
            bubble.progress--;//to trigger fail->fail state change
        }
    }*/

    function messageSent(msg_id){
        var bubble = getBubble(msg_id);
        if(bubble){
            bubble.status = "pending";
        }
    }

    function messageDelivered(msg_id){
        var bubble = getBubble(msg_id);
        if(bubble){
            bubble.status= "delivered";

          //  if(lastMessage.id == bubble.id){
            //    updateLastMessage();
            //}
        }
    }

    function addMessage(message){
		//if (!opened && conv_data.count==2)
		//	conv_data.remove(0)

        /*if (!loadReverse && myAccount!="" && message.type!="1") {
			if (isGroup() && vibraForGroup=="Yes") appWindow.vibrateNow()
			else if (!isGroup() && vibraForPersonal=="Yes") appWindow.vibrateNow()
        }*/

		ConvScript.addMessage(loadReverse,positionToAdd,message);
		positionToAdd = positionToAdd+1
		updateLastMessage()
		if (!loadReverse) appWindow.checkUnreadMessages();
	}

    function getNameForBubble(uname)
    {
        var arr = uname.split(' ');
        return arr[0];
    }

    function goToEndOfList(){
        conv_items.positionViewAtIndex(conv_items.count-1, ListView.Contain)
    }

    Emojidialog{
        id:emojiDialog

        Component.onCompleted: {
            emojiDialog.emojiSelected.connect(conversation_view.emojiSelected);
        }

    }

    Rectangle{
        id:top_bar
        width:parent.width
		color: "transparent" //theme.inverted? "#161616" : "transparent"
        height: appWindow.inPortrait ? 73 : (showSendButton ? 0 : 73)
		clip: true
		
        Item {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            anchors.left: parent.left
            anchors.leftMargin: 0
			height: 50

			BorderImage {
				width: 86
				height: 42
				anchors.verticalCenter: parent.verticalCenter
				anchors.left: parent.left
				anchors.leftMargin: 16
				source: "image://theme/meegotouch-sheet-button-"+(theme.inverted?"inverted-":"")+
						"background" + (bcArea.pressed? "-pressed" : "")
				border { left: 22; right: 22; bottom: 22; top: 22; }
				Label { 
					anchors.verticalCenter: parent.verticalCenter
					anchors.horizontalCenter: parent.horizontalCenter
					font.pixelSize: 22; font.bold: true
                    text: qsTr("Back")
				}
			}

			MouseArea {
				id: bcArea
				anchors.top: parent.top
				anchors.left: parent.left
				height: 73
				width: 130
				onClicked: { 
                    //chatsTabButton.clicked()
					appWindow.setActiveConv("")
					appWindow.pageStack.pop(1)
					if (conv_data.count==0 && !isGroup()) {
						// EMPTY CONVERSATION. REMOVING
						deleteConversation(jid)
						removeChatItem(jid)
					}
                }
			}

	        Label {
                id: conversationTitle
                text: title
				width: parent.width - 74
	            horizontalAlignment: Text.AlignRight
				verticalAlignment: Text.AlignTop
	            font.bold: true
                font.italic: isGroup() && subject==""
				y: isGroup() ? 8 : (ustatus.state=="default"? 8 : -1)
				height: 28
	        }
			UserStatus {
		        id:ustatus
		        height:30
		        itemwidth: parent.width -74
                anchors.top: conversationTitle.bottom
				visible: !isGroup()
		    }
            RoundedImage {
                id:userimage
                size:50
                imgsource:picture
                anchors.verticalCenter: parent.verticalCenter
				anchors.right: parent.right
				anchors.rightMargin: 16
            }
			MouseArea {
				anchors.right: parent.right
				anchors.top: parent.top
				height: 73
				width: 84
				onClicked: { 
					if (!conversation_view.isGroup()) {
                        var contact = waContacts.getOrCreateContact({"jid":conversation_view.jid});
                        contact.openProfile();
					} else {
						profileUser = jid
                        //pageStack.push (Qt.resolvedUrl("../Groups/GroupProfile.qml"))
                        openProfile();
                        conversationProfile.item.getInfo();
					}
				}
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
		if (inputText==myAccount)
			return qsTr("You")
        var resp = inputText;
		var founded = false
        for(var i =0; i<contactsModel.count; i++)
        {
            if(resp == contactsModel.get(i).jid) {
				founded = true
                resp = contactsModel.get(i).name;
		    	if (resp.indexOf("@")>-1  && contactsModel.get(i).pushname)
					resp = contactsModel.get(i).pushname;
				break;
			}
        }
		if (founded) return resp
		else return resp.split('@')[0]
    }

    function getAuthorPicture(inputText) {
        var resp = inputText;
        for(var i =0; i<contactsModel.count; i++)
        {
            if(resp == contactsModel.get(i).jid) {
                resp = contactsModel.get(i).picture;
				break;
			}
        }
        return resp.split('@')[0]
    }



	ListModel { id:groupMembers }

    function getBubbleColor(user) {

		var color = -1
		if (groupMembers.count==0) {
			groupMembers.insert(groupMembers.count, {"name":user})
			color = 1
		} else {
			for(var i =0; i<groupMembers.count; i++)
			{
				if(user == groupMembers.get(i).name) {
				    color = i+1;
					break;
				}
			}
			if (color==-1) {
				groupMembers.insert(groupMembers.count, {"name":user})
				color = groupMembers.count
			}
        }
		return color;
	}


    Component{
        id:myDelegate

        BubbleDelegate{
			jid: conversation_view.jid
            mediatype_id: model.mediatype_id
            message: model.type==20 || model.type==21 ? getAuthor(model.content) : model.content
            media: model.media
            date: model.timestamp
            from_me: model.type
            progress: model.progress
			msg_id: model.msg_id
            name: mediatype_id==10 || from_me==1 || !isGroup? "" : model.type==22? model.author.jid : getAuthor(model.author.jid)
            author: model.author
		 	state_status: isGroup && model.status == "pending"? "delivered" : model.status
			isGroup: conversation_view.isGroup()
            bubbleColor: from_me==1 ? 1 : isGroup ? getBubbleColor(model.author.jid) : mainBubbleColor

			onOptionsRequested: {

				consoleDebug("options requested ") // + ConversationHelper.getContact(model.author.jid).contactName)
                copy_facilitator.text = model.content;
                selectedMessage = model;
                selectedMessageIndex = index
				showContactDetails = model.type==0 && name==model.author.jid.split('@')[0]
				bubbleMenu.open();
			}
			
			Connections {
				target: appWindow

				onUpdateContactName: {
					if (model.author.jid == ujid) {
						if (model.author.jid = ujid.split('@')[0] && isGroup && from_me==0) {
							consoleDebug("Update push name in Conversation bubbles")
							name= mediatype_id==10 || from_me==1 || !isGroup ? "" : getAuthor(model.author.jid).split('@')[0]
						}
					}
				}
			}
			
        }
    }

	Timer {
		id:typing_timer
		interval: 2000; running: false; repeat: false
		onTriggered: {
		    iamtyping = false;
            sendPaused(jid);
	    }
    }

    Rectangle {
		id: conv_panel
        color: "transparent" //theme.inverted? "transparent" : "#dedfde"
        anchors.top: parent.top
        anchors.topMargin: top_bar.height
        width: parent.width
        height: parent.height - top_bar.height - input_button_holder.height
        clip: true

        Item {
        	anchors.fill: parent
            visible: !opened

            Label{
                anchors.centerIn: parent;
                text: qsTr("Loading conversation...")
                font.pointSize: 20
                width:parent.width
                horizontalAlignment: Text.AlignHCenter
				color: "gray"
            }
        }



        /*Rectangle {
            id: topMargin
            color: "transparent"
            width: parent.width
            height: Math.max(0, parent.height-(conv_items.count>3?input_button_holder.height:0)-conv_items.contentHeight)
			visible: opened
        }*/

        ListView{
            id:conv_items
            spacing: 6
            delegate: myDelegate
            model: conv_data
            anchors.top: parent.top
            //anchors.topMargin: topMargin.height
            height: parent.height - myTextArea.height
            width: parent.width
            cacheBuffer: 10000
			visible: opened
            onCountChanged: {
                //do some magic
            }
            header: messagesListHeader
			
        }

		Rectangle {
            id: myTextArea
            color: "transparent"
            height: input_holder.height
			anchors.bottom: parent.bottom
            width: appWindow.inPortrait? 480 : 854

            Rectangle {
                id: input_holder
                anchors.top: parent.top
                anchors.topMargin: 10
                anchors.left: parent.left
                width: parent.width
                height: currentTextHeight
                color: theme.inverted? "#1A1A1A" : "white"

                Image {
                    x: 16; y: 12;
                    height: 36; width: 36; smooth: true
                    source: "../common/images/icons/wazapp36" + (blockedContacts.indexOf(jid)>-1? "blocked":"") + ".png"
                }

                MouseArea {
                    id: input_holder_area
                    anchors.fill: parent
					enabled: blockedContacts.indexOf(jid)==-1
                    onClicked: {
                        showSendButton=true;
                        forceFocusToChatText()
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

                Connections{
                    target:conversation_view

					onForceFocusToChatText: chat_text.forceActiveFocus()

                    onSendButtonClicked:{
                        //consoleDebug("SEND CLICKED");
						sendMediaWindow.opacity = 0

                        showSendButton=true;
                        forceFocusToChatText()

                        var toSend = cleanText(chat_text.text);
                        toSend = toSend.trim();
                        if (toSend != "")
                        {
                            chat_text.text = "";
                            appWindow.sendMessage(jid,toSend);
                        }
                        forceFocusToChatText()

                    }

                    onEmojiSelected:{
                        consoleDebug("GOT EMOJI "+emojiCode);

                        /*var str = cleanText(chat_text.text);

                        var emojiImg = '<img src="/opt/waxmppplugin/bin/wazapp/UI/common/images/emoji/32/emoji-E'+emojiCode+'.png" />'
                        str = str.substring(0,chat_text.lastPosition) + emojiImg + str.slice(chat_text.lastPosition)

                        chat_text.text = str;
                        chat_text.cursorPosition = chat_text.lastPosition + 1
                        forceFocusToChatText()*/

                       	var str = cleanText(chat_text.text)

						var pos = str.indexOf("&quot;")
						var newPosition = chat_text.lastPosition
						while(pos>-1 && pos<chat_text.lastPosition) {
							chat_text.lastPosition = chat_text.lastPosition +5
							pos = str.indexOf("&quot;", pos+1)
							
						}
						pos = str.indexOf("&amp;")
						while(pos>-1 && pos<chat_text.lastPosition) {
							chat_text.lastPosition = chat_text.lastPosition +4
							pos = str.indexOf("&amp;", pos+1)
						}
						pos = str.indexOf("&lt;")
						while(pos>-1 && pos<chat_text.lastPosition) {
							chat_text.lastPosition = chat_text.lastPosition +3
							pos = str.indexOf("&lt;", pos+1)
						}
						pos = str.indexOf("&gt;")
						while(pos>-1 && pos<chat_text.lastPosition) {
							chat_text.lastPosition = chat_text.lastPosition +3
							pos = str.indexOf("&gt;", pos+1)
						}
						pos = str.indexOf("<br />")
						while(pos>-1 && pos<chat_text.lastPosition) {
							chat_text.lastPosition = chat_text.lastPosition +5
							pos = str.indexOf("<br />", pos+1)
						}

						var emojiImg = '<img src="/opt/waxmppplugin/bin/wazapp/UI/common/images/emoji/20/emoji-E'+emojiCode+'.png" />'
						str = str.substring(0,chat_text.lastPosition) + cleanText(emojiImg) + str.slice(chat_text.lastPosition)
						chat_text.text = Helpers.emojify2(str)
						chat_text.cursorPosition = newPosition + 1
						forceFocusToChatText()
                    }

                }

                WATextArea {
                    id: chat_text
                    width:parent.width -60
                    x: 54
                    y: 0
                    placeholderText: blockedContacts.indexOf(jid)>-1 ?
									 qsTr("Contact blocked") : 
									 (showSendButton|| cleanText(chat_text.text).trim()!="") ? "" : qsTr("Write your message here")
                    platformStyle: myTextFieldStyle
                    wrapMode: TextEdit.Wrap
                    textFormat: Text.RichText
					enabled: blockedContacts.indexOf(jid)==-1

                    property bool alreadyFocused: false

					function cleanTextWithoutLines(txt){
						//consoleDebug("LAST POSITION: " + lastPosition)
						var repl = "p, li { white-space: pre-wrap; }";
						var res = txt;
						res = Helpers.getCode(res);
						while(res.indexOf("<br />")>-1) res = res.replace("<br />", "wazappLineBreak");
						res = res.replace(/<[^>]*>?/g, "").replace(repl,"");
						res = res.replace(/^\s+/,"");
						while(res.indexOf("wazappLineBreak")>-1) res = res.replace("wazappLineBreak", "<br />");
						//consoleDebug("PREVIOUS TEXT: "  + res)
						return res;
					}

					onHeightChanged: {
						//consoleDebug("TEXT AREA HEIGHT: " + parseInt(chat_text.height))
						currentTextHeight = chat_text.height<72 ? 72 : chat_text.height+12
						textHeightChanged()
						if (conversation_view.status == PageStatus.Active)
							conv_items.positionViewAtEnd()
						//input_holder.height = currentTextHeight
					}

					onTextPasted: {
						chat_text.text = Helpers.emojify2(chat_text.text)
					}
					
                    onTextChanged: {
                        sendMediaWindow.opacity = 0

                        //chat_text.text = Helpers.emojify2(chat_text.text)
                        if(!typingEnabled)
                        {
                            //to prevent initial set of placeHolderText from firing textChanged signal
                            typingEnabled = true
                            return
                        }
                        if(!isGroup()) {
                            if(!iamtyping) {
                                consoleDebug("TYPING");
                                sendTyping(jid);
                            }
                            iamtyping = true;
                            typing_timer.restart();

                        }
                    }

                    platformSipAttributes: SipAttributes {
                        actionKeyEnabled: chat_text.cursorPosition>0
                        actionKeyLabel: sendWithEnterKey? qsTr("Send") : ""
                    }

                    onEnterKeyClicked: { 
						sendMediaWindow.opacity = 0

						if (sendWithEnterKey) {
							sendButtonClicked();
							forceFocusToChatText()
						} else {
							lastPosition = chat_text.cursorPosition
							var str = cleanTextWithoutLines(chat_text.text)

							var pos = str.indexOf("<br />")
							var newPosition = lastPosition
							while(pos>-1 && pos<lastPosition) {
								lastPosition = lastPosition +5
								pos = str.indexOf("<br />", pos+1)
							}
							
							str = str.substring(0,lastPosition) + "<br />" + str.slice(lastPosition)
							chat_text.text = Helpers.emojify2(str)
							chat_text.cursorPosition = newPosition + 1
						}
					}

					onInputPanelChanged: conv_items.positionViewAtEnd()

                    onActiveFocusChanged: {
                        lastPosition = chat_text.cursorPosition
                        //consoleDebug("LAST POSITION: " + lastPosition)
						conv_items.positionViewAtEnd()
                        showSendButton = chat_text.focus || input_button_holder_area.focus || emoji_button.focus
                        if (showSendButton) {
                            if (!alreadyFocused) {
                                alreadyFocused = true
                                goToEndOfList()
                            }
                        } else {
                            alreadyFocused = false
							sendMediaWindow.opacity = 0
						}
                    }
                }
            }

        }
    }

	SendMedia {
		id: sendMediaWindow
		height: appWindow.inPortrait? 180 : 100
		width: parent.width
		opacity: 0
		visible: opacity!=0
		anchors.bottom: parent.bottom
		anchors.bottomMargin: 90

		Behavior on opacity {
		    NumberAnimation { duration: 200 }
		}

		onSelected: {
			sendMediaWindow.opacity = 0
			if (value=="pic") {
				pageStack.push(sendPicture)
			} 
			else if (value=="campic") {
				openCamera(jid,"still-capture")
				//pageStack.push(Qt.resolvedUrl("TakePicture.qml"))
			} 
			else if (value=="vid") {
				pageStack.push(sendVideo)
			}
			else if (value=="camvid") {
				openCamera(jid,"video-capture")
			}
			else if (value=="audio") {
				pageStack.push(sendAudio)
			}
			else if (value=="rec") {
				pageStack.push(sendAudioRec)
			}
			else if (value=="location") {
				pageStack.push (Qt.resolvedUrl("Location.qml"))
			}
			else if (value=="vcard") {
				shareSyncContacts.mode = "share"
				pageStack.push(shareSyncContacts)
			}
		}
	}


    function cleanText(txt){
        var repl = "p, li { white-space: pre-wrap; }";
        var res = txt;
        res = Helpers.getCode(res);
		res = res.replace("text-indent:0px;\"><br />","text-indent:0px;\">")
		while(res.indexOf("<br />")>-1) res = res.replace("<br />", "wazappLineBreak");
		res = res.replace(/<[^>]*>?/g, "").replace(repl,"");
		res = res.replace(/^\s+/,"");
		while(res.indexOf("wazappLineBreak")>-1) res = res.replace("wazappLineBreak", "<br />");
		return res;
    }


	Rectangle {
		id: input_button_holder
		anchors.bottom: parent.bottom
		anchors.left: parent.left
		width: parent.width
		height: blockedContacts.indexOf(jid)==-1 && showSendButton ? 72 : 0
		color: theme.inverted? "#1A1A1A" : "white"
		clip: true
		
	    MouseArea {
			id: input_button_holder_area
			anchors.fill: parent
			onClicked: { 
				sendMediaWindow.opacity = 0
				showSendButton=true; 
				forceFocusToChatText()
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
            iconSource: "../common/images/emoji/32/emoji-E415.png"
		    anchors.left: parent.left
			anchors.leftMargin: 16
		    anchors.verticalCenter: send_button.verticalCenter
            onClicked: {
				sendMediaWindow.opacity = 0
                emojiDialog.openDialog();
				showSendButton=true; 
                chat_text.lastPosition = chat_text.cursorPosition
		    }
		}

		Button {
			id: media_button
			anchors.left: emoji_button.right
			anchors.leftMargin: 12
			anchors.verticalCenter: parent.verticalCenter
			width: 50
			height: width
			iconSource: theme.inverted ? "../common/images/attachment-white.png" : "../common/images/attachment.png"

			onClicked: {
				if (sendMediaWindow.visible) sendMediaWindow.opacity = 0
				else sendMediaWindow.opacity = 1
				showSendButton=true; 
				forceFocusToChatText()
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
		    onClicked: sendButtonClicked();
		}

	}

    TextField{
        id:copy_facilitator
        visible:false
    }

    Menu {
        id: bubbleMenu

        MenuLayout {

            WAMenuItem{
				height: 80
                text: qsTr("Copy content")
				//singleItem: !profileMenuItem.visible
                onClicked:{
                    copy_facilitator.selectAll()
                    copy_facilitator.copy()
				}
            }

			// REMOVE SINGLE ITEM IS NOT WORKING WELL
			// EDIT: Testing now with fixed textArea
            WAMenuItem{
				height: 80
                text: qsTr("Remove message")
				bottomItem: !profileMenuItem.visible
                onClicked:{
                    deleteMessage(jid, selectedMessage.msg_id)
					conv_data.remove(selectedMessageIndex)
                    if(hasMore) {
                        loadMoreMessages(1);
					}
                    updateLastMessage();
				}
            }

            WAMenuItem{
				id: profileMenuItem
                visible: conversation_view.isGroup() && (selectedMessage?selectedMessage.author.jid!=myAccount:false)
				height: visible ? 80 : 0
                text: qsTr("View contact profile")
                onClicked:{
					profileUser = selectedMessage.author.jid
					pageStack.push (Qt.resolvedUrl("../Contacts/ContactProfile.qml"))
				}
            }

        }
    }

    Component {
        id: messagesListHeader

        Item{
            //visible: hasMore
            width:conv_items.width
            //height:visible?loadMoreButton.height+20:0;
			height: Math.max(hasMore?60:0, conv_panel.height -conv_items.contentHeight -myTextArea.height)
            Button{
				visible: hasMore
				height: 44
                id:loadMoreButton
                text:qsTr("Load more...")
				font.pixelSize: 22
                onClicked: {
					var cval = conv_items.count
                    loadMoreMessages(20);
					conv_items.positionViewAtIndex(conv_items.count -cval,ListView.Beginning)
					conv_items.contentY = conv_items.contentY - 60
                }
                anchors.horizontalCenter:parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 12
            }
          }
    }




    Component{
        id:groupProfile
        GroupProfile{
            groupSubject: conversation_view.subject
            groupPicture: conversation_view.picture
            groupOwnerJid: conversation_view.owner
            jid:conversation_view.jid
        }
    }

    Loader{
        id:conversationProfile
    }


}
