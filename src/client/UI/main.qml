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

import "Chats"
import "common"
import "Contacts"
import "Menu"
import "Updater"
import "Settings"

//import com.nokia.extras 1.0

WAStackWindow {
    id: appWindow
    initialPage: mainPage  
    showStatusBar: !(screen.currentOrientation == Screen.Landscape && activeConvJId!="")

    toolBarPlatformStyle:ToolBarStyle{
        inverted: theme.inverted
    }

    Component.onCompleted: {theme.inverted = true;}
    property string waversiontype:waversion.split('.').length == 4?'developer':'beta'
    property string activeConvJId:""

    /****** Signal and Slot definitions *******/

    signal changeStatus(string new_status)
    signal sendMessage(string jid, string msg);
    signal requestPresence(string jid);
    signal refreshContacts();
    signal sendTyping(string jid);
    signal sendPaused(string jid);
    signal quit()
    signal deleteConversation(string jid);
    signal deleteMessage(string jid, int msg_id);
    signal conversationActive(string jid);
    signal fetchMedia(int id);
    signal fetchGroupMedia(int id);
    signal loadMessages(string jid, int offsetId, int limit);
    signal conversationOpened(string jid);
    //prevent double opened, sometimes QContactsManager sends more than 1 signal
    property bool updateContactsOpenend: false

            /******************/
    function onConnected(){setIndicatorState("online")}
    function onConnecting(){setIndicatorState("connecting")}
    function onDisconnected(){setIndicatorState("connecting")}
    function onSleeping(){setIndicatorState("offline")}
    function onLoginFailed(){setIndicatorState("reregister")}

    function appFocusChanged(focus){
        var user_id = getActiveConversation()
        if (user_id){
            conversationActive(user_id);
        }
    }

    function setActiveConv(activeJid){
        console.log("SETTING ACTIVE CONV "+activeJid)
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


	function onContactsChanged() {

        /*@@TODO: invalid way and should be removed. When a contact changes, only that changed contact should be synced silently
                and UI gets updated silently as well.**/
		if (updateContactsOpenend==false) {
		console.log("CONTACTS CHANGED!!!");
			updateContactsOpenend = true
			//updateContacts.open()  UI crashes with this, needs more work
		}
	}	

    function onSyncClicked(){
        tabGroups.currentTab=waContacts;
        //loadingPage.operation="Refreshing Contacts"
        appWindow.pageStack.push(loadingPage);
        refreshContacts();
    }

    function onRefreshSuccess(){
        appWindow.pageStack.pop();
    }

    function onRefreshFail(){
        appWindow.pageStack.pop();
    }

    function setIndicatorState(indicatorState){
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

    function pushContacts(contacts){
        waContacts.pushContacts(contacts)
    }

    function onContactsSyncStatusChanged(state) {
        /*UNCOMMENTME: SETTING TO STATE OF MAIN?! WTF?!!!!!!!!!!!!! */
        if (state=="GETTING") loadingPage.operation = qsTr("Retrieving contacts list...")
        else if (state=="SENDING") loadingPage.operation = qsTr("Fetching contacts...")
        else if (state=="LOADING") loadingPage.operation = qsTr("Loading contacts...")
        else loadingPage.operation = ""
    }

    function openConversation(jid){
          console.log("should open chat window with "+jid)

          var conversation = waChats.getOrCreateConversation(jid);
          conversation.open();
     }


    /****Conversation related slots****/

    function conversationReady(conv){
        //This should be called if and only if conversation start point is backend
        console.log("Got a conv in conversationReady slot");
        var conversation = waChats.getOrCreateConversation(conv.jid);
        console.log("Finding appropriate contact");
        var contact = waContacts.getOrCreateContact({jid:conv.jid});

        console.log("Adding to conversation");
        conversation.addContact(contact);

        console.log("Binding conversation to contact");
        contact.setConversation(conversation);


    }

    function messagesReady(messages){
        console.log("GOT MESSAGES SIGNAL");
        var conversation = waChats.getConversation(messages.jid);
        console.log("proceed to check validity of conv")
        if(!conversation){
            console.log("FATAL UI ERROR, HOW COME CONV IS NOT HERE?!!");
            appWindow.quitInit();
        }

        conversation.unreadCount=messages.conversation.unreadCount;
        conversation.remainingMessagesCount = messages.conversation.remainingMessagesCount;

        console.log("Adding messages to conv")
        for (var i =0; i< messages.data.length; i++)
        {
            console.log("adding a message");
            conversation.addMessage(messages.data[i]);
        }

        if(appWindow.getActiveConversation()==messages.jid){
            //to reset unreadCount in frontend and inform backend about
            conversation.open();
        }
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

    function onTyping(jid){
        var conversation = waChats.getConversation(jid);

        if(conversation){
            conversation.setTyping();
        }
    }

    function onPaused(jid){
        var conversation = waChats.getConversation(jid);

        if(conversation){
            conversation.setPaused();
        }
    }

    function onMessageSent(message_id,jid){
        var conversation = waChats.getConversation(jid);

        if(conversation){
            conversation.messageSent(message_id);
        }
    }

    function onMessageDelivered(message_id,jid){
        var conversation = waChats.getConversation(jid);

        if(conversation){
            conversation.messageDelivered(message_id);
        }
    }

        /**** Media ****/
    function onMediaTransferSuccess(jid,message_id,mediaObject){
        console.log("Caught media transfer success in main")
        var conversation = waChats.getConversation(jid);

        if(conversation)
            conversation.mediaTransferSuccess(message_id,mediaObject);
    }

    function onMediaTransferError(jid,message_id,mediaObject){
        console.log("ERROR!! "+jid)
        var conversation = waChats.getConversation(jid);

        if(conversation)
            conversation.mediaTransferError(message_id,mediaObject);
    }

    function onMediaTransferProgressUpdated(progress,jid,message_id){
        console.log("UPDATED PROGRESS "+progress)
        var conversation = waChats.getConversation(jid);

        if(conversation)
            conversation.mediaTransferProgressUpdated(progress,message_id);
    }
        /************/


    /*****************************************/

    WAUpdate{
        id:updatePage
    }

    Settings{
        id:settingsPage;
    }

    LoadingPage{
        id:loadingPage
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
                onDeleteConversation: appWindow.deleteConversation(jid);
            }

            Contacts{
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
                    text: qsTr("Chats")
                    //iconSource: "../images/icon-m-toolbar-home.png"
                    tab: waChats
                }
                TabButton {
                    platformStyle: TabButtonStyle{inverted: theme.inverted}
                    text: qsTr("Contacts")
                    // iconSource: "../images/icon-m-toolbar-list.png"
                    tab: waContacts
                }
            }

            ToolIcon {
                platformStyle: ToolButtonStyle{inverted:theme.inverted}
                id:toolbar_menu_item
                platformIconId: "toolbar-settings"

                onClicked: { pageStack.push(settingsPage); }

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
