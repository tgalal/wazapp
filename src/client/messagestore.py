# -*- coding: utf-8 -*-
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
from PySide.QtCore import QObject
from PySide.QtGui import QImage
import time
import datetime
from wadebug import MessageStoreDebug
import os
from constants import WAConstants
import dbus

class MessageStore(QObject):


	messageStatusUpdated = QtCore.Signal(str,int,int);
	messagesReady = QtCore.Signal(dict,bool);
	conversationReady = QtCore.Signal(dict);
	conversationExported = QtCore.Signal(str, str); #jid, exportePath
	conversationMedia = QtCore.Signal(list);
	conversationGroups = QtCore.Signal(list);
	
	currKeyId = 0

	def __init__(self,dbstore):
	
		_d = MessageStoreDebug();
		self._d = _d.d;
		super(MessageStore,self).__init__();
		
		self.store = dbstore
		self.conversations = {}
		#get unique contactId from messages
		#messages = self.store.Message.findAll(fields=["DISTINCT contact_id"])
		#for m in messages:
		#	self.loadMessages(m.getContact());
		#load messages for jids of those ids
		
	
	def onConversationOpened(self,jid):
		if not self.conversations.has_key(jid):
			return
			
		conv = self.conversations[jid]
		conv.clearNew();
	
	def deleteConversation(self,jid):
	
		if not self.conversations.has_key(jid):
			return
		
		conv = self.conversations[jid]
		
		if conv.type == "single":
			self.store.Message.delete({"conversation_id":conv.id})
		else:
			self.store.Groupmessage.delete({"groupconversation_id":conv.id})
		conv.delete();
		del self.conversations[jid]

	

	def deleteMessage(self,jid,msgid):

		if not self.conversations.has_key(jid):
			return
		
		conv = self.conversations[jid]
		
		if conv.type == "single":
			self.store.Message.delete({"conversation_id":conv.id, "id":msgid})
		else:
			self.store.Groupmessage.delete({"groupconversation_id":conv.id, "id":msgid})


	def removeSingleContact(self, jid):
		self._d("Removing contact: "+jid);


	def exportConversation(self, jid):
		self._d("Exporting conversations")
		bus = dbus.SessionBus()
		exportDir = WAConstants.CACHE_CONV

		if not os.path.exists(exportDir):
			os.makedirs(exportDir)
			
		conv = self.getOrCreateConversationByJid(jid)
		conv.loadMessages(offset=0, limit=0)
		
		cachedContacts = self.store.getCachedContacts()
		
		contacts = {}
		
		if not conv.isGroup():
			contact = conv.getContact()
			try:
				contacts[contact.id] = cachedContacts[contact.number].name or contact.number
			except:
				contacts[contact.id] = contact.number
				
		else:
			contacts = conv.getContacts()
			for c in contacts:
				try:
					contacts[c.id] = cachedContacts[c.number].name or c.number
				except:
					contacts[c.id] = c.number
		
		fileName = "WhatsApp chat with %s"%(contacts[contact.id])
		exportPath = "%s/%s.txt"%(exportDir, fileName.encode('utf-8'))
		item = "file://"+exportPath
		
		buf = ""

		for m in conv.messages:
			if not conv.isGroup():
				if m.type == m.TYPE_SENT and m.status != m.STATUS_DELIVERED:
					continue
			
			t = datetime.datetime.fromtimestamp(int(m.timestamp)/1000).strftime('%d-%m-%Y %H:%M')
			author = contacts[m.contact_id] if conv.isGroup() else (contacts[conv.contact_id] if m.type == m.TYPE_RECEIVED else "You")
			content = m.content if not m.media_id else "[media omitted]"
			try:
				authorClean = author.encode('utf-8','replace') #how it's working for you?
			except UnicodeDecodeError:
