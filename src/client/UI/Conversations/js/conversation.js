var conversation=false;
var contacts = new Array();
var observers = new Array();

function getContact(contactJid){
    for(var i=0;i<contacts.length;i++){

        if(contacts[i].jid == contactJid){
            return contacts[i]
        }
    }

    return false;
}
