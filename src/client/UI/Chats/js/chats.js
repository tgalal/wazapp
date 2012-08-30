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


function moveToCorrectIndex(jid){
    /*
        Triggered when lastMessage is updated.
        It moves the chat item with jid to correct position according to lastMessage created time
     */
    //console.log("---/.[[][][][][][][][][][][][][][][][][][][][][][][][][][][]]");
    //console.log("SORTING")
    var index=0;
    var chatItem;
    for (var i=0; i< conversationsModel.count;i++)
    {
        chatItem = conversationsModel.get(i);

        if(chatItem.conversation.jid == jid){
            index = i;
            break;
         }
    }
    //console.log("go the object and its index at"+index)

    var lastMessage = chatItem.conversation.lastMessage;
     //got the object and its index

    if(index ==0) //it's already on top
        return

    //now rescan to find the correct slot

    var targetIndex = index;

    //console.log("rescanning")

    for (var i=0; i<index;i++) //we won't be moving lower than that
    {
        var  compItem = conversationsModel.get(i).conversation.lastMessage;
        //console.log(compItem);

        if(compItem && lastMessage.created > compItem.created){
            //console.log("found target at "+i);
             targetIndex = i;
             break
        }
    }
    //console.log("moving")
    //console.log(conversationsModel.count);
    //console.log(index);
    //console.log(targetIndex);
    conversationsModel.move(index,targetIndex,1);
    //console.log("MOVED!!")
}
