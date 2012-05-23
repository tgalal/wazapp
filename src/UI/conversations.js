

function getChatData() {
   // addMessage("Hello there!",true,"10:00am");
   // addMessage("Hey!!",false,"10:00am");
}

//function addMessage(id,message,type,formattedDate,timestamp,status)
function addMessage(message)
{
    var msg_status = message.status == 0?"sending":message.status==1?"pending":"delivered";



    conv_data.insert(conv_data.count,{"msg_id":message.id,"message":message.content,"type":message.type, "timestamp":message.formattedDate,"status":msg_status})
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
