import QtQuick 1.1
import com.nokia.meego 1.0

import "js/conversations.js" as ConvScript
import "../common/js/Global.js" as Helpers
import "js/conversation.js" as ConversationHelper
import "../common"
import "../Menu"
import "../EmojiDialog"

WAPage {
    id:conversation_view

	property bool stopReading: false
	property int positionToGo: 0

    onStatusChanged: {
        if(status == PageStatus.Deactivating){
            appWindow.setActiveConv("")
        }
        else if(status == PageStatus.Active){
			if (!opened) {
				while (conv_data.count>2) conv_data.remove(0)
				loadMoreMessages(20)
				opened = true
				conv_items.positionViewAtEnd()
			}
            appWindow.conversationActive(jid);
            appWindow.setActiveConv(jid)
			pageIsActive = true
			opened = true
		}
		else if(status == PageStatus.Inactive){
			while (conv_data.count>21) conv_data.remove(0)
			conv_items.positionViewAtEnd()
			opened = false
		}        
    }

	property int listHeaderContent: 0
	/*onHeightChanged: {
		if (appWindow.inPortrait)
			listHeaderContent = Math.max(hasMore?60:0, (showSendButton?355:745)-conv_items.contentHeight)
		else
			listHeaderContent = Math.max(hasMore?60:0, (showSendButton?150:444)-conv_items.contentHeight)

		console.log("MARGIN HEIGHT: "+ listHeaderContent + " - LIST HEIGHT: " + conv_items.contentHeight)

		if (showSendButton)
			conv_items.contentY = positionToGo +390
		else
			goToEndOfList()
	}*/

	TextFieldStyle {
        id: myTextFieldStyle
        backgroundSelected: ""
        background: ""
		backgroundDisabled: ""
		backgroundError: ""
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
    property string defaultGroupIcon:"../common/images/group.png"
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
	
	signal textHeightChanged;
    signal sendButtonClicked;
	signal forceFocusToChatText;
    signal emojiSelected(string emojiCode);


	Connections {
		target: appWindow
		onGroupInfoUpdated: {
			var data = groupInfoData.split("<<->>")
			if (jid==data[0]) {
				owner = data[1]
			}
		}
		onOnPictureUpdated: {
			if (jid == ujid) {
				userimage.imgsource = ""
				userimage.imgsource = getPicture()
			}
		}	

	}

    function loadMoreMessages(value){
        var firstMessage = conv_data.get(0);

        if(!firstMessage)
            return;

        console.log("SHOULD LOAD MORE");
        appWindow.loadMessages(jid,firstMessage.msg_id,value);
    }

    function getContacts(){return ConversationHelper.contacts;}

    function getTitle(){
        var title="";

        if(isGroup())
            title = subject==""?groupSubjectNotReady:subject;
        else if(contacts && contacts.length)
            title= getAuthor(jid);

        return title;
    }

    function getPicture(){
        var pic="";

        if(isGroup())
            pic = "/home/user/.cache/wazapp/contacts/" + jid.split('@')[0] + ".png"
        else if(contacts && contacts.length)
            pic = getAuthorPicture(jid) //contacts[0].contactPicture;

        return pic;
    }

    function addObserver(o){

        for(var i=0;i<ConversationHelper.observers.length;i++){

            if(ConversationHelper.observers[i]==o){
                //console.log("DUPLICATE OBSERVER!!!");
                return;
            }

        }

        ConversationHelper.observers.push(o);
        //console.log("Added observer");
    }

    function onChange(){
        for(var i=0; i<ConversationHelper.observers.length; i++){
            //console.log("REBIND")
            var o = ConversationHelper.observers[i];
            if(o && o.rebind)
                o.rebind();
        }
    }

    function rebind(){
        title:getTitle();
        picture:getPicture();
    }


    function isGroup(){
        return jid.split('-').length > 1;
    }

    function removeContact(contact){
        //console.log("SHOULD REMOVE CONTACT WITH JID"+contact.jid);
        //console.log(ConversationHelper.contacts.length);
        for(var i=0; i<ConversationHelper.contacts.length; i++){
            if(ConversationHelper.contacts[i].jid == contact.jid){
                //console.log("REMOVED A CONTACT");
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
        //console.log("UPDATING LAST MESSAGE AND SHOULD REBIND ALL CONCERNED!");

        var m = conv_data.get(conv_data.count-2);

        if(!lastMessage || lastMessage.created != m.created)
        {
            lastMessage = conv_data.get(conv_data.count-2);
            onChange();
        }
    }




    Component.onCompleted:{

		conv_data.insert(0,{"msg_id":"", "content":"", "type":0,
                            "timestamp":"", "status":"","author":"",
                            "mediatype_id":10, "media":"", "progress":0})

        //requestPresence(jid);
    }

    function open(){

        if(jid != appWindow.getActiveConversation()){
            appWindow.pageStack.push(conversation_view);
        }

        appWindow.conversationOpened(jid);

        if(unreadCount){
            //console.log("OPENED,RESETTING COUNT")
            unreadCount =0;
            onChange();
            //console.log("SHOULD REFLECT!")
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

    function mediaTransferProgressUpdated(progress,message_id){
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
    }

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

    function addMessage(message){ConvScript.addMessage(message);}

    function getNameForBubble(uname)
    {
        var arr = uname.split(' ');
        return arr[0];
    }

    function goToEndOfList() {
        //conv_items.positionViewAtIndex(conv_items.count-1, ListView.Contain)
		conv_items.positionViewAtIndex(conv_items.count-1, ListView.End)
		//conv_items.positionViewAtEnd()
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
						if (conv_data.count==1 && !isGroup()) {
							// EMPTY CONVERSATION. REMOVING
							deleteConversation(jid)
							removeChatItem(jid)
						}
                    }
				}
			}

	        Label {
                id: conversationTitle
                text: title
				width: parent.width - 62
	            horizontalAlignment: Text.AlignRight
				verticalAlignment: Text.AlignTop
	            font.bold: true
                font.italic: isGroup() && subject==""
				y: isGroup() ? 8 : -1
				height: 28
	        }
			UserStatus {
		        id:ustatus
		        height:30
		        itemwidth: parent.width -62
                anchors.top: conversationTitle.bottom
				visible: !isGroup()
		    }
            RoundedImage {
                id:userimage
                size:50
                imgsource:picture
                anchors.verticalCenter: parent.verticalCenter
				anchors.right: parent.right
				/*onImageError: {
					if (isGroup())
						picture="../common/images/group.png"
					else
						picture="../common/images/user.png"
				}*/
				MouseArea {
					anchors.fill: parent
					// User Profile window. Not finished yet
					onClicked: { 
						if (!conversation_view.isGroup()) {
							profileUser = jid
							pageStack.push (Qt.resolvedUrl("../Contacts/ContactProfile.qml"))
						} else {
							profileUser = jid
							pageStack.push (Qt.resolvedUrl("../Groups/GroupProfile.qml"))
						}
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
        for(var i =0; i<contactsModel.count; i++)
        {
            if(resp == contactsModel.get(i).jid) {
                resp = contactsModel.get(i).name;
				break;
			}
        }
        return resp
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
        return resp
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
		return color-1;
	}


    Component{
        id:myDelegate

        BubbleDelegate{
            mediatype_id: model.mediatype_id
            message: model.type==20 || model.type==21 ? getAuthor(model.content) : model.content
            media:model.media
            date: model.timestamp
            from_me: model.type
            progress:model.progress
            name: mediatype_id==10 || from_me==1 || !isGroup ? "" : getAuthor(model.author.jid).split('@')[0]
            author:model.author
		 	state_status:isGroup && model.status == "pending"?"delivered":model.status
            isGroup: conversation_view.isGroup()
            bubbleColor: from_me==1 ? 1 : isGroup ? getBubbleColor(model.author.jid) : mainBubbleColor

			onOptionsRequested: {

				console.log("options requested ") // + ConversationHelper.getContact(model.author.jid).contactName)
                copy_facilitator.text = model.content;
                selectedMessage = model;
                selectedMessageIndex = index
				showContactDetails = model.type==0 && name==model.author.jid.split('@')[0]
				bubbleMenu.open();
			}
        }
    }

	Timer {
		id:typing_timer
		interval: 2000; running: false; repeat: false
		onTriggered: {
		    iamtyping = false;
            paused(jid);
	    }
    }

    Rectangle {
        color: theme.inverted? "transparent" : "#dedfde"
        anchors.bottom: parent.bottom
        //anchors.topMargin: top_bar.height
        width: parent.width
        height: parent.height - top_bar.height
        clip: true

        /*Rectangle {
            id: topMargin
            color: "transparent"
            width: parent.width
            //height: Math.max(0, parent.height+(conv_items.count>3?input_button_holder.height:0)-conv_items.contentHeight)
			height: 0
			//onHeightChanged: console.log("MARGIN HEIGHT: "+ topMargin.height + " - LIST HEIGHT: " + conv_items.contentHeight)
		
			
        }*/

        ListView{
            id:conv_items
            spacing: 6
            delegate: myDelegate
            model: conv_data
            anchors.bottom: input_button_holder.top
            height: parent.height - input_button_holder.height
            width: parent.width
            cacheBuffer: 20000
			//boundsBehavior: Flickable.StopAtBounds
            /*onCountChanged: {
				if (appWindow.inPortrait)
					listHeaderContent = Math.max(hasMore?60:0, (showSendButton?355:745)-conv_items.contentHeight)
				else
					listHeaderContent = Math.max(hasMore?60:0, (showSendButton?50:444)-conv_items.contentHeight)
            }
			onContentYChanged: {
				//console.log("CONTENT Y: " + conv_items.contentY)
				//if (!stopReading) positionToGo = conv_items.contentY
			}*/
            header: messagesListHeader

        }

		Rectangle {
			id: input_button_holder
			anchors.bottom: parent.bottom
			anchors.left: parent.left
			width: parent.width
			height: (showSendButton)? 72 : 0
			color: theme.inverted? "#1A1A1A" : "white"
			clip: true
		
			MouseArea {
				id: input_button_holder_area
				anchors.fill: parent
				onClicked: { 
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
		            //var component = Qt.createComponent("Emojidialog.qml");
		            //var sprite = component.createObject(conversation_view, {});

		            emojiDialog.openDialog();
				}
			}

			Button
			{
				id: location_button
				//platformStyle: ButtonStyle { inverted: true }
				width:50
				height:50
		        iconSource: "../common/images/location.png"
				anchors.left: emoji_button.right
				anchors.leftMargin: 16
				anchors.verticalCenter: send_button.verticalCenter
		        onClicked: {
		            pageStack.push (Qt.resolvedUrl("Location.qml"))
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
				onClicked: sendButtonClicked();
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
				singleItem: !profileMenuItem.visible
                onClicked:{
                    copy_facilitator.selectAll()
                    copy_facilitator.copy()
				}
            }

			// REMOVE SINGLE ITEM IS NOT WORKING WELL
            /*WAMenuItem{
				height: 80
                text: qsTr("Remove message")
				bottomItem: !profileMenuItem.visible
                onClicked:{
                    deleteMessage(jid, selectedMessage.msg_id)
					conv_data.remove(selectedMessageIndex)
                    if(hasMore && conv_items.contentHeight<(conversation_view.height-top_bar.height))
                        loadMoreMessages(1);

                    updateLastMessage();
				}
            }*/

            WAMenuItem{
				id: profileMenuItem
				visible: conversation_view.isGroup() && showContactDetails
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
			height: Math.max(hasMore?60:0, parent.height -conv_items.contentHeight)
            Button{
				visible: hasMore
				height: 44
                id:loadMoreButton
                text:qsTr("Load more...")
				font.pixelSize: 22
                onClicked: {
					var cval = conv_items.count
                    loadMoreMessages(15);
					conv_items.positionViewAtIndex(conv_items.count -cval,ListView.Beginning)
					conv_items.contentY = conv_items.contentY - 70
                }
                anchors.horizontalCenter:parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 12
            }
          }
    }

    Component {
        id: textInputComponent

        Rectangle {
            id: spacer
            color: "transparent"
            height: input_holder.height
            width: appWindow.inPortrait? 480 : 854

            Rectangle {
                id: input_holder
                anchors.top: parent.top
                anchors.topMargin: 10
                anchors.left: parent.left
                width: parent.width
                height: chat_text.height<72? 72 : chat_text.height+12
                color: theme.inverted? "#1A1A1A" : "white"

                Image {
                    x: 16; y: 12;
                    height: 36; width: 36; smooth: true
                    source: "../common/images/icons/wazapp48.png"
                }

                MouseArea {
                    id: input_holder_area
                    anchors.fill: parent
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
                        //console.log("SEND CLICKED");

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
                        console.log("GOT EMOJI "+emojiCode);

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
                    placeholderText: (showSendButton|| cleanText(chat_text.text).trim()!="") ? "" : qsTr("Write your message here")
                    platformStyle: myTextFieldStyle
                    wrapMode: TextEdit.Wrap
                    textFormat: Text.RichText

                    property bool alreadyFocused: false

					function cleanTextWithoutLines(txt){
						//console.log("LAST POSITION: " + lastPosition)
						var repl = "p, li { white-space: pre-wrap; }";
						var res = txt;
						res = Helpers.getCode(res);
						while(res.indexOf("<br />")>-1) res = res.replace("<br />", "wazappLineBreak");
						res = res.replace(/<[^>]*>?/g, "").replace(repl,"");
						res = res.replace(/^\s+/,"");
						while(res.indexOf("wazappLineBreak")>-1) res = res.replace("wazappLineBreak", "<br />");
						//console.log("PREVIOUS TEXT: "  + res)
						return res;
					}

					onHeightChanged: {
						//console.log("TEXT AREA HEIGHT: " + parseInt(chat_text.height))
						currentTextHeight = chat_text.height<72 ? 72 : chat_text.height+12
						textHeightChanged()
						if (conversation_view.status == PageStatus.Active)
							conv_items.positionViewAtEnd()
						//input_holder.height = Math.max(chat_text.height, 65)
					}

                    onTextChanged: {
                        if(!typingEnabled)
                        {
                            //to prevent initial set of placeHolderText from firing textChanged signal
                            typingEnabled = true
                            return
                        }

                        if(!iamtyping)
                        {
                            console.log("TYPING");
                            typing(jid);
                        }
                        iamtyping = true;
                        typing_timer.restart();
                    }

                    platformSipAttributes: SipAttributes {
                        actionKeyEnabled: true
                        actionKeyLabel: sendWithEnterKey? qsTr("Send") : ""
                    }

                    onEnterKeyClicked: { 
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

                    onActiveFocusChanged: {
                        lastPosition = chat_text.cursorPosition
                        //console.log("LAST POSITION: " + lastPosition)
                        showSendButton = chat_text.focus || input_button_holder_area.focus || emoji_button.focus
                        /*if (showSendButton) {
							if (!alreadyFocused) {
                                alreadyFocused = true
                                goToEndOfList()
                            }
                        } else
                            alreadyFocused = false
						*/
                    }
                }
            }

        }

    }
}
