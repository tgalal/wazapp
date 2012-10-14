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
import com.nokia.extras 1.0

import "Chats"
import "common"
import "Contacts"
import "Menu"
import "Updater"
import "Settings"
import "Conversations"
import "Profile"
import "Groups"
import "Misc"
import "common/js/settings.js" as MySettings

//import com.nokia.extras 1.0

WAStackWindow {
    id: appWindow
    initialPage: mainPage //splashPage//mainPage
    showStatusBar: initializationDone && !(screen.currentOrientation == Screen.Landscape && activeConvJId!="")
    showToolBar: initializationDone && !dialogOpened

    toolBarPlatformStyle:ToolBarStyle{
        inverted: theme.inverted
    }

    Component.onCompleted: {
        pageStack.push(splashPage,{},true)

        MySettings.initialize()
        theme.inverted = MySettings.getSetting("ThemeColor", "White")=="Black"
        mainBubbleColor = parseInt(MySettings.getSetting("BubbleColor", "1"))
        sendWithEnterKey = MySettings.getSetting("SendWithEnterKey", "Yes")=="Yes"
        resizeImages = MySettings.getSetting("ResizeImages", "Yes")=="Yes"
        orientation = parseInt(MySettings.getSetting("Orientation", "0"))
        vibraForPersonal = MySettings.getSetting("PersonalVibrate", "Yes")
        vibraForGroup = MySettings.getSetting("GroupVibrate", "Yes")
        personalRingtone = MySettings.getSetting("PersonalRingtone", "/usr/share/sounds/ring-tones/Message 1.mp3")
        groupRingtone = MySettings.getSetting("GroupRingtone", "/usr/share/sounds/ring-tones/Message 1.mp3")
        myBackgroundImage = MySettings.getSetting("Background", "none")
        myBackgroundOpacity = MySettings.getSetting("BackgroundOpacity", "5")
        setBackground(myBackgroundImage)
    }

    property string waversiontype:waversion.split('.').length == 4?'developer':'beta'
    property string activeConvJId:""
    property string profileUser//@@THIS IS FUCKING RETARDED!!!!!!!!
    property bool updateSingleStatus: false
    property bool dialogOpened: false
    property int mainBubbleColor
    property bool sendWithEnterKey
    property bool resizeImages
    //property string selectedPicture//@@THIS IS FUCKING RETARDED!!!!!!!!
    property string selectedContactName: ""//@@THIS IS FUCKING RETARDED!!!!!!!!
    //property string selectedGroupPicture//@@THIS IS FUCKING RETARDED!!!!!!!!
    //property string bigProfileImage //@@THIS IS FUCKING RETARDED!!!!!!!!
    property int orientation
    property string personalRingtone
    property string groupRingtone
    property string vibraForPersonal
    property string vibraForGroup
    property bool initializationDone: false
    property string currentSelectionProfile//@@THIS IS FUCKING RETARDED!!!!!!!!
    property string currentSelectionProfileValue//@@THIS IS FUCKING RETARDED!!!!!!!!
    property string myBackgroundImage
    property int myBackgroundOpacity

    property string currentProfilePicture: currentPicture;
    property string currentStatus:MySettings.getSetting("Status", "Hi there I'm using Wazapp")
    property string defaultProfilePicture: "common/images/user.png"
    property string defaultGroupPicture: "common/images/group.png"

    /****** Signal and Slot definitions *******/

    signal setLanguage(string lang);
    signal consoleDebug(string text);

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
    signal endGroupChat(string gjid);
    signal groupEnded();
    signal setGroupSubject(string gjid, string subject);
    signal getPictureIds(string jids);
    signal getPicture(string jid);
    signal onContactPictureUpdated(string ujid);
    signal setGroupPicture(string jid, string file);
    signal setMyProfilePicture(string file);
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
    signal exportConversation(string jid);
    signal breathe()
    signal playSoundFile(string soundfile);
    signal stopSoundFile();


    signal openContactPicker(string multi, string title); //TESTING...
    signal setBlockedContacts(string contacts);
    signal setResizeImages(bool resize);
    signal openCamera(string jid, string mode);
    signal setPersonalRingtone(string value);
    signal setPersonalVibrate(bool value);
    signal setGroupRingtone(string value);
    signal setGroupVibrate(bool value);
    signal vibrateNow();

    signal setRingtone(string ringtonevalue);
    signal setBackground(string backgroundimg);


    signal openPreviewPicture(string ujid, string picturefile, int rotation, string previewimg, string capturemode)
    function capturedPreviewPicture(ujid, picturefile, rotation, previewimg, capturemode) {
        openPreviewPicture(ujid, picturefile, rotation, previewimg, capturemode)
    }

    signal mediaTransferProgressUpdated(int mprogress, int mid) //@@THIS IS FUCKING RETARDED!!!!!!!!
    signal mediaTransferSuccess(int mid, string filepath)//@@THIS IS FUCKING RETARDED!!!!!!!!
    signal mediaTransferError(int mid)//@@THIS IS FUCKING RETARDED!!!!!!!!

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
        consoleDebug("Pushing ringtones")
        ringtoneModel.clear()
        var nosound = qsTr("(no sound)")
        var browse = qsTr("Browse")
        ringtoneModel.append({ name: browse, value: "browse"})
        ringtoneModel.append({ name: nosound, value: "/usr/share/sounds/ring-tones/No sound.wav"})
        for (var i=0; i<files.length; ++i) {
            ringtoneModel.append(files[i])
        }
        ringtonesUpdated();
    }


    signal browseFiles(string folder, string format);
    signal browserUpdated();
    signal customRingtoneSelected();
    property bool enableBackInBrowser
    property string currentBrowserFolder

    ListModel {
        id: browserModel
    }
    function pushBrowserFiles(files, folder) {
        browserModel.clear()
        enableBackInBrowser = folder!="/home/user/MyDocs"
        currentBrowserFolder = folder
        for (var i=0; i<files.length; ++i) {
            browserModel.append(files[i])
        }
        browserUpdated();
    }



    signal groupCreated(string group_id)

    function onRemovedParticipants() {
        removedParticipants()
    }

    signal profilePictureUpdated()

    function onPictureUpdated(jid) {

        if(jid == myAccount) {
            var path = WAConstants.CACHE_CONTACTS + "/" + myAccount.split("@")[0] + ".jpg";
            currentProfilePicture=""
            currentProfilePicture = path

            profilePictureUpdated()
        } else {

            var isGroup =  jid.indexOf("-") != -1
            var conversation = isGroup?waChats.getOrCreateConversation(jid):waChats.findConversation(jid)

            if(!isGroup) {
                  consoleDebug("getting contacts")
                var contacts = getContacts();
                consoleDebug("Looking for right contact to update")
                for(var i=0; i<contacts.count; i++){
                    var c = contacts.get(i);
                    if(c.jid == jid){
                        consoleDebug("Updating contact picture now")
                        c.picture = ""
                        c.picture = WAConstants.CACHE_CONTACTS + "/" + jid.split("@")[0] + ".jpg";
                    }
                }
            }

            if(conversation){
                conversation.picture = ""
                conversation.onChange();
                conversation.picture = conversation.getPicture();
                conversation.onChange();
            }
        }
    }

    //property string groupParticipantsIds
    function onGroupParticipants(jid, jids) {
        //groupParticipantsIds = jids
        //groupParticipants()

        console.log("GOT GROUP PARTICIPANTS FOR "+jid)
        var conversation = waChats.getOrCreateConversation(jid);
        console.log("GOT CONV, now pushing")
        conversation.pushParticipants(jids)

    }

    function onGroupEnded() {
        groupEnded()
    }

    function onGroupInfoUpdated(jid, data) {
        consoleDebug("SHOULD PUSH GROUP INFO TO "+jid)
        var conversation = waChats.getOrCreateConversation(jid);
        conversation.pushGroupInfo(data);
        conversation.onChange();

    }
    function onGroupSubjectChanged(gJid) {
        getGroupInfo(gJid); //@@TODO, in case I changed group subject, why re-fetch everything?!
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

    function showNotification(text){
        osd_notify.parent = pageStack.currentPage
        osd_notify.text = text
        osd_notify.show();
    }

    function setSplashOperation(op) {
        splashPage.setCurrentOperation(op)
    }

    function onInitDone(){
        initializationDone = true
        pageStack.pop(mainPage,true)
        //pageStack.replace(mainPage)
    }


    function onConversationExported(jid, path){
        consoleDebug(jid+":::"+path)
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


    function setMyAccount(account) { //@@TODO purge!
        myAccount = account
        blockedContacts = MySettings.getSetting("BlockedContacts", "")
        setBlockedContacts(blockedContacts)

        resizeImages = MySettings.getSetting("ResizeImages", "Yes")=="Yes" ? true : false
        setResizeImages(resizeImages)

        setPersonalRingtone(MySettings.getSetting("PersonalRingtone", "/usr/share/sounds/ring-tones/Message 1.mp3"));
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
        newc = newc.replace(/,,/g,",")
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



    function getContacts(){

        return contactsModel;
    }

    function getGroups(){

        consoleDebug("Getting groups")
        var convs = getConversations();
        consoleDebug(convs)
        var modelData = Qt.createQmlObject("import QtQuick 1.0; ListModel{}", appWindow, "groupsModel")

        for(var i=0; i < convs.count; i++) {

            var conv = convs.get(i).conversation;
            consoleDebug(conv);
            consoleDebug(conv.isGroup());

            if(conv.isGroup()) {

                consoleDebug("Appending")

                modelData.append({name:conv.title, picture:conv.picture, jid:conv.jid})
                consoleDebug("Pass")

            }

        }

        consoleDebug("Returning")
        consoleDebug(modelData.length);

        return modelData;

    }


    function getConversations(){

        return conversationsModel;
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


    signal phoneContactsReady()
    function pushPhoneContacts(contacts){
        phoneContactsModel.clear()
        consoleDebug("APPENDING PHONE CONTACTS:" + contacts.length)

        var tmpModelData = new Array
        for (var i=0; i<contacts.length; i++) {
           //phoneContactsModel.insert(phoneContactsModel.count,{"name":contacts[i][0] || contacts[i][2].toString(), "picture":contacts[i][1],
            // "numbers":contacts[i][2].toString(), "selected":false})

            tmpModelData.push({"name":contacts[i][0] || contacts[i][2].toString(), "picture":contacts[i][1],
                                                            "numbers":contacts[i][2].toString(), "selected":false})
        }

        breathe()

        modelworker.sendMessage({"model":phoneContactsModel,"data":tmpModelData})

    }

    WorkerScript{
        id:modelworker
        source: "common/js/modelworker.js"
        onMessage: {
            console.log("EMITING READY")
            phoneContactsReady()
            console.log("EMIT")
        }
    }

    signal profileStatusChanged()
    function onProfileStatusChanged(){
        profileStatusChanged()
        currentStatus = MySettings.getSetting("Status", "")
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
        dialogOpened = false
        var conversation = waChats.getOrCreateConversation(jid);
        conversation.open();
    }


    /****Conversation related slots****/

    function conversationReady(conv){
        //This should be called if and only if conversation start point is backend
        consoleDebug("Got a conv in conversationReady slot: " + conv.jid);


        if(!initializationDone)
            splashPage.setSubOperation(conv.jid)

        breathe()
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

    signal reorderConversation(string cjid) //@@THIS IS FUCKING RETARDED!!!!!!!!
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

        if (reorder) reorderConversation(messages.jid)//wtf?

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

    signal onTyping(string ujid)//@@THIS IS FUCKING RETARDED!!!!!!!!
    /*function onTyping(jid){
        var conversation = waChats.getConversation(jid);

        if(conversation){
            conversation.setTyping();
        }
    }*/

    signal onPaused(string ujid) //@@THIS IS FUCKING RETARDED!!!!!!!!
    /*function onPaused(jid){
        var conversation = waChats.getConversation(jid);

        if(conversation){
            conversation.setPaused();
        }
    }*/

    signal messageSent(int mid, string ujid)//@@THIS IS THE MOST FUCKING RETARDED THING I'VE EVER SEEN!!!!!!!!
    function onMessageSent(message_id,jid) {
        var conversation = waChats.getConversation(jid);

        if(conversation){
            conversation.messageSent(message_id);
        }
        messageSent(message_id,jid)
    }

    signal messageDelivered(int mid, string ujid)  //@@THIS IS THE MOST FUCKING RETARDED THING I'VE EVER SEEN!!!!!!!!
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

    WASplash{
        id:splashPage
    }


    WAUpdate{
        id:updatePage
    }

    SettingsNew{
        id:settingsPage
    }

    SyncedContactsList{
        id: genericSyncedContactsSelector
    }

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

    SelectContacts {
        id: shareSyncContacts
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
    /*ListModel {
        id: participantsModel
    }*/


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

        InfoBanner {
            id:osd_notify
            topMargin: 10
           // iconSource: "system_banner_thumbnail.png"
            timerEnabled: true
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
