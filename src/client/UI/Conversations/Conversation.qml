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

    onStatusChanged: {
        if(status == PageStatus.Deactivating){
            appWindow.setActiveConv("")
        }
        else if(status == PageStatus.Active){
            appWindow.conversationActive(jid);
            appWindow.setActiveConv(jid)
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

    /****conversation info properties****/
    property int conversation_id;
    property string jid;
    property string title:getTitle();
    property string picture:getPicture();
    property variant contacts;
    property variant lastMessage;
    property string subject;
    property string defaultGroupIcon:"../common/images/group.png"
    property int unreadCount;
    property int remainingMessagesCount;
    property bool hasMore:remainingMessagesCount?true:false
    /*******************************/

    property int inboundBubbleColor: settingsPage.bubbleColor;
    property int outboundBubbleColor: 1

    property string groupSubjectNotReady:qsTr("Fetching group subject")+"...";
    property variant selectedMessage;
    property int selectedMessageIndex;
    property bool typingEnabled:false
    property bool iamtyping:false
    property string pageIdentifier:"conversation_page" //used in notification hiding process
    property bool pageIsActive: false
    property bool showSendButton;

    signal sendButtonClicked;
    signal emojiSelected(string emojiCode);

    function loadMoreMessages(){

        var firstMessage = conv_data.get(0);

        if(!firstMessage)
            return;

         console.log("SHOULD LOAD MORE");
        appWindow.loadMessages(jid,firstMessage.msg_id,10);
    }

    function getContacts(){return ConversationHelper.contacts;}

    function getTitle(){
        var title="";

        if(isGroup())
            title = subject==""?groupSubjectNotReady:subject;
        else if(contacts && contacts.length)
            title= contacts[0].contactName;

        return title;
    }

    function getPicture(){
        var picture="";

        if(isGroup())
            picture = defaultGroupIcon;
        else if(contacts && contacts.length)
            picture = contacts[0].contactPicture;


        console.log(picture);
        return picture;
    }

    function addObserver(o){

        for(var i=0;i<ConversationHelper.observers.length;i++){

            if(ConversationHelper.observers[i]==o){
                console.log("DUPLICATE OBSERVER!!!");
                return;
            }

        }

        ConversationHelper.observers.push(o);
        console.log("Added observer");
    }

    function onChange(){
        for(var i=0; i<ConversationHelper.observers.length; i++){
            console.log("REBIND")
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
        console.log("SHOULD REMOVE CONTACT WITH JID"+contact.jid);
        console.log(ConversationHelper.contacts.length);
        for(var i=0; i<ConversationHelper.contacts.length; i++){
            if(ConversationHelper.contacts[i].jid == contact.jid){
                console.log("REMOVED A CONTACT");
                ConversationHelper.contacts.splice(i,1);
                return;
            }
        }
    }

    function addContact(c){
        console.log("PUSHING")
        ConversationHelper.contacts.push(c);
        console.log("PUSHED")
        console.log(ConversationHelper.contacts);
        console.log(contacts);
        contacts = ConversationHelper.contacts;
        console.log("ASSIGNED")
        addObserver(c);
        console.log("OBSERVED")
        onChange();
        console.log("TRIGGERED CHANGE");

       // c.setConversation(conversation_view);
    }

    function updateLastMessage(){
        console.log("UPDATING LAST MESSAGE AND SHOULD REBIND ALL CONCERNED!");

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
    /*NEW STUFF*/
    function open(){

        if(jid != appWindow.getActiveConversation()){
            appWindow.pageStack.push(conversation_view);
        }

        appWindow.conversationOpened(jid);

        if(unreadCount){
            console.log("OPENED,RESETTING COUNT")
            unreadCount =0;
            onChange();
            console.log("SHOULD REFLECT!")
        }
    }
    /*********/

   // signal conversationUpdated(int msgId, int msgType, string number,string lastMsg,string time,string formattedDate);
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
						conv_items.positionViewAtEnd()
                    }
				}
			}

	        Label {
                id: conversationTitle
                text: title
				width: parent.width - 62
	            horizontalAlignment: Text.AlignRight
				verticalAlignment: Text.AlignTop
				anchors.top: parent.top
	            font.bold: true
                font.italic: isGroup() && subject==""
				height: 28
	        }
			UserStatus {
		        id:ustatus
		        height:30
		        itemwidth: parent.width -62
                anchors.top: conversationTitle.bottom
		    }
            RoundedImage {
                id:userimage
                size:50
                imgsource:picture
                anchors.verticalCenter: parent.verticalCenter
				anchors.right: parent.right
				MouseArea {
					anchors.fill: parent
					// User Profile window. Not finished yet
					//onClicked: { pageStack.push (Qt.resolvedUrl("ContactProfile.qml")) }
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

    Component{
        id:myDelegate

        BubbleDelegate{
            mediatype_id: model.mediatype_id
            message: model.content
            media:model.media
            date: model.timestamp
            from_me:model.type==1
            progress:model.progress
            name: ""/*UNCOMMENTME mediatype_id==10 || from_me || isGroup ? "" : getAuthor(model.author.jid).split('@')[0]*/
            author:model.author
			state_status:model.status
            isGroup: conversation_view.isGroup()
            bubbleColor: model.type==1?outboundBubbleColor:inboundBubbleColor;

			onOptionsRequested: {

				console.log("options requested")
                copy_facilitator.text = model.content;
                selectedMessage = model;
                selectedMessageIndex = index
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
        anchors.top: parent.top
        anchors.topMargin: top_bar.height
        width: parent.width
        height: parent.height - top_bar.height - input_button_holder.height
        clip: true

        Rectangle {
            id: topMargin
            color: "transparent"
            width: parent.width
            height: Math.max(0, parent.height-(conv_items.count>3?input_button_holder.height:0)-conv_items.contentHeight)

        }

        ListView{
            id:conv_items
            spacing: 6
            delegate: myDelegate
            model: conv_data
            anchors.top: parent.top
            anchors.topMargin: topMargin.height
            height: parent.height - topMargin.height
            width: parent.width
            cacheBuffer: 10000
            onCountChanged: {
                //do some magic
            }
            header: messagesListHeader
          //  footer: textInputComponent
        }
    }





    function cleanText(txt){
        var repl = "p, li { white-space: pre-wrap; }";
        var res = txt;
        res = Helpers.getCode(res);
        res = res.replace(/<[^>]*>?/g, "").replace(repl,"");
        return res.replace(/^\s+/,"");
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
                sendButtonClicked();

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

            WAMenuItem{
				height: 80
                text: qsTr("Copy content")
                onClicked:{
                    copy_facilitator.selectAll()
                    copy_facilitator.copy()
				}
            }

            WAMenuItem{
				id: detailsMenuItem
                visible: selectedMessage && selectedMessage.type==0?true:false;
				height: visible ? 80 : 0
                text: selectedMessage?ConversationHelper.getContact(selectedMessage.author.jid).contactName?qsTr("View contact"):qsTr("Add to contacts"):"";
                onClicked:{
                    Qt.openUrlExternally("tel:"+selectedMessage.author.number)
				}
            }

            WAMenuItem{
				height: 80
                text: qsTr("Remove message")
                onClicked:{
                    deleteMessage(jid, selectedMessage.msg_id)
					conv_data.remove(selectedMessageIndex)
                    if(hasMore && conv_items.contentHeight<(conversation_view.height-top_bar.height))
                        loadMoreMessages();

                    updateLastMessage();
				}
            }
        }
    }

    Component {
        id: messagesListHeader

        Item{
            visible: hasMore
            width:conv_items.width
            height:visible?loadMoreButton.height+20:0;
            Button{
                id:loadMoreButton
                text:qsTr("Load more")+"..."
                onClicked: {
                    loadMoreMessages();
                }
                anchors.horizontalCenter:parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.bottomMargin: 20
                anchors.topMargin: 20
            }
          }
    }

    Component {
        id: textInputComponent

        Rectangle {
            id: spacer
            color: "transparent"
            height: input_holder.height + 10
            width: appWindow.inPortrait? 480 : 854

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
                    source: "../common/images/icons/wazapp48.png"
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

                Connections{
                    target:conversation_view
                    onSendButtonClicked:{
                        console.log("SEND CLICKED");

                        showSendButton=true;
                        chat_text.forceActiveFocus()

                        var toSend = cleanText(chat_text.text);
                        toSend = toSend.trim();
                        if (toSend != "")
                        {
                            appWindow.sendMessage(jid,toSend);
                            chat_text.text = "";
                        }
                        chat_text.forceActiveFocus()

                    }

                    onEmojiSelected:{
                        console.log("GOT EMOJI "+emojiCode);

                        var emojiImg = '<img src="../common/images/emoji/20/emoji-E'+emojiCode+'.png" />'
                        console.log(emojiImg);
                        chat_text.text+=emojiImg;

                       /* var str = cleanText(chat_text.text);
                        str = str.substring(0,chat_text.lastPosition) + cleanText(emojiCode) + str.slice(chat_text.lastPosition)
                        chat_text.text = Helpers.emojify2(str)
                        chat_text.cursorPosition = chat_text.lastPosition + 1
                        chat_text.forceActiveFocus();*/
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

                    onTextChanged: {
                        if(!typingEnabled)
                        {
                            //to prevent initial set of placeHolderText from firing textChanged signal
                             //SERIOUSLY HOW MANY TIMES DO I HAVE TO ADD THIS DAMN CHECK AND IT GETS REMOVED?!!
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
                        actionKeyIcon: "image://theme/icon-m-toolbar-send-chat-white"
                        actionKeyLabel: qsTr("Send")
                    }
                    onEnterKeyClicked: { sendButtonClicked(); chat_text.forceActiveFocus() }

                    onActiveFocusChanged: {
                        lastPosition = chat_text.cursorPosition
                        console.log("LAST POSITION: " + lastPosition)
                        showSendButton = chat_text.focus || input_button_holder_area.focus || emoji_button.focus
                        if (showSendButton) {
                            if (!alreadyFocused) {
                                alreadyFocused = true
                                goToEndOfList()
                            }
                        } else
                            alreadyFocused = false

                    }



                }
            }

        }

    }
}