#				authorClean = "".join(i for i in author if ord(i)<128) #and why this?
				authorClean = author #working great for all cases
			try:
				contentClean = content.encode('utf-8','replace') #same again
			except UnicodeDecodeError:
#				contentClean = "".join(i for i in content if ord(i)<128) #same again
				contentClean = content #same again
			buf+="[%s]%s: %s\n"%(str(t),authorClean,contentClean)

		f = open(exportPath, 'w')		
		f.write(buf)
		f.close()
			
		trackerService = bus.get_object('org.freedesktop.Tracker1.Miner.Files.Index','/org/freedesktop/Tracker1/Miner/Files/Index')
		addFile = trackerService.get_dbus_method('IndexFile','org.freedesktop.Tracker1.Miner.Files.Index')
		addFile(item)
		time.sleep(1) #the most stupid line I ever wrote in my life but it must be here because of the sluggish tracker
		shareService = bus.get_object('com.nokia.ShareUi', '/')
		share = shareService.get_dbus_method('share', 'com.nokia.maemo.meegotouch.ShareUiInterface')
		share([item,])		
			
			
	def getConversationMedia(self,jid):
		tmp = []
		media = []
		gMedia = []

		conversation = self.getOrCreateConversationByJid(jid)

		messages = self.store.Message.findAll({"conversation_id":conversation.id,"NOT media_id":0})
		for m in messages:
			media.append(m.getMedia())

		if media:
			for ind in media:
				if ind.transfer_status == 2:
					tmp.append(ind.getModelData());

		gMessages = self.store.Groupmessage.findAll({"contact_id":conversation.contact_id,"NOT media_id":0})
		for m in gMessages:
			gMedia.append(m.getMedia())

		if gMedia:
			for gind in gMedia:
				if gind.transfer_status == 2:
					tmp.append(gind.getModelData());

		self.conversationMedia.emit(tmp)

	def getConversationGroups(self,jid):

		contact = self.store.Contact.getOrCreateContactByJid(jid)
		groups = self.store.GroupconversationsContacts.findGroups(contact.id)
		cachedContacts = self.store.getCachedContacts()
		
		tmp = []
		
		for group in groups:
			if group.jid is None:
				continue
			groupInfo = {}
			groupInfo["jid"] = str(group.jid)
			jname = group.jid.replace("@g.us","")
			groupInfo["pic"] = WAConstants.CACHE_CONTACTS+"/"+jname+".png" if os.path.isfile(WAConstants.CACHE_CONTACTS+"/"+jname+".png") else WAConstants.DEFAULT_GROUP_PICTURE
			groupInfo["subject"] = str(group.subject)
			groupInfo["contacts"] = ""
			
			contacts = group.getContacts()
			resultContacts = []
			for c in contacts:
				try:
					contact = cachedContacts[c.number].name or c.number
				except:
					contact = c.number
				resultContacts.append(contact.encode('utf-8'))
				
			groupInfo["contacts"] = resultContacts
			
			tmp.append(groupInfo)

		self.conversationGroups.emit(tmp)
	
	def loadConversations(self):
		conversations = self.store.ConversationManager.findAll();
		self._d("init load convs")
		convList = []
		for c in conversations:
			self._d("loading messages")
			jid = c.getJid();
			c.loadMessages();

			self.conversations[jid] = c

			if len(c.messages) > 0:
				convList.append({"jid":jid,"message":c.messages[0],"lastdate":c.messages[0].created})

		convList = sorted(convList, key=lambda k: k['lastdate']);
		convList.reverse();

		for ci in convList:
			messages = []
			self.sendConversationReady(ci['jid']);
			messages.append(ci['message']);
			self.sendMessagesReady(ci['jid'],messages,False);

			#elif len(c.messages) == 0:
			#	self.deleteConversation(jid)
		

	def loadMessages(self,jid,offset=0, limit=1):
	
		self._d("Load more messages requested");
		
		messages = self.conversations[jid].loadMessages(offset,limit);
		
		self.sendMessagesReady(jid,messages,False);
		return messages
	
	
	def sendConversationReady(self,jid):
		#self._d("SENDING CONV READY %s"%jid)
		'''
			jid,subject,id,contacts..etc
			messages
		'''
		c = self.conversations[jid];
		tmp = c.getModelData();
		#self._d(tmp)
		tmp["isGroup"] = c.isGroup()
		tmp["jid"]=c.getJid();
		picturePath =  WAConstants.CACHE_CONTACTS + "/" + jid.split('@')[0] + ".png"
		tmp["picture"] = picturePath if os.path.isfile(picturePath) else None
		#self._d("Checking if group")
		if c.isGroup():
			#self._d("yes, fetching contacts")
			contacts = c.getContacts();
			tmp["contacts"] = []
			for contact in contacts:
				#self._d(contact.getModelData())
				tmp["contacts"].append(contact.getModelData());
		
		#self._d("emitting ready ")
		self.conversationReady.emit(tmp);
	
	def sendMessagesReady(self,jid,messages,reorder=True):
		if not len(messages):
			return
			
		tmp = {}
		tmp["conversation_id"] = self.conversations[jid].id
		tmp["jid"] = jid
		tmp["data"] = []
		tmp['conversation'] = self.conversations[jid].getModelData();
		tmp['conversation']['unreadCount'] = tmp['conversation']['new']
		
		foreignKeyField = "conversation_id" if self.conversations[jid].type=="single" else "groupconversation_id";
		tmp['conversation']['remainingMessagesCount'] = messages[0].findCount({"id<":self.conversations[jid].messages[0].id,foreignKeyField:self.conversations[jid].id})
		
		for m in messages:
			msg = m.getModelData()
			msg['formattedDate'] = datetime.datetime.fromtimestamp(int(msg['timestamp'])/1000).strftime('%d-%m-%Y %H:%M')
			msg['content'] = msg['content'].decode('utf-8');
			msg['jid'] = jid
			msg['contact'] = m.getContact().getModelData()
			media = m.getMedia()
			msg['media']= media.getModelData() if media is not None else None
			msg['msg_id'] = msg['id']
			tmp["data"].append(msg)
			
		self.messagesReady.emit(tmp,reorder);
			
	
	
	def getUnsent(self):
		messages = self.store.Message.findAll(conditions={"status":self.store.Message.STATUS_PENDING,"type":self.store.Message.TYPE_SENT},order=["id ASC"]);
		
		
		groupMessages = self.store.Groupmessage.findAll(conditions={"status":self.store.Message.STATUS_PENDING,"type":self.store.Message.TYPE_SENT},order=["id ASC"]);
		
		
		
		messages.extend(groupMessages);
		
		return messages	
		
	
	def get(self,key):
		
		try:
			key.remote_jid.index('-')
			return self.store.Groupmessage.findFirst({"key":key.toString()});
			
		except ValueError:
			return self.store.Message.findFirst({"key":key.toString()});
		
	def getG(self,key):
		return self.store.Groupmessage.findFirst({"key":key});
		
	def getOrCreateConversationByJid(self,jid):
		
		if self.conversations.has_key(jid):
			return self.conversations[jid];
		
		groupTest = jid.split('-');
		if len(groupTest)==2:
			conv = self.store.Groupconversation.findFirst(conditions={"jid":jid})
			
			if conv is None:
				conv = self.store.Groupconversation.create()
				conv.setData({"jid":jid})
				conv.save()
			
		else:
			contact = self.store.Contact.getOrCreateContactByJid(jid)
			conv = self.store.Conversation.findFirst(conditions={"contact_id":contact.id})
		
			if conv is None:
				conv = self.store.Conversation.create()
				conv.setData({"contact_id":contact.id})
				conv.save()
		
		return conv
	
	def generateKey(self,message):
		
		conv = message.getConversation();
		jid = conv.getJid();
		
		#key = str(int(time.time()))+"-"+MessageStore.currId;
		localKey = Key(jid,True,str(int(time.time()))+"-"+str(MessageStore.currKeyId))
		
		while self.get(localKey) is not None:
			MessageStore.currKeyId += 1
			localKey = Key(jid,True,str(int(time.time()))+"-"+str(MessageStore.currKeyId))
			
		#message.key = localKey
		
		return localKey;
	
	def updateStatus(self,message,status):
		self._d("UPDATING STATUS TO "+str(status));
		message.status = status
		message.save()
		conversation = message.getConversation()
		
		jid = conversation.getJid();
		
		index = self.getMessageIndex(jid,message.id);
		
		if index >= 0:
			#message is loaded
			self.conversations[jid].messages[index] = message
			self.messageStatusUpdated.emit(jid,message.id,status)
	
	def getMessageIndex(self,jid,msg_id):
		if self.conversations.has_key(jid):
			messages = self.conversations[jid].messages;
			for i in range(0,len(messages)):
				if msg_id == messages[i].id:
					return i
		
		return -1
	
	
	def isGroupJid(self,jid):
		try:
			jid.index('-')
			return True
		except:
			return False
	
	def createMessage(self,jid = None):
		'''
		Message creator. If given a jid, it detects the message type (normal/group) and allocates a conversation for it.
				 Otherwise, returns a normal message
		'''
		if jid is not None:
			conversation =  self.getOrCreateConversationByJid(jid);
			if self.isGroupJid(jid):
				msg = self.store.Groupmessage.create()
				msg.groupconversation_id = conversation.id
				msg.Groupconversation = conversation
				
				
			else:
				msg = self.store.Message.create()
				msg.conversation_id = conversation.id
				msg.Conversation = conversation
		else:
			msg = self.store.Message.create()
		
		return msg
		

	def pushMessage(self,jid,message,signal=True):
		
		conversationLoaded = self.conversations.has_key(jid);
		
		conversation = self.getOrCreateConversationByJid(jid);
		message.setConversation(conversation)
		
		if message.key is None:
			message.key = self.generateKey(message).toString();
		#check not duplicate
		#if not self.store.Message.findFirst({"key",message.key}):
		
		if message.Media is not None and message.Media.mediatype_id:
			#message.Media.setMessageId(message.id)
			message.Media.save()
			message.media_id = message.Media.id
			
		message.save();
	
		self.conversations[jid] = conversation #to rebind new unread counts
		self.conversations[jid].messages.append(message)
	
		if signal:
			if not conversationLoaded:
				self.sendConversationReady(jid)
		
			self.sendMessagesReady(jid,[message]);
			
			
	def updateGroupInfo(self,jid,ownerJid,subject,subjectOwnerJid,subjectT,creation):
		
		conversation = self.getOrCreateConversationByJid(jid);
		
		owner = self.store.Contact.getOrCreateContactByJid(ownerJid)
		subjectOwner = self.store.Contact.getOrCreateContactByJid(subjectOwnerJid)
		
		conversation.contact_id = owner.id
		conversation.subject = subject
		conversation.subject_owner = subjectOwner.id
		conversation.subject_timestamp = subjectT
		conversation.created = creation
		
		conversation.save()
		
		self.conversations[jid] = conversation;
		self.sendConversationReady(jid)


	def messageExists(self, jid, msgId):
		k = Key(jid, False, msgId)
		return self.get(k) is not None

	def keyExists(self, k):
		return self.get(k) is not None
		
		
		
class Key():
	def __init__(self,remote_jid, from_me,idd):
		self.remote_jid = remote_jid;
		self.from_me = from_me;
		self.id = idd;

	def toString(self):
		return "Key(idd=\"" + self.id + "\", from_me=" + str(self.from_me) + ", remote_jid=\"" + self.remote_jid + "\")";
		
