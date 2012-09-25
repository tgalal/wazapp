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
import QtMobility.gallery 1.1

import "Chats"
import "common"
import "Contacts"
import "Menu"
import "Updater"
//import "Settings"
import "Conversations"
import "Profile"
import "Groups"
import "common/js/settings.js" as MySettings

//import com.nokia.extras 1.0

WAStackWindow {
    id: appWindow
    initialPage: mainPage  
    showStatusBar: !(screen.currentOrientation == Screen.Landscape && activeConvJId!="")
	showToolBar: !dialogOpened

    toolBarPlatformStyle:ToolBarStyle{
        inverted: theme.inverted
    }

    Component.onCompleted: {
		MySettings.initialize()
		theme.inverted = MySettings.getSetting("ThemeColor", "White")=="Black"
		mainBubbleColor = parseInt(MySettings.getSetting("BubbleColor", "1"))
		sendWithEnterKey = MySettings.getSetting("SendWithEnterKey", "Yes")=="Yes"
		resizeImages = MySettings.getSetting("ResizeImages", "Yes")=="Yes"
		orientation = parseInt(MySettings.getSetting("Orientation", "0"))
		vibraForPersonal = MySettings.getSetting("PersonalVibrate", "Yes")
		vibraForGroup = MySettings.getSetting("GroupVibrate", "Yes")
	}

    property string waversiontype:waversion.split('.').length == 4?'developer':'beta'
    property string activeConvJId:""
	property string profileUser
	property bool updateSingleStatus: false
	property bool dialogOpened: false
    property int mainBubbleColor
	property bool sendWithEnterKey
	property bool resizeImages
	property string selectedPicture
	property string selectedContactName: ""
	property string selectedGroupPicture
	property string bigProfileImage
    property int orientation
	property string vibraForPersonal
	property string vibraForGroup

    /****** Signal and Slot definitions *******/

	signal setLanguage(string lang);
	signal consoleDebug(string text);

	signal statusChanged();
    signal changeStatus(string new_status)
    signal sendMessage(string jid, string msg);
    signal requestPresence(string jid);
    signal refreshContacts(string mode, string jid);
    signal sendTyping(string jid);
    signal sendPaused(string jid);
    signal quit()
    signal deleteConversation(string jid);
    signal deleteMessage(string jid, int msg_id);
    signal conversationActive(string jid);
    signal fetchMedia(int id);
    signal fetchGroupMedia(int id);
    signal uploadMedia(int id);
    signal uploadGroupMedia(int id);
    signal loadMessages(string jid, int offsetId, int limit);
    signal conversationOpened(string jid);
	signal sendSMS(string num)
	signal makeCall(string num)
	signal getGroupInfo(string jid);
	signal createGroupChat(string subject);
	signal addParticipants(string gjid, string participants);
	signal addedParticipants();
	signal removeParticipants(string gjid, string participants);
	signal removedParticipants();
	signal getGroupParticipants(string gjid);
	signal groupParticipants();
	signal endGroupChat(string gjid);
	signal groupEnded();
	signal setGroupSubject(string gjid, string subject);
	signal getPictureIds(string jids);
	signal getPicture(string jid, string type);
	signal onContactPictureUpdated(string ujid);
	signal setPicture(string jid, string file);
	signal sendMediaMessage(string jid, string data, string image, string preview);
	signal sendMediaImageFile(string jid, string file);
	signal sendMediaVideoFile(string jid, string file, string preview);
	signal sendMediaAudioFile(string jid, string file);
	signal sendMediaRecordedFile(string jid);
	signal sendLocation(string jid, string latitude, string longitude, string rotate);
    signal sendVCard(string jid, string contact);
	signal removeSingleContact(string jid);
	signal updateContactName(string ujid, string npush);
	signal rotateImage(string file);
	signal imageRotated(string filepath);
	signal getPicturesFinished();
	signal removeFile(string file);
	signal startRecording();
	signal stopRecording();
	signal playRecording();
	signal deleteRecording();


	signal openContactPicker(string multi, string title); //TESTING...
	signal setBlockedContacts(string contacts);
	signal setResizeImages(bool resize);
	signal openCamera(string jid, string mode);
    signal setPersonalRingtone(string value);
    signal setPersonalVibrate(bool value);
	signal setGroupRingtone(string value);
    signal setGroupVibrate(bool value);
	signal vibrateNow();


	signal openPreviewPicture(string ujid, string picturefile, int rotation, string previewimg, string capturemode)
	function capturedPreviewPicture(ujid, picturefile, rotation, previewimg, capturemode) {
		openPreviewPicture(ujid, picturefile, rotation, previewimg, capturemode)
	}

	signal mediaTransferProgressUpdated(int mprogress, int mid)
	signal mediaTransferSuccess(int mid, string filepath)
	signal mediaTransferError(int mid)

	signal selectedMedia(string url);
	property string currentJid: ""

	signal populatePhoneContacts()

	signal thumbnailUpdated()
	function onThumbnailUpdated() {
		thumbnailUpdated()
	}

	signal getImageFiles();
	ListModel {
		id: galleryModel
	}
	function pushImageFiles(files) {
		for (var i=0; i<files.length; ++i) {
			galleryModel.append(files[i])
		}
	}

	signal getVideoFiles();
	ListModel {
		id: galleryVideoModel
	}
	function pushVideoFiles(files) {
		for (var i=0; i<files.length; ++i) {
			galleryVideoModel.append(files[i])
		}
	}

	signal getRingtones();
	signal ringtonesUpdated();
	ListModel {
		id: ringtoneModel
	}
	function pushRingtones(files) {
		ringtoneModel.clear()
		ringtoneModel.append({ name: QT_TR_NOOP("(no sound)"), value: "No sound.wav"})
		for (var i=0; i<files.length; ++i) {
			ringtoneModel.append(files[i])
		}
		ringtonesUpdated();
	}

	signal groupCreated(string group_id)

	function onRemovedParticipants() {
		removedParticipants()
	}


	property string groupParticipantsIds
	function onGroupParticipants(jids) {
		groupParticipantsIds = jids
		groupParticipants()
	}

	function onGroupEnded() {
		groupEnded()
	}

	signal groupInfoUpdated(string gjid, string gdata)

	function onGroupSubjectChanged() {
		getGroupInfo(profileUser)
	}

	
	function uploadResult(data, image, to, preview) {
		if (data.indexOf("ERROR")==-1)
			sendMediaMessage(to, data, image, preview)
	}

    //prevent double opened, sometimes QContactsManager sends more than 1 signal
    property bool updateContactsOpenend: false

            /******************/
	property string connectionStatus
    function onConnected(){
		setIndicatorState("online")
		//getPictures();
	}

    function onConnecting(){setIndicatorState("connecting")}
    function onDisconnected(){setIndicatorState("connecting")}
    function onSleeping(){setIndicatorState("offline")}
    function onLoginFailed(){setIndicatorState("reregister")}

	signal appFocusOut()

    function appFocusChanged(focus){
		if (!focus) appFocusOut()
        var user_id = getActiveConversation()
        if (user_id){
            conversationActive(user_id);
        }
    }

    function setActiveConv(activeJid){
        consoleDebug("SETTING ACTIVE CONV "+activeJid)
        activeConvJId=activeJid
    }

    function onUpdateAvailable(updateData){
        updateDialog.version = updateData.l
        updateDialog.link = updateData.d
        updateDialog.severity = updateData.u
        updateDialog.changes = updateData.m

        updatePage.version = updateData.l
        updatePage.url = updateData.d
        updatePage.urgency = updateData.u
        updatePage.summary = updateData.m

        var changes = ""
        for(var i =0; i<updateData.c.length; i++){
            changes += "* "+updateData.c[i]+"\n";
        }
        updatePage.changes = changes

        updateDialog.open()

        waMenu.updateVisible = true;
    }

    function quitInit(){
        quitConfirm.open();
    }

    function aboutInit(){
        aboutDialog.open();
    }


	function onContactsChanged() {

        /*@@TODO: invalid way and should be removed. When a contact changes, only that changed contact should be synced silently
                and UI gets updated silently as well.**/
		if (updateContactsOpenend==false) {
		consoleDebug("CONTACTS CHANGED!!!");
			updateContactsOpenend = true
			//updateContacts.open()  UI crashes with this, needs more work
		}
	}	

    function onSyncClicked(){
        //tabGroups.currentTab=waContacts;
        appWindow.pageStack.push(loadingPage);
        refreshContacts("SYNC","ALL");
    }

	signal refreshSuccessed
    function onRefreshSuccess(){
		if(!updateSingleStatus) {
			appWindow.pageStack.pop();
			//getPictures()
		}
		updateSingleStatus = false
		refreshSuccessed()
    }

	signal refreshFailed
    function onRefreshFail(){
        if(!updateSingleStatus) appWindow.pageStack.pop();
		updateSingleStatus = false
		refreshFailed()
    }

    function setIndicatorState(indicatorState){
		connectionStatus = indicatorState
        var showPoints = [waChats, waContacts]
        for(var p in showPoints){
            showPoints[p].indicator_state= indicatorState
        }
    }

    function getActiveConversation(){

        if(appWindow.pageStack.currentPage.pageIdentifier && appWindow.pageStack.currentPage.pageIdentifier == "conversation_page")
        {
            return appWindow.pageStack.currentPage.jid;
        }

        return 0;
    }


	property string contactForStatus
	signal contactStatusUpdated(string nstatus)
	function updateContactStatus(status) {
	    for(var i =0; i<contactsModel.count; i++)
        {
            if(contactForStatus == contactsModel.get(i).jid) {
				consoleDebug("FOUNDED CONTACT " + contactsModel.get(i).jid +" - " + status)
				contactsModel.get(i).status = status
			}
        }
		contactStatusUpdated(status)
	}
	
	
	property string myAccount: ""
	function setMyAccount(account) {
		myAccount = account

		blockedContacts = MySettings.getSetting("BlockedContacts", "")
		setBlockedContacts(blockedContacts)

		resizeImages = MySettings.getSetting("ResizeImages", "Yes")=="Yes" ? true : false
		setResizeImages(resizeImages)

		setPersonalRingtone(MySettings.getSetting("PersonalRingtone", "Message 1.mp3"));
        setPersonalVibrate(MySettings.getSetting("PersonalVibrate", "Yes")=="Yes"); //changed to be passed as boolean
		setGroupRingtone(MySettings.getSetting("GroupRingtone", "/usr/share/sounds/ring-tones/Message 1.mp3"));
        setGroupVibrate(MySettings.getSetting("GroupVibrate", "Yes")=="Yes");

	}

	function getPictures() {
		var list;
    	for(var i =0; i<contactsModel.count; i++) {
			list = list + (list!==""? ",":"") + contactsModel.get(i).jid;
			consoleDebug("ADDING TO LIST: " + contactsModel.get(i).jid)
		}
		getPictureIds(list)
	}


	property variant blockedContacts: ""

	function blockContact(jid) {
		blockedContacts = blockedContacts + (blockedContacts!==""? ",":"") + jid;
		MySettings.setSetting("BlockedContacts", blockedContacts)
		setBlockedContacts(blockedContacts)
	}

	function unblockContact(jid) {
		var newc = blockedContacts
		newc = newc.replace(jid,"")
		newc = newc.replace(",,",",")
		blockedContacts = newc
		MySettings.setSetting("BlockedContacts", blockedContacts)
		setBlockedContacts(blockedContacts)
	}

    function updateContactsData(contacts){
		var added = 0
		for(var i =0; i<contacts.length; i++) {
			var add = true
			for(var j =0; j<contactsModel.count; j++) {
				if (contactsModel.get(j).jid==contacts[i].jid) {
					contactsModel.get(j).name = contacts[i].name
					add = false
					break
				}
			}
			if (add) {
				//contacts[i].newContact = true;
				contactsModel.insert(i, contacts[i]);
				currentContacts = currentContacts + "," + contacts[i].jid
				newContacts = newContacts +1
				//contactsAdded.title = newContacts
			}
		}
    }

	property string currentContacts: ""
	property int newContacts: 0

    function pushContacts(mode,contacts){
        waContacts.pushContacts(contacts)
		var newc = 0
		if (mode=="SYNC") {
			newContacts = 0
			for(var j =0; j<contactsModel.count; j++) {
				if (currentContacts.indexOf(contactsModel.get(j).jid)==-1 ) {
					currentContacts = currentContacts + "," + contactsModel.get(j).jid
					//contactsModel.get(j).newContact = true
					newContacts = newContacts +1
				}
			}
			//contactsAdded.title = newContacts
		} else {
			for(var j =0; j<contactsModel.count; j++) {
				currentContacts = currentContacts + "," + contactsModel.get(j).jid
			}
		}
    }

    function pushPhoneContacts(contacts){
        phoneContactsModel.clear()
		consoleDebug("APPENDING PHONE CONTACTS:" + contacts.length)
		for (var i=0; i<contacts.length; i++) {
			phoneContactsModel.insert(phoneContactsModel.count,{"name":contacts[i][0], "picture":contacts[i][1], 
										"numbers":contacts[i][2].toString(), "selected":false})
		}
    }

    function onContactsSyncStatusChanged(s) {
        switch(s){
        case "GETTING": loadingPage.operation = qsTr("Retrieving contacts list...");
            break;
        case "SENDING":  loadingPage.operation = qsTr("Fetching contacts...");
            break;
        case "LOADING": loadingPage.operation = qsTr("Loading contacts...");
            break;
        default:  loadingPage.operation = "";
            break;
        }
    }

    function openConversation(jid){
          consoleDebug("should open chat window with "+jid)

          var conversation = waChats.getOrCreateConversation(jid);
          conversation.open();
     }


    /****Conversation related slots****/

    function conversationReady(conv){
        //This should be called if and only if conversation start point is backend
        consoleDebug("Got a conv in conversationReady slot: " + conv.jid);
        var conversation = waChats.getOrCreateConversation(conv.jid);

        var contact;

        if(conversation.isGroup()) {
            consoleDebug("SUBJET IS "+conv.subject);
            conversation.subject = conv.subject || "";
            conversation.groupIcon = conv.picture || "";
            consoleDebug("Picture is "+conv.picture );

            /*for(var i=0; i<conv.contacts.length; i++) {
                consoleDebug("ADDING CONTACT TO GROUP CONV");
                contact = waContacts.getOrCreateContact({jid:conv.contacts[i].jid});
                conversation.addContact(contact);
                consoleDebug("ADDED");
            }*/
        } else {

            consoleDebug("Finding appropriate contact");
            contact = waContacts.getOrCreateContact({jid:conv.jid});
            conversation.addContact(contact);
            consoleDebug("Binding conversation to contact");
            contact.setConversation(conversation);

        }

    }

	signal reorderConversation(string cjid)
	signal updateChatItemList()

    function messagesReady(messages,reorder){
        consoleDebug("GOT MESSAGES SIGNAL");
        var conversation = waChats.getConversation(messages.jid);
        consoleDebug("proceed to check validity of conv")
        if(!conversation){
            consoleDebug("FATAL UI ERROR, HOW COME CONV IS NOT HERE?!!");
            appWindow.quitInit();
        }

        conversation.unreadCount=messages.conversation.unreadCount?messages.conversation.unreadCount:0;
        conversation.remainingMessagesCount = messages.conversation.remainingMessagesCount;

        consoleDebug("Adding messages to conv")
        for (var i =0; i< messages.data.length; i++)
        {
            //consoleDebug("adding message: " + messages.data[i].content );
            conversation.addMessage(messages.data[i]);
        }

        if(appWindow.getActiveConversation()==messages.jid){
            //to reset unreadCount in frontend and inform backend about
            conversation.open();
        }

		if (reorder) reorderConversation(messages.jid)

		onPaused(messages.jid)

    }

	function checkUnreadMessages() {
		var num = 0
        for(var i =0; i<conversationsModel.count; i++) {
			var nconv = conversationsModel.get(i).conversation.unreadCount
			num = num + (nconv? nconv : 0)
		}
		unreadChatMessages.title = num.toString() 
	}

    function onLastSeenUpdated(jid,seconds){

        var conversation = waChats.getConversation(jid);

        if(conversation){
            if(seconds)
                conversation.setOffline(seconds);
            else
                conversation.setOffline();
        }
    }

    function onAvailable(jid){
        var conversation = waChats.getConversation(jid);

        if(conversation){
            conversation.setOnline();
        }
    }

    function onUnavailable(jid){
        var conversation = waChats.getConversation(jid);

        if(conversation){
            conversation.setOffline();
        }
    }

	signal onTyping(string ujid)
    /*function onTyping(jid){
        var conversation = waChats.getConversation(jid);

        if(conversation){
            conversation.setTyping();
        }
    }*/

	signal onPaused(string ujid)
    /*function onPaused(jid){
        var conversation = waChats.getConversation(jid);

        if(conversation){
            conversation.setPaused();
        }
    }*/

    signal messageSent(int mid, string ujid)
    function onMessageSent(message_id,jid) {
        var conversation = waChats.getConversation(jid);

        if(conversation){
            conversation.messageSent(message_id);
        }
		messageSent(message_id,jid)
    }

    signal messageDelivered(int mid, string ujid)
    function onMessageDelivered(message_id,jid) {
        var conversation = waChats.getConversation(jid);

        if(conversation){
            conversation.messageDelivered(message_id);
        }
		messageDelivered(message_id,jid)
    }

        /**** Media ****/
   /* function onMediaTransferSuccess(jid,message_id,mediaObject){
        //consoleDebug("Caught media transfer success in main")
        //var conversation = waChats.getConversation(jid);

        //if(conversation)
            mediaTransferSuccess(jid,message_id,mediaObject);
    }

    function onMediaTransferError(jid,message_id,mediaObject){
        //consoleDebug("ERROR!! "+jid)
        //var conversation = waChats.getConversation(jid);

        //if(conversation)
            mediaTransferError(jid,message_id,mediaObject);
    }

    function onMediaTransferProgressUpdated(progress,jid,message_id){
        //consoleDebug("UPDATED PROGRESS "+progress + " for " + jid + " - message id: " + message_id)
        //var conversation = waChats.getConversation(jid);

        //if(conversation)
            mediaTransferProgressUpdated(progress,jid,message_id);
    }*/
        /************/


    /*****************************************/

    WAUpdate{
        id:updatePage
    }

    /*Settings{
        id:settingsPage
    }*/

	SendPicture {
		id:sendPicture
	}

	SendVideo {
		id:sendVideo
	}

	SendAudioRec {
		id:sendAudioRec
	}

	SendAudio {
		id:sendAudio
	}

	SendAudioFile {
		id:sendAudioFile
	}

	SelectPicture {
		id:setProfilePicture
	}

	SelectContacts {
		id: shareSyncContacts
	}

	AddContacts {
		id: addContacts
	}

    LoadingPage{
        id:loadingPage
    }

    ListModel{
		id:conversationsModel
	}

    ListModel{
        id:contactsModel
    }

    ListModel{
        id:phoneContactsModel
    }

	property string selectedContacts: ""
	ListModel {
		id: participantsModel
	}


	DocumentGalleryModel {
		id: galleryArtistModel
		rootType: DocumentGallery.Album
		properties: ["artist", "title"]
		sortProperties: ["artist", "title"]
		autoUpdate: true
	}


	property string filterAlbum
    DocumentGalleryModel {
        id: galleryAudioModel
        rootType: DocumentGallery.Audio
        properties: ["url", "fileName", "title", "artist", "duration"]
        sortProperties: ["+title"]
		autoUpdate: true
		filter: GalleryFilterIntersection {
            filters: [
                GalleryEqualsFilter {
                    property: "albumTitle"
                    value: filterAlbum.replace("'","\\'")
                }
            ]
		}
   }


    WAPage {
        id: mainPage;
        tools: mainTools

        TabGroup {
            id: tabGroups
            currentTab: waChats

            Chats{
                id:waChats
                height: parent.height
                onDeleteConversation: appWindow.deleteConversation(jid)
            }

            Contacts {
                id: waContacts
                height: parent.height
            }
        }

        ToolBarLayout {

            id:mainTools

            ToolIcon{
                iconSource: "common/images/icons/wazapp48.png"
                platformStyle: ToolButtonStyle{inverted: theme.inverted}
            }

            ButtonRow {
                style: TabButtonStyle { inverted:theme.inverted }

                TabButton {
					id: chatsTabButton
                    platformStyle: TabButtonStyle{inverted:theme.inverted}
                    //text: qsTr("Chats")
                    iconSource: "image://theme/icon-m-toolbar-new-chat" + (theme.inverted ? "-white" : "") 
                    tab: waChats
					CountBubble {
						id: unreadChatMessages
						anchors.right: parent.right
						anchors.rightMargin: 16
						y: -8 // Yes, I like it this way!
					}
                }
                TabButton {
					id: contactsTabButton
                    platformStyle: TabButtonStyle{inverted: theme.inverted}
                    //text: qsTr("Contacts")
                    iconSource: "common/images/book" + (theme.inverted ? "-white" : "") + ".png";
                    tab: waContacts
					CountBubble {
						id: contactsAdded
						anchors.right: parent.right
						anchors.rightMargin: 16
						y: -8 // Yes, I like it this way!
						title: newContacts
					}
                }
            }

            ToolIcon {
                platformStyle: ToolButtonStyle{inverted:theme.inverted}
                id:toolbar_menu_item
                platformIconId: "toolbar-view-menu"
				onClicked: (waMenu.status === DialogStatus.Closed) ? waMenu.open() : waMenu.close()
                //onClicked: { pageStack.push(settingsPage); }

            }
        }
    }

    WAMenu {
        id: waMenu

        Component.onCompleted: {
            waMenu.syncClicked.connect(onSyncClicked)
		}
    }

    QueryDialog {
        id: updateContacts
        titleText: qsTr("Update Contacts")
        message: qsTr("The Phone contacts database has changed. Do you want to sync contacts now?")
        acceptButtonText: qsTr("Yes")
        rejectButtonText: qsTr("No")
        onAccepted: { updateContactsOpenend = false; syncClicked(); }
    }

    QueryDialog {
        id: quitConfirm
        titleText: qsTr("Confirm Quit")
        message: qsTr("Are you sure you want to quit Wazapp?")
        acceptButtonText: qsTr("Yes")
        rejectButtonText: qsTr("No")
        onAccepted: quit();
    }

    QueryDialog {
        id:aboutDialog
        icon: "common/images/icons/wazapp80.png"
        titleText: "Wazapp" //This should not be translated!
        message: qsTr("version") + " " + waversion + "\n\n" + 
                 qsTr("This is a %1 version.").arg(waversiontype) + "\n" + 
				 qsTr("You are trying it at your own risk.") + "\n" + 
				 qsTr("Please report any bugs to") + "\n" + "tarek@wazapp.im"
 
    }

    QueryDialog {
        id: updateDialog
        property string version;
        property string link;
        property string changes;
        property string severity;

        titleText: qsTr("Wazapp %1 is now available for update!").arg(version)
        message: "Urgency:"+severity+"\nSummary:\n"+changes
        acceptButtonText: qsTr("Details")
        rejectButtonText: qsTr("Cancel")
        onAccepted: appWindow.pageStack.push(updatePage);
    }

}
