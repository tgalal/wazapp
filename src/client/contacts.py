'''
Copyright (c) 2012, Tarek Galal <tarek@wazapp.im>

This file is part of Wazapp, an IM application for Meego Harmattan platform that
allows communication with Whatsapp users

Wazapp is free software: you can redistribute it and/or modify it under the 
terms of the GNU General Public License as published by the Free Software 
Foundation, either version 2 of the License, or (at your option) any later 
version.

Wazapp is distributed in the hope that it will be useful, but WITHOUT ANY 
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A 
PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with 
Wazapp. If not, see http://www.gnu.org/licenses/.
'''
import os
from PySide.QtGui import *
from utilities import Utilities
from warequest import WARequest
from xml.dom import minidom
from PySide.QtCore import QObject
from PySide.QtCore import QUrl
from PySide.QtCore import Qt
from PySide.QtGui import QImage
from PySide import QtCore;
from QtMobility.Contacts import *
from litestore import LiteStore as DataStore
from xml.dom import minidom
from Models.contact import Contact
from constants import WAConstants
import thread
from wadebug import WADebug;
import sys

class ContactsSyncer(WARequest):
	'''
	Interfaces with whatsapp contacts server to get contact list
	'''
	contactsRefreshSuccess = QtCore.Signal();
	contactsRefreshFail = QtCore.Signal();
	contactsSyncStatus = QtCore.Signal(str);

	def __init__(self,store):
		WADebug.attach(self);
		self.store = store;
		self.base_url = "sro.whatsapp.net";
		self.req_file = "/client/iphone/bbq.php";
		super(ContactsSyncer,self).__init__();

	def sync(self):
		self._d("INITiATING SYNC")
		self.contactsSyncStatus.emit("GETTING");
		cm = ContactsManager();
		phoneContacts = cm.getContacts();

		for c in phoneContacts:
			self.addParam("u[]",c['number'])

		self.addParam("me",self.store.account.phoneNumber);
		self.addParam("cc",self.store.account.cc)

		self.contactsSyncStatus.emit("SENDING");
		data = self.sendRequest();
		
		if data:
			self.updateContacts(data);
		else:
			self.contactsRefreshFail.emit();
		
		self.exit();
		
		
	def updateContacts(self,data):
		#data = str(data);
		data =minidom.parseString(data);
		contacts  = data.getElementsByTagName("s");
		for c in contacts:
			self.contactsSyncStatus.emit("LOADING");
			contactObj = self.store.Contact.create();
			is_valid = False;

			for (name, value) in c.attributes.items():
				if name == "p":
					contactObj.number = value
				elif name == "jid":
					contactObj.jid = value
				elif name == "t":
					is_valid = True

			if is_valid:
				contactObj.status = c.firstChild.data.encode('utf-8') if c.firstChild is not None else ""
				matchingContact =  self.store.Contact.findFirst({"jid":contactObj.jid});
				contactObj.id = matchingContact.id if matchingContact else 0;
				contactObj.save();
				
		self.contactsRefreshSuccess.emit();
		
	def onRefreshing(self):
		self.start();

	def run(self):
		try:
			self.sync();
		except:
			self._d(sys.exc_info()[1])
			self.contactsRefreshFail.emit()
		#self.exec_();

class WAContacts(QObject):

	refreshing = QtCore.Signal();
	contactsRefreshed = QtCore.Signal();
	contactsRefreshFailed = QtCore.Signal();
	contactsSyncStatusChanged = QtCore.Signal(str);

	def __init__(self,store):
		super(WAContacts,self).__init__();
		self.store = store;
		self.contacts = [];
		self.raw_contacts = None;
		self.manager = ContactsManager();
		
		
	
	def initiateSyncer(self):
		self.syncer = ContactsSyncer(self.store);
		#self.syncer.done.connect(self.syncer.updateContacts);
		self.syncer.contactsRefreshSuccess.connect(self.contactsRefreshed);
		self.syncer.contactsRefreshFail.connect(self.contactsRefreshFailed);
		self.syncer.contactsSyncStatus.connect(self.contactsSyncStatusChanged);

	def resync(self):
		self.initiateSyncer();
		self.refreshing.emit();
		self.syncer.start();
		

	
	def getContacts(self):
		contacts = self.store.Contact.fetchAll();
		if len(contacts) == 0:
			#print "RESYNCING";
			#self.resync();
			return contacts;		
		#O(n2) matching, need to change that
		cm = self.manager
		phoneContacts = cm.getContacts();
		tmp = []
		self.contacts = {};
		
		if not os.path.exists("/home/user/.cache/wazapp/contacts"):
			os.makedirs("/home/user/.cache/wazapp/contacts")

		for wc in contacts:
			for c in phoneContacts:
				if wc.number == c['number']:
					#@@TODO cache to enhance startup
					user_img = QImage(QUrl(c['picture']).toString().replace("file://",""))
					mask_img = QImage("/opt/waxmppplugin/bin/wazapp/UI/common/images/usermask.png")
					preimg = QPixmap.fromImage(QImage(user_img.scaled(96, 96, Qt.KeepAspectRatioByExpanding, Qt.SmoothTransformation)));
					PixmapToBeMasked = QImage(96, 96, QImage.Format_ARGB32_Premultiplied);
					Mask = QPixmap.fromImage(mask_img);
					Painter = QPainter(PixmapToBeMasked);
					Painter.drawPixmap(0, 0, 96, 96, preimg);
					Painter.setCompositionMode(QPainter.CompositionMode_DestinationIn);
					Painter.drawPixmap(0, 0, 96, 96, Mask);
					Painter.end()
					PixmapToBeMasked.save("/home/user/.cache/wazapp/contacts/" + c['name'] + ".png", "PNG")
					c['picture'] = "/home/user/.cache/wazapp/contacts/" + c['name'] + ".png";

					wc.setRealTimeData(c['name'],c['picture']);
					if wc.status is not None:
						wc.status = wc.status.decode('utf-8');
					#tmp.append(wc.toModel());
					tmp.append(wc.getModelData());
					self.contacts[wc.number] = wc;
					break;
					
		self.store.cacheContacts(self.contacts);
		return sorted(tmp, key=lambda k: k['name'].upper()) ;


class ContactsManager(QObject):
	'''
	Provides access to phone's contacts manager API
	'''
	def __init__(self):
		super(ContactsManager,self).__init__();
		self.manager = QContactManager(self);
		self.contacts = []

	def getContacts(self):
		'''
		Gets all phone contacts
		'''
		contacts = self.manager.contacts();
		self.contacts = []
		for contact in contacts:
			avatars = contact.details(QContactAvatar.DefinitionName);
			avatar = QContactAvatar(avatars[0]).imageUrl() if len(avatars) > 0 else WAConstants.DEFAULT_CONTACT_PICTURE;
			label =  contact.displayLabel();
			numbers = contact.details(QContactPhoneNumber.DefinitionName);
			for number in numbers:
				self.contacts.append({"alphabet":label[0].upper(),"name":label,"number":QContactPhoneNumber(number).number(),"picture":avatar});

		return self.contacts;


if __name__ == "__main__":
	cs = ContactsSyncer();
	cs.start();
