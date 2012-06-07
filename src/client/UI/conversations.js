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

function getChatData() {
   // addMessage("Hello there!",true,"10:00am");
   // addMessage("Hey!!",false,"10:00am");
}

//function addMessage(id,message,type,formattedDate,timestamp,status)
function addMessage(message)
{
    var msg_status = message.status == 0?"sending":message.status==1?"pending":"delivered";

    var author = message.contact;


    conv_data.insert(conv_data.count,{"msg_id":message.id,
                                        "message":message.content,
                                        "type":message.type,
                                        "timestamp":message.formattedDate,
                                        "status":msg_status,
                                        "author":author,
                                        "mediatype_id":message.media_id?message.media.mediatype_id:1,
                                        "media":message.media,
                                        "progress":0})

    //conv_data.append({"msg_id":id,"message":message,"type":type, "timestamp":timestamp,"status":msg_status});
     conv_items.positionViewAtEnd()
    // conversation_view.conversationUpdated(id,type,conversation_view.user_id,message,timestamp,formattedDate);
     conversation_view.conversationUpdated(message);
}

function onTyping(user_id){
    status.text="Typing...";
}

function onPaused(user_id){
    status.text="";
}

/*
function receive(message)
{



    console.log("IN REC");
    var time = "10:02am"

    addMessage(message.id, message.content,message.type,message.timestamp);


}

function send(){
    if (chat_text.text.trim() == "")
        return;

    var tmp = chat_text.text;
     addMessage(chat_text.text,1,"10:01am");
     chat_text.text=""

    return tmp;
}
*/
