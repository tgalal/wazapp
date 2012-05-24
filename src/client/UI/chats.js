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
var chats = []
function importChats() {


    for(var i =0; i<chats.length; i++)
    {
        chatsModel.append(chats[i]);

    }
    
}

//function updateChats(msgId, msgType, number,lastMsg,time,formattedDate){
function updateChats(message){

    //console.log("UPDAING CONV "+number +" ::: "+formattedDate)
    var found = false;
    for (var i=0; i<chatsModel.count;i++)
    {
        var chatItem = chatsModel.get(i);

        if(chatItem.jid == message.jid)
        {

            chatsModel.remove(i);

            break

         }
    }

    var targetIndex = chatsModel.count;
    for (var i=0; i<chatsModel.count;i++)
    {
        var  compItem = chatsModel.get(i);

        if(message.timestamp > compItem.timestamp){
             targetIndex = i;
             break
        }


    }


    //{msgId:msgId,msgType:msgType,number:number, lastMsg:lastMsg, time:time, formattedDate:formattedDate}
    chatsModel.insert(targetIndex,message);
   // chatsModel.insert(targetIndex,{msgId:message.id,msgType:message.type,number:message.jid, lastMsg:message.content, time:message.timestamp, formattedDate:message.formattedDate})
   // chatsModel.sync();
}

