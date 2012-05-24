/***************************************************************************
**
** Copyright (c) 2012, Tarek Galal <tarek@wazapp.im>
**
** This file is part of Wazapp, an IM application for Meego Harmattan
** platform that allows communication with Whatsapp users.
**
** Wazapp is free software: you can redistribute it and/or modify it under
** the terms of the GNU General Public License as published by the
** Free Software Foundation, either version 3 of the License, or
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
var conv = "Conversation.qml";
var component = Qt.createComponent(conv);
var chats = new Array();


var contacts = new Array();





function findContact(user_id)
{
   return getContactData(user_id);
}

function getContactData(user_id)
{
    for(var i =0; i<contacts.length; i++)
    {
        if(contacts[i].jid == user_id)
            return contacts[i]
    }

    return {name:user_id.split('@')[0],picture:"pics/user.png",jid:user_id}

}

function populateContacts()
{
    contactsModel.clear();
    if(contacts.length > 0)
        contactsContainer.state=""
    for(var i =0; i<contacts.length; i++)
    {
        if(contacts[i].picture == "none")
        {
            contacts[i].picture="pics/user.png"
            contacts[i].hasPicture = false;
        }
        else
            contacts[i].hasPicture = true;
        contactsModel.append(contacts[i]);


    }
}

function getChatWindow(user_id)
{
    for(var i =0; i<chats.length; i++)
    {
        if(chats[i].user_id == user_id)
            return chats[i];

    }

    return 0;
}

function hello(data)
{
    console.log("test");
}

function createChatWindow(user_id,user_name,user_picture)
{
    if(component.status == Component.Ready){
        var dynamicObject = component.createObject(appWindow);
        if(dynamicObject == null){
            console.log("error creating block");
            console.log(component.errorString());

            return false;
        }

       // dynamicObject.anchors.fill = contactsContainer

        //dynamicObject.z=1
        dynamicObject.user_name = user_name
        dynamicObject.user_id = user_id
        dynamicObject.user_picture = user_picture
        dynamicObject.conversationUpdated.connect(contactsContainer.conversationUpdated)
        dynamicObject.sendMessage.connect(contactsContainer.sendMessage);
        dynamicObject.typing.connect(contactsContainer.sendTyping);
        dynamicObject.paused.connect(contactsContainer.sendPaused);

      //  dynamicObject.newMessage.connect(test)


        //dynamicObject.onNewMessage = function(t){console.log("TESSTTT");}

        chats.push({user_id:user_id,user_name:user_name,"conversation":dynamicObject})
        //dynamicObject.visible=false


        //return dynamicObject;
        return chats[chats.length-1];

    }else{
        console.log("error loading block component");
        console.log(component.errorString());
        return false;
    }

}

function openChatWindow(user_id,prev_state){

    var chatWindow = getChatWindow(user_id);

    if(chatWindow==0)
    {
        var contact = getContactData(user_id);
        chatWindow = createChatWindow(user_id,contact.name,contact.picture)

     }


     chatWindow.prev_state=prev_state
     chatWindow.conversation.visible =true;
}
