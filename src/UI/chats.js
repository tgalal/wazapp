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

