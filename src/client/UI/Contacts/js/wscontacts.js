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

import "js/contacts.js" as ContactsManager

WorkerScript.onMessage = function(mycontacts) {
	consoleDebug("WORKER SCRIPT FOR CONTACTS: " + parseInt(mycontacts.length))

	for(var i=0; i<mycontacts.length; i++) {
		consoleDebug("CHECKING CONTACT: " + mycontacts[i].name)

		/*var udpate = "false"
		for(var j=0; j<contactsModel.count; j++) {
			if (contactsModel.get(j).jid==mycontacts[i].jid) {
				consoleDebug("UPDATING CONTACT: " + mycontacts[i].name)
				contactsModel.get(j) = mycontacts[i]
				updateContactName(mycontacts[i].jid,mycontacts[i].name)
				update = "true"
				break
			}
		}
		if (udpate == "false") {
			consoleDebug("ADDING CONTACT: " + mycontacts[i].name)
			contactsModel.insert(i, mycontacts[i]);
			updateContactName(mycontacts[i].jid,mycontacts[i].name)
		}*/
	}
}

