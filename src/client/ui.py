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

from PySide import QtCore
from PySide.QtCore import QUrl
from PySide.QtDeclarative import QDeclarativeView,QDeclarativeProperty
from QtMobility.Messaging import *
from contacts import WAContacts
from waxmpp import WAXMPP
from utilities import Utilities
#from registration import Registration

from messagestore import MessageStore
from threading import Timer
from waservice import WAService
import dbus
from wadebug import UIDebug
import os, shutil, time, hashlib
from subprocess import call
import Image
from PIL.ExifTags import TAGS
from constants import WAConstants
import subprocess

class WAUI(QDeclarativeView):
	quit = QtCore.Signal()
	splashOperationUpdated = QtCore.Signal(str)
	initialized = QtCore.Signal()
	phoneContactsReady = QtCore.Signal(list)

	
	def __init__(self, accountJid):
		
		_d = UIDebug();
		self._d = _d.d;
	
		self.initializationDone = False
		bus = dbus.SessionBus()
		mybus = bus.get_object('com.nokia.video.Thumbnailer1', '/com/nokia/video/Thumbnailer1')
		self.iface = dbus.Interface(mybus, 'org.freedesktop.thumbnails.SpecializedThumbnailer1')
		self.iface.connect_to_signal("Finished", self.thumbnailUpdated)

		contactsbus = bus.get_object('com.nokia.maemo.meegotouch.Contacts', '/', follow_name_owner_changes=True, )
		self.contactsbus = dbus.Interface(contactsbus, 'com.nokia.maemo.meegotouch.ContactsInterface')
		self.contactsbus.connect_to_signal("contactsPicked", self.contactPicked)

		camerabus = bus.get_object('com.nokia.maemo.CameraService', '/', follow_name_owner_changes=True, )
		self.camera = dbus.Interface(camerabus, 'com.nokia.maemo.meegotouch.CameraInterface')
		self.camera.connect_to_signal("captureCompleted", self.captureCompleted)
		self.camera.connect_to_signal("cameraClosed", self.captureCanceled)
		self.selectedJid = ""
		
		super(WAUI,self).__init__();
		url = QUrl('/opt/waxmppplugin/bin/wazapp/UI/main.qml')

		self.filelist = []
		self.accountJid = accountJid;

		self.rootContext().setContextProperty("waversion", Utilities.waversion);
		self.rootContext().setContextProperty("WAConstants", WAConstants.getAllProperties());
		self.rootContext().setContextProperty("myAccount", accountJid);
		
		currProfilePicture = WAConstants.CACHE_PROFILE + "/" + accountJid.split("@")[0] + ".jpg"
		self.rootContext().setContextProperty("currentPicture", currProfilePicture if os.path.exists(currProfilePicture) else "")
		
		
		
		self.setSource(url);
		self.focus = False
		self.whatsapp = None
		self.idleTimeout = None
		
	
	def preQuit(self):
		self._d("pre quit")
		self.quit.emit()
		
	def onProcessEventsRequested(self):
		#self._d("Processing events")
		QtCore.QCoreApplication.processEvents()
		
	def initConnections(self,store):
		self.store = store;
		#self.setOrientation(QmlApplicationViewer.ScreenOrientationLockPortrait);
		#self.rootObject().sendRegRequest.connect(self.sendRegRequest);
		self.c = WAContacts(self.store);
		self.c.contactsRefreshed.connect(self.populateContacts);
		self.c.contactsRefreshed.connect(self.rootObject().onRefreshSuccess);
		#self.c.contactsRefreshed.connect(self.updateContactsData); NUEVO!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		self.c.contactsRefreshFailed.connect(self.rootObject().onRefreshFail);
		self.c.contactsSyncStatusChanged.connect(self.rootObject().onContactsSyncStatusChanged);
		self.c.contactPictureUpdated.connect(self.rootObject().onPictureUpdated);
		#self.c.contactUpdated.connect(self.rootObject().onContactUpdated);
		#self.c.contactAdded.connect(self.onContactAdded);
		self.rootObject().refreshContacts.connect(self.c.resync)
		self.rootObject().sendSMS.connect(self.sendSMS)
		self.rootObject().makeCall.connect(self.makeCall)
		self.rootObject().sendVCard.connect(self.sendVCard)
		self.rootObject().consoleDebug.connect(self.consoleDebug)
		self.rootObject().setLanguage.connect(self.setLanguage)
		self.rootObject().removeFile.connect(self.removeFile)
		self.rootObject().getRingtones.connect(self.getRingtones)
		self.rootObject().startRecording.connect(self.startRecording)
		self.rootObject().stopRecording.connect(self.stopRecording)
		self.rootObject().playRecording.connect(self.playRecording)
		self.rootObject().deleteRecording.connect(self.deleteRecording)
		self.rootObject().breathe.connect(self.onProcessEventsRequested)
		self.rootObject().browseFiles.connect(self.browseFiles)

		self.rootObject().openContactPicker.connect(self.openContactPicker)

		#self.rootObject().vibrateNow.connect(self.vibrateNow)
				
		#Changed by Tarek: connected directly to QContactManager living inside contacts manager
		#self.c.manager.manager.contactsChanged.connect(self.rootObject().onContactsChanged);
		#self.c.manager.manager.contactsAdded.connect(self.rootObject().onContactsChanged);
		#self.c.manager.manager.contactsRemoved.connect(self.rootObject().onContactsChanged);
		
		#self.contactsReady.connect(self.rootObject().pushContacts)
		self.phoneContactsReady.connect(self.rootObject().pushPhoneContacts)
		self.splashOperationUpdated.connect(self.rootObject().setSplashOperation)
		self.initialized.connect(self.rootObject().onInitDone)


		
		#self.rootObject().quit.connect(self.quit)
		
		self.messageStore = MessageStore(self.store);
		self.messageStore.messagesReady.connect(self.rootObject().messagesReady)
		self.messageStore.conversationReady.connect(self.rootObject().conversationReady)
		self.rootObject().loadMessages.connect(self.messageStore.loadMessages);
		
		
		self.rootObject().deleteConversation.connect(self.messageStore.deleteConversation)
		self.rootObject().deleteMessage.connect(self.messageStore.deleteMessage)
		self.rootObject().conversationOpened.connect(self.messageStore.onConversationOpened)
		self.rootObject().removeSingleContact.connect(self.messageStore.removeSingleContact)
		self.rootObject().exportConversation.connect(self.messageStore.exportConversation)
		self.dbusService = WAService(self);
		
	
	def focusChanged(self,old,new):
		if new is None:
			self.onUnfocus();
		else:
			self.onFocus();
	
	def onUnfocus(self):
		self._d("FOCUS OUT")
		self.focus = False
		
		if not self.initializationDone:
			return
		
		self.rootObject().appFocusChanged(False);
		self.idleTimeout = Timer(5,self.whatsapp.eventHandler.onUnavailable)
		self.idleTimeout.start()
		self.whatsapp.eventHandler.onUnfocus();
		
	
	def onFocus(self):
		self._d("FOCUS IN")
		self.focus = True
		
		if not self.initializationDone:
			return

		self.whatsapp.eventHandler.notifier.stopSound();
		self.rootObject().appFocusChanged(True);
		if self.idleTimeout is not None:
			self.idleTimeout.cancel()
		
		self.whatsapp.eventHandler.onFocus();
		self.whatsapp.eventHandler.onAvailable();
	
	def closeEvent(self,e):
		self._d("HIDING")
		e.ignore();
		self.whatsapp.eventHandler.onUnfocus();
		
		
		self.hide();
		
		#self.showFullScreen();
	
	def forceRegistration(self):
		''' '''
		self._d("NO VALID ACCOUNT")
		exit();
		self.rootObject().forceRegistration(Utilities.getCountryCode());
		
	def sendRegRequest(self,number,cc):
		
		
		self.reg.do_register(number,cc);
		#reg =  ContactsSyncer();
		#reg.start();
		#reg.done.connect(self.blabla);

		#reg.reg_success.connect(self.rootObject().regSuccess);
		#reg.reg_fail.connect(self.rootObject().regFail);
		
		#reg.start();
		
	def setLanguage(self,lang):
		if os.path.isfile(WAConstants.STORE_PATH + "/language.qm"):
			os.remove(WAConstants.STORE_PATH + "/language.qm")
		shutil.copyfile("/opt/waxmppplugin/bin/wazapp/i18n/" + lang + ".qm", WAConstants.STORE_PATH + "/language.qm")


	def consoleDebug(self,text):
		self._d(text);


	def setMyAccount(self,account):
		self.rootObject().setMyAccount(account)

	def sendSMS(self, num):
		print "SENDING SMS TO " + num
		m = QMessage()
		m.setType(QMessage.Sms)
		a = QMessageAddress(QMessageAddress.Phone, num)
		m.setTo(a)
		m.setBody("")
		s = QMessageService()
		s.compose(m)


	def makeCall(self, num):
		print "CALLING TO " + num
		bus = dbus.SystemBus()
		csd_call = dbus.Interface(bus.get_object('com.nokia.csd', '/com/nokia/csd/call'), 'com.nokia.csd.Call')
		csd_call.CreateWith(str(num), dbus.UInt32(0))
	
	def sendVCard(self,jid,name):
		self.c.exportContact(jid,name);
	

	def openContactPicker(self,multi,title):
		call(["qdbus", "com.nokia.maemo.meegotouch.Contacts", "/", "com.nokia.maemo.meegotouch.ContactsInterface.openContactPicker", "0", title, multi, "", "1", "("," ",")"])


	def contactPicked(self,contacts,val):
		print "CONTACTS PICKED: " + str(contacts) + " - " + val


		
	def updateContact(self, jid):
		self._d("POPULATE SINGLE");
		self.c.updateContact(jid);
	
	def updatePushName(self, jid, push):
		self._d("UPDATING CONTACTS");
		contacts = self.c.getContacts();
		self.rootObject().updateContactsData(contacts);
		self.rootObject().updateContactName.emit(jid,push);


	def updateContactsData(self):
		contacts = self.c.getContacts();
		position = 0
		for contact in contacts:
			print "CONTACT DATA: " + str(contact)
			if contact.iscontact=="no" and contact.pushname=="":
				self.rootObject().insertNewContact(position,contact);
			position = position +1


		

	def populateContacts(self, mode, status=""):
		#syncer = ContactsSyncer(self.store);
		
		#self.c.refreshing.connect(syncer.onRefreshing);
		#syncer.done.connect(c.updateContacts);
		if (mode == "STATUS"):
			self._d("UPDATE CONTACT STATUS");
			self.rootObject().updateContactStatus(status)

		else:
			if not self.initializationDone:
				self.splashOperationUpdated.emit("Loading Contacts")

			contacts = self.c.getContacts();
			self._d("POPULATE CONTACTS: " + str(len(contacts)));
			
			
			contactsFiltered = filter(lambda c: c["jid"]!=self.accountJid, contacts)
			self.rootObject().pushContacts(mode,contactsFiltered);

		#if self.whatsapp is not None:
		#	self.whatsapp.eventHandler.networkDisconnected()

		
	def populateConversations(self):
		if not self.initializationDone:
			self.splashOperationUpdated.emit("Loading Conversations")
		self.messageStore.loadConversations()
		

	def populatePhoneContacts(self):
		
		if not self.initializationDone:
			self.splashOperationUpdated.emit("Loading Phone Contacts")
		
		self._d("POPULATE PHONE CONTACTS");
		contacts = self.c.getPhoneContacts();
		self.rootObject().pushPhoneContacts(contacts);
		#self.phoneContactsReady.emit(contacts)

	
	def login(self):
		self.whatsapp.start();
	
	def showUI(self,jid):
		self._d("SHOULD SHOW")
		self.showFullScreen();
		self.rootObject().openConversation(jid)
		
	def getActiveConversation(self):
		
		if not self.focus:
			return 0
		
		self._d("GETTING ACTIVE CONV")
		
		activeConvJId = QDeclarativeProperty(self.rootObject(),"activeConvJId").read();
		
		#self.rootContext().contextProperty("activeConvJId");
		self._d("DONE - " + str(activeConvJId))
		self._d(activeConvJId)
		
		return activeConvJId
		

	def processFiles(self, folder, data): #, ignored):
		#print "Processing " + folder
		
		if not os.path.exists(folder):
			return
		
		currentDir = os.path.abspath(folder)
		filesInCurDir = os.listdir(currentDir)

		for file in filesInCurDir:
			curFile = os.path.join(currentDir, file)

			if os.path.isfile(curFile):
				curFileExtention = curFile.split(".")[-1]
				if curFileExtention in data and not curFile in self.filelist and not "No sound.wav" in curFile:
					self.filelist.append(curFile)
			elif not "." in curFile: #Don't process hidden folders
				#if not curFile in ignored:
				self.processFiles(curFile, data) #, ignored)


	def getImageFiles(self):
		print "GETTING IMAGE FILES..."
		self.filelist = []
		data = ["jpg","jpeg","png","gif","JPG","JPEG","PNG","GIF"]
		'''ignored = ["/home/user/MyDocs/ANDROID","/home/user/MyDocs/openfeint"]
		f = open("/home/user/.config/tracker/tracker-miner-fs.cfg", 'r')
		for line in f:
			if "IgnoredDirectories=" in line:
				values = line.replace("IgnoredDirectories=","").split(';')
				break
		f.close()
		for val in values:
			ignored.append(val.replace("$HOME","/home/user"))'''

		self.processFiles("/home/user/MyDocs/DCIM", data) #, ignored)
		self.processFiles("/home/user/MyDocs/Pictures", data) #, ignored)
		self.processFiles("/home/user/MyDocs/Wazapp", data) #, ignored) @@Remove since using STORE_PATH as well?
		self.processFiles(WAConstants.STORE_PATH, data)


		myfiles = []
		for f in self.filelist:
			stats = os.stat(f)
			lastmod = time.localtime(stats[8])

			m = hashlib.md5()
			url = QtCore.QUrl("file://"+f).toEncoded()
			m.update(url)
			crypto = WAConstants.THUMBS_PATH + "/grid/" + m.hexdigest() + ".jpeg"
			if not os.path.exists(crypto):
				# Thumbnail does'n exist --> Generating...
				if f.split(".")[-1] == "jpg" or f.split(".")[-1] == "JPG":
					self.iface.Queue(str(url),"image/jpeg","grid", True)
				elif f.split(".")[-1] == "png" or f.split(".")[-1] == "PNG":
					self.iface.Queue(str(url),"image/png","grid", True)
				elif f.split(".")[-1] == "gif" or f.split(".")[-1] == "GIF":
					self.iface.Queue(str(url),"image/gif","grid", True)

			myfiles.append({"fileName":f.split('/')[-1],"url":QtCore.QUrl("file://"+f).toEncoded(),"date":lastmod,"thumb":crypto}) 

		self.rootObject().pushImageFiles( sorted(myfiles, key=lambda k: k['date'], reverse=True) );


	def getVideoFiles(self):
		print "GETTING VIDEO FILES..."
		self.filelist = []
		data = ["mov","3gp","mp4","MOV","3GP","MP4"]
		'''ignored = ["/home/user/MyDocs/ANDROID","/home/user/MyDocs/openfeint"]
		f = open("/home/user/.config/tracker/tracker-miner-fs.cfg", 'r')
		for line in f:
			if "IgnoredDirectories=" in line:
				values = line.replace("IgnoredDirectories=","").split(';')
				break
		f.close()
		for val in values:
			ignored.append(val.replace("$HOME","/home/user"))'''

		self.processFiles("/home/user/MyDocs/DCIM", data) #, ignored)
		self.processFiles("/home/user/MyDocs/Movies", data) #, ignored)
		self.processFiles("/home/user/MyDocs/Wazapp", data) #, ignored)
		self.processFiles(WAConstants.STORE_PATH, data)

		myfiles = []
		for f in self.filelist:
			stats = os.stat(f)
			lastmod = time.localtime(stats[8])
			
			m = hashlib.md5()
			url = QtCore.QUrl("file://"+f).toEncoded()
			m.update(url)
			crypto = WAConstants.THUMBS_PATH + "/grid/" + m.hexdigest() + ".jpeg"
			if not os.path.exists(crypto):
				# Thumbnail does'n exist --> Generating...
				if f.split(".")[-1] == "mp4" or f.split(".")[-1] == "MP4":
					self.iface.Queue(str(url),"video/mp4","grid", True)
				elif f.split(".")[-1] == "3gp" or f.split(".")[-1] == "3GP":
					self.iface.Queue(str(url),"video/3gpp4","grid", True)
				elif f.split(".")[-1] == "mov" or f.split(".")[-1] == "MOV":
					self.iface.Queue(str(url),"video/mpquicktime4","grid", True)

			myfiles.append({"fileName":f.split('/')[-1],"url":QtCore.QUrl("file://"+f).toEncoded(),"date":lastmod,"thumb":crypto}) 

		self.rootObject().pushVideoFiles( sorted(myfiles, key=lambda k: k['date'], reverse=True) );


	def getRingtones(self):
		print "GETTING RING TONES..."
		self.filelist = []
		data = ["mp3","MP3","wav","WAV"]
		self.processFiles("/usr/share/sounds/ring-tones/", data) #, ignored)
		self.processFiles("/home/user/MyDocs/Ringtones", data) #, ignored)

		myfiles = []
		for f in self.filelist:
			myfiles.append({"name":f.split('/')[-1].split('.')[0].title(),"value":f}) 

		self.rootObject().pushRingtones( sorted(myfiles, key=lambda k: k['name']) );



	def thumbnailUpdated(self,result):
		self.rootObject().onThumbnailUpdated()


	def openCamera(self, jid, mode):
		#self.camera.showCamera() #Only supports picture mode on start

		self.selectedJid = jid;
		call(["qdbus", "com.nokia.maemo.CameraService", "/", "com.nokia.maemo.meegotouch.CameraInterface.showCamera", "0", "", mode, "true"])

		'''
		# This shit doesn't work!!!
		camera = QCamera;
		viewFinder = QCameraViewfinder();
		viewFinder.show();
		camera.setViewfinder(viewFinder);
		imageCapture = QCameraImageCapture(camera);
		camera.setCaptureMode(QCamera.CaptureStillImage);
		camera.start();'''



	def captureCompleted(self,mode,filepath):
		if self.selectedJid == "":
			return;

		print "CAPTURE COMPLETED! Mode: " + mode
		rotation = 0
		capturemode = "image"
		if filepath.split(".")[-1] == "jpg":
			crypto = ""
			rotation = 0
			im = Image.open(filepath)
			try:
				if ', 274: 6,' in str(im._getexif()):
					rotation = 90
			except:
				rotation = 0
		else:
			capturemode = "video"
			m = hashlib.md5()
			url = QtCore.QUrl("file://"+filepath).toEncoded()
			m.update(url)
			crypto = WAConstants.THUMBS_PATH + "/screen/" + m.hexdigest() + ".jpeg"
			self.iface.Queue(str(url),"video/mp4","screen", True)

		print "CAPTURE COMPLETED! File: " + filepath
		self.rootObject().capturedPreviewPicture(self.selectedJid, filepath, rotation, crypto, capturemode)
		self.selectedJid = ""


	def captureCanceled(self):
		print "CAPTURE CLOSED!!!"
		self.selectedJid = ""


	def removeFile(self, filepath):
		print "REMOVING FILE: " + filepath
		filepath = filepath.replace("file://","")
		os.remove(filepath)


	def startRecording(self):
		print 'Starting the record...'
		self.pipe = subprocess.Popen(['/usr/bin/arecord','-r','16000','-t','wav',WAConstants.CACHE_PATH+'/temprecord.wav'])
		print "The pid is: " + str(self.pipe.pid)


	def stopRecording(self):
		print 'Killing REC Process now!'
		os.kill(self.pipe.pid, 9)
		self.pipe.poll()


	def playRecording(self):
		self.whatsapp.eventHandler.notifier.playSound(WAConstants.CACHE_PATH+'/temprecord.wav')


	def deleteRecording(self):
		if os.path.exists(WAConstants.CACHE_PATH+'/temprecord.wav'):
			os.remove(WAConstants.CACHE_PATH+'/temprecord.wav')


	def browseFiles(self, folder, format):
		print "Processing " + folder
		currentDir = os.path.abspath(folder)
		filesInCurDir = os.listdir(currentDir)
		myfiles = []

		for file in filesInCurDir:
			curFile = os.path.join(currentDir, file)
			curFileName = curFile.split('/')[-1]
			if curFileName[0] != ".":
				if os.path.isfile(curFile):
					curFileExtention = curFile.split(".")[-1]
					if curFileExtention in format:
						myfiles.append({"fileName":curFileName,"filepath":curFile, 
										"filetype":"send-audio", "name":"a"+curFile.split('/')[-1]})
				else:
					myfiles.append({"fileName":curFileName,"filepath":curFile, 
									"filetype":"folder", "name":"a"+curFile.split('/')[-1]})

		self.rootObject().pushBrowserFiles( sorted(myfiles, key=lambda k: k['name']), folder);



	def initConnection(self):
		
		password = self.store.account.password;
		usePushName = self.store.account.pushName
		resource = "iPhone-2.8.3";
		chatUserID = self.store.account.username;
		domain ='s.whatsapp.net'
		
		
		
		whatsapp = WAXMPP(domain,resource,chatUserID,usePushName,password);
		
		WAXMPP.message_store = self.messageStore;
	
		whatsapp.setContactsManager(self.c);
		
		whatsapp.eventHandler.connected.connect(self.rootObject().onConnected);
		whatsapp.eventHandler.typing.connect(self.rootObject().onTyping)
		whatsapp.eventHandler.paused.connect(self.rootObject().onPaused)
		whatsapp.eventHandler.showUI.connect(self.showUI)
		whatsapp.eventHandler.messageSent.connect(self.rootObject().onMessageSent);
		whatsapp.eventHandler.messageDelivered.connect(self.rootObject().onMessageDelivered);
		whatsapp.eventHandler.connecting.connect(self.rootObject().onConnecting);
		whatsapp.eventHandler.loginFailed.connect(self.rootObject().onLoginFailed);
		whatsapp.eventHandler.sleeping.connect(self.rootObject().onSleeping);
		whatsapp.eventHandler.disconnected.connect(self.rootObject().onDisconnected);
		whatsapp.eventHandler.available.connect(self.rootObject().onAvailable);
		whatsapp.eventHandler.unavailable.connect(self.rootObject().onUnavailable);
		whatsapp.eventHandler.lastSeenUpdated.connect(self.rootObject().onLastSeenUpdated);
		whatsapp.eventHandler.updateAvailable.connect(self.rootObject().onUpdateAvailable)
		
		whatsapp.eventHandler.groupInfoUpdated.connect(self.rootObject().onGroupInfoUpdated);
		whatsapp.eventHandler.groupCreated.connect(self.rootObject().groupCreated);
		whatsapp.eventHandler.addedParticipants.connect(self.rootObject().addedParticipants);
		whatsapp.eventHandler.removedParticipants.connect(self.rootObject().onRemovedParticipants);
		whatsapp.eventHandler.groupParticipants.connect(self.rootObject().onGroupParticipants);
		whatsapp.eventHandler.groupEnded.connect(self.rootObject().onGroupEnded);
		whatsapp.eventHandler.groupSubjectChanged.connect(self.rootObject().onGroupSubjectChanged);
		whatsapp.eventHandler.profilePictureUpdated.connect(self.updateContact);

		whatsapp.eventHandler.setPushName.connect(self.updatePushName);
		whatsapp.eventHandler.statusChanged.connect(self.rootObject().onProfileStatusChanged);
		#whatsapp.eventHandler.setPushName.connect(self.rootObject().updatePushName);
		#whatsapp.eventHandler.profilePictureUpdated.connect(self.rootObject().onPictureUpdated);

		whatsapp.eventHandler.imageRotated.connect(self.rootObject().imageRotated);
		whatsapp.eventHandler.getPicturesFinished.connect(self.rootObject().getPicturesFinished);

		whatsapp.eventHandler.mediaTransferSuccess.connect(self.rootObject().mediaTransferSuccess);
		whatsapp.eventHandler.mediaTransferError.connect(self.rootObject().mediaTransferError);
		whatsapp.eventHandler.mediaTransferProgressUpdated.connect(self.rootObject().mediaTransferProgressUpdated)
		
		whatsapp.eventHandler.doQuit.connect(self.preQuit);
		
		whatsapp.eventHandler.notifier.ui = self
		
		
		#whatsapp.eventHandler.new_message.connect(self.rootObject().newMessage)
		self.rootObject().sendMessage.connect(whatsapp.eventHandler.sendMessage)
		self.rootObject().sendTyping.connect(whatsapp.eventHandler.sendTyping)
		self.rootObject().sendPaused.connect(whatsapp.eventHandler.sendPaused);
		self.rootObject().conversationActive.connect(whatsapp.eventHandler.getLastOnline);
		self.rootObject().conversationActive.connect(whatsapp.eventHandler.conversationOpened);
		self.rootObject().quit.connect(whatsapp.eventHandler.quit)
		self.rootObject().fetchMedia.connect(whatsapp.eventHandler.fetchMedia)
		self.rootObject().fetchGroupMedia.connect(whatsapp.eventHandler.fetchGroupMedia)
		self.rootObject().uploadMedia.connect(whatsapp.eventHandler.uploadMedia)
		self.rootObject().uploadGroupMedia.connect(whatsapp.eventHandler.uploadGroupMedia)
		self.rootObject().getGroupInfo.connect(whatsapp.eventHandler.getGroupInfo)
		self.rootObject().createGroupChat.connect(whatsapp.eventHandler.createGroupChat)
		self.rootObject().addParticipants.connect(whatsapp.eventHandler.addParticipants)
		self.rootObject().removeParticipants.connect(whatsapp.eventHandler.removeParticipants)
		self.rootObject().getGroupParticipants.connect(whatsapp.eventHandler.getGroupParticipants)
		self.rootObject().endGroupChat.connect(whatsapp.eventHandler.endGroupChat)
		self.rootObject().setGroupSubject.connect(whatsapp.eventHandler.setGroupSubject)
		self.rootObject().getPictureIds.connect(whatsapp.eventHandler.getPictureIds)
		self.rootObject().getPicture.connect(whatsapp.eventHandler.getPicture)
		self.rootObject().setGroupPicture.connect(whatsapp.eventHandler.setGroupPicture)
		self.rootObject().setMyProfilePicture.connect(whatsapp.eventHandler.setProfilePicture)
		self.rootObject().sendMediaImageFile.connect(whatsapp.eventHandler.sendMediaImageFile)
		self.rootObject().sendMediaVideoFile.connect(whatsapp.eventHandler.sendMediaVideoFile)
		self.rootObject().sendMediaAudioFile.connect(whatsapp.eventHandler.sendMediaAudioFile)
		self.rootObject().sendMediaRecordedFile.connect(whatsapp.eventHandler.sendMediaRecordedFile)
		self.rootObject().sendMediaMessage.connect(whatsapp.eventHandler.sendMediaMessage)
		self.rootObject().sendLocation.connect(whatsapp.eventHandler.sendLocation)
		self.rootObject().rotateImage.connect(whatsapp.eventHandler.rotateImage)
		self.rootObject().changeStatus.connect(whatsapp.eventHandler.changeStatus)

		self.c.contactExported.connect(whatsapp.eventHandler.sendVCard)

		self.rootObject().setBlockedContacts.connect(whatsapp.eventHandler.setBlockedContacts)
		self.rootObject().setResizeImages.connect(whatsapp.eventHandler.setResizeImages)
		self.rootObject().setPersonalRingtone.connect(whatsapp.eventHandler.setPersonalRingtone)
		self.rootObject().setPersonalVibrate.connect(whatsapp.eventHandler.setPersonalVibrate)
		self.rootObject().setGroupRingtone.connect(whatsapp.eventHandler.setGroupRingtone)
		self.rootObject().setGroupVibrate.connect(whatsapp.eventHandler.setGroupVibrate)

		self.rootObject().openCamera.connect(self.openCamera)

		self.rootObject().getImageFiles.connect(self.getImageFiles)
		self.rootObject().getVideoFiles.connect(self.getVideoFiles)
		
		self.rootObject().populatePhoneContacts.connect(self.populatePhoneContacts)
		self.rootObject().playSoundFile.connect(whatsapp.eventHandler.notifier.playSound)
		self.rootObject().stopSoundFile.connect(whatsapp.eventHandler.notifier.stopSound)


		#self.reg = Registration();
		self.whatsapp = whatsapp;
		
		
		#print "el acks:"
		#print whatsapp.supports_receipt_acks
		
		#self.whatsapp.start();
		
		
		

		

