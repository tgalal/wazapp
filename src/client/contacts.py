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
from PySide.QtCore import *
from PySide.QtGui import QImage
from PySide import QtCore;
from QtMobility.Contacts import *
from QtMobility.Versit import *
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

	def __init__(self,store,userid):
		WADebug.attach(self);
		self.store = store;
		self.uid = userid;
		self.base_url = "sro.whatsapp.net";
		self.req_file = "/client/iphone/bbq.php";
		super(ContactsSyncer,self).__init__();

	def sync(self):
		self._d("INITiATING SYNC")
		self.contactsSyncStatus.emit("GETTING");
		self.clearParams();

		if self.uid == "ALL":
			cm = ContactsManager();
			phoneContacts = cm.getContacts();
			for c in phoneContacts:
				self.addParam("u[]",c['number'])

		else:
			parts = self.uid.split(',')
			for part in parts:
				if part != "undefined":
					self._d("ADDING CONTACT FOR SYNC " + part)
					self.addParam("u[]",part)
		
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
		data = minidom.parseString(data);
		contacts = data.getElementsByTagName("s");
	
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
	contactUpdated = QtCore.Signal(str);
	contactExported = QtCore.Signal(str,str);

	def __init__(self,store):
		super(WAContacts,self).__init__();
		self.store = store;
		self.contacts = [];
		self.raw_contacts = None;
		self.manager = ContactsManager();
		
		
	
	def initiateSyncer(self, userid):
		self.syncer = ContactsSyncer(self.store,userid);
		#self.syncer.done.connect(self.syncer.updateContacts);
		self.syncer.contactsRefreshSuccess.connect(self.contactsRefreshed);
		self.syncer.contactsRefreshFail.connect(self.contactsRefreshFailed);
		self.syncer.contactsSyncStatus.connect(self.contactsSyncStatusChanged);

	def resync(self, userid=None):
		self.initiateSyncer(userid);
		self.refreshing.emit();
		self.syncer.start();
		
		
	def updateContact(self,jid):
		if "@g.us" in jid:
			user_img = QImage("/opt/waxmppplugin/bin/wazapp/UI/common/images/group.png")
		else:
			user_img = QImage("/opt/waxmppplugin/bin/wazapp/UI/common/images/user.png")

		jname = jid.replace("@s.whatsapp.net","").replace("@g.us","")
		user_img.save("/home/user/.cache/wazapp/contacts/" + jname + ".png", "PNG")
		if os.path.isfile("/home/user/.cache/wazapp/contacts/" + jname + ".jpg"):
			user_img = QImage("/home/user/.cache/wazapp/contacts/" + jname + ".jpg")
			user_img.save("/home/user/.cache/wazapp/profile/" + jname + ".jpg", "JPEG")
		mask_img = QImage("/opt/waxmppplugin/bin/wazapp/UI/common/images/usermask.png")
		preimg = QPixmap.fromImage(QImage(user_img.scaled(96, 96, Qt.KeepAspectRatioByExpanding, Qt.SmoothTransformation)));
		PixmapToBeMasked = QImage(96, 96, QImage.Format_ARGB32_Premultiplied);
		Mask = QPixmap.fromImage(mask_img);
		Painter = QPainter(PixmapToBeMasked);
		Painter.drawPixmap(0, 0, 96, 96, preimg);
		Painter.setCompositionMode(QPainter.CompositionMode_DestinationIn);
		Painter.drawPixmap(0, 0, 96, 96, Mask);
		Painter.end()
		PixmapToBeMasked.save("/home/user/.cache/wazapp/contacts/" + jname + ".png", "PNG")
		#os.remove("/home/user/.cache/wazapp/contacts/" + jname + ".jpg")
		self.contactUpdated.emit(jid);


	def updateContactPushName(self,jid,pushname):
		jname = jid.replace("@s.whatsapp.net","")

		cm = self.manager
		phoneContacts = cm.getContacts();

		exists = False
		for c in phoneContacts:
			if jname == c['number']:
				exists = True;
				break;

		contact = self.store.Contact.getOrCreateContactByJid(jid)
		contact.pushname = pushname
		contact.save()
		self.store.cacheContacts(self.contacts);
		
		if exists is True:
			self.contactUpdated.emit(jid);
		else:
			self.contactsRefreshed.emit();
				
	def checkPicture(self,jname,imagepath):
		if not os.path.isfile("/home/user/.cache/wazapp/contacts/" + jname + ".png"):
			user_img = QImage("/opt/waxmppplugin/bin/wazapp/UI/common/images/user.png")
			if imagepath is not "":
				user_img = QImage(QUrl(imagepath).toString().replace("file://",""))
			if os.path.isfile("/home/user/.cache/wazapp/contacts/" + jname + ".jpg"):
				user_img = QImage("/home/user/.cache/wazapp/contacts/" + jname + ".jpg")
			mask_img = QImage("/opt/waxmppplugin/bin/wazapp/UI/common/images/usermask.png")
			preimg = QPixmap.fromImage(QImage(user_img.scaled(96, 96, Qt.KeepAspectRatioByExpanding, Qt.SmoothTransformation)));
			PixmapToBeMasked = QImage(96, 96, QImage.Format_ARGB32_Premultiplied);
			Mask = QPixmap.fromImage(mask_img);
			Painter = QPainter(PixmapToBeMasked);
			Painter.drawPixmap(0, 0, 96, 96, preimg);
			Painter.setCompositionMode(QPainter.CompositionMode_DestinationIn);
			Painter.drawPixmap(0, 0, 96, 96, Mask);
			Painter.end()
			PixmapToBeMasked.save("/home/user/.cache/wazapp/contacts/" + jname + ".png", "PNG")
			if os.path.isfile("/home/user/.cache/wazapp/contacts/" + jname + ".jpg"):
				os.remove("/home/user/.cache/wazapp/contacts/" + jname + ".jpg")



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
		if not os.path.exists("/home/user/.cache/wazapp/profile"):
			os.makedirs("/home/user/.cache/wazapp/profile")

		for wc in contacts:
			jname = wc.jid.replace("@s.whatsapp.net","")
			founded = False
			for c in phoneContacts:
				if wc.number == c['number']:
					founded = True
					self.checkPicture(jname,c['picture'])
					c['picture'] = "/home/user/.cache/wazapp/contacts/" + jname + ".png";
					wc.setRealTimeData(c['name'],c['picture']);
					break;

			if founded is False:
				self.checkPicture(jname,"")
				c['name'] = wc.pushname if wc.pushname is not None else ""
				c['picture'] = "/home/user/.cache/wazapp/contacts/" + jname + ".png";
				wc.setRealTimeData(c['name'],c['picture']);

			if wc.status is not None:
				wc.status = wc.status.decode('utf-8');
			if wc.pushname is not None:
				wc.pushname = wc.pushname.decode('utf-8');

			if c['name'] is not "":
				tmp.append(wc.getModelData());
				self.contacts[wc.number] = wc;

					
		self.store.cacheContacts(self.contacts);
		return sorted(tmp, key=lambda k: k['name'].upper()) ;



	def getPhoneContacts(self):
		cm = self.manager
		phoneContacts = cm.getPhoneContacts();
		tmp = []

		for c in phoneContacts:
			wc = [];
			c['picture'] = QUrl(c['picture']).toString().replace("file://","")
			wc.append(c['name'])
			#wc.append(c['id'])
			wc.append(c['picture'])
			wc.append(c['numbers'])
			if ( len(c['numbers'])>0):
				tmp.append(wc);
		return sorted(tmp)



	def exportContact(self, jid, name):
		cm = self.manager
		phoneContacts = cm.getQtContacts();
		contacts = []

		for c in phoneContacts:
			if name == c.displayLabel():
				if os.path.isfile("/home/user/.cache/wazapp/contacts/" + name + ".vcf"):
					os.remove("/home/user/.cache/wazapp/contacts/" + name + ".vcf")
				print "founded contact: " + c.displayLabel()
				contacts.append(c)
				openfile = QFile("/home/user/MyDocs/Wazapp/media/contacts/" + name + ".vcf")
				openfile.open(QIODevice.WriteOnly)
				if openfile.isWritable():
					exporter = QVersitContactExporter()
					if exporter.exportContacts(contacts, QVersitDocument.VCard30Type):
						documents = exporter.documents()
						writer = QVersitWriter()
						writer.setDevice(openfile)
						writer.startWriting(documents)
						writer.waitForFinished()
				openfile.close()
				self.contactExported.emit(jid, name);
				break;



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


	def getPhoneContacts(self):
		contacts = self.manager.contacts();
		self.contacts = []
		for contact in contacts:
			avatars = contact.details(QContactAvatar.DefinitionName);
			avatar = QContactAvatar(avatars[0]).imageUrl() if len(avatars) > 0 else WAConstants.DEFAULT_CONTACT_PICTURE;
			label =  contact.displayLabel();
			#cid =  contact.id();
			numbers = contact.details(QContactPhoneNumber.DefinitionName);
			allnumbers = []

			for number in numbers:
				allnumbers.append(QContactPhoneNumber(number).number())

			self.contacts.append({"name":label,"numbers":allnumbers,"picture":avatar});

		return self.contacts;


	def getQtContacts(self):
		return self.manager.contacts();


if __name__ == "__main__":
	cs = ContactsSyncer();
	cs.start();
