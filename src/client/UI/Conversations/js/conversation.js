var conversation=false;
var contacts = new Array();
var observers = new Array();

function getContact(contactJid){

    var index = getContactIndex(contactJid);
    if(index > -1) {
        return contacts[index];
    }

    return false;
}

function getContactIndex(contactJid) {

    for(var i=0;i<contacts.length;i++){

        if(contacts[i].jid == contactJid){
            return i;
        }
    }

    return -1
}
