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


var contactsViews = new Array();

function Contact(jid){

    this.jid = jid;

    var tmp = jid.split('@');
    this.number = tmp[0];
    this.name = this.number;
    this.picture = defaultProfilePicture
    this.status = "";
	this.pushname = "";
	//this.newContact = false;
}


function populateContacts(contacts)
{

    console.log("Init contact populate from QML");
    var conversations = {}
    console.log("Gathering open conversations");
    var ccount = 0;
    for(var i=0; i<contactsViews.length; i++){

        var contact = contactsViews[i];
        var cConv = contact.getConversation();
        if(cConv){
            ccount++;
            conversations[cConv.jid]=cConv;
            cConv.removeContact(contact);
        }
    }

    console.log("Gathered conversations before clearing: "+ccount);
    breathe()

    contactsModel.clear();
    contactsViews = new Array();
    console.log("cleared");
    if(contacts.length > 0)
        contactsContainer.state=""

    console.log("Populating contacts of amount: "+contacts.length);

    if(!initializationDone) {
		splashPage.resetProgress()
		splashPage.setProgressMax(contacts.length)
	}

    for(var i =0; i<contacts.length; i++)
    {
		//console.log("APPENDING CONTACT: " + contacts[i].jid + " - " + contacts[i].name)
		//contacts[i].newContact = false;
        contactsModel.append(contacts[i]);

        if(!initializationDone){
            splashPage.setSubOperation(contacts[i].jid)
            splashPage.setProgress(i)
            breathe()
         }
        else if(i%4 == 0) {
            breathe();
        }

        var cachedConv =   conversations[contacts[i].jid];
        if(cachedConv){
            console.log("Rebinding existing conv");
            console.log(cachedConv);
            console.log(contactsViews[i]);
            cachedConv.addContact(contactsViews[i]);
            contactsViews[i].setConversation(cachedConv);
        }
    }
    console.log("Populating done!");
}
