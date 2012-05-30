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
import time
import datetime

class MessageStore(QObject):


	messageStatusUpdated = QtCore.Signal(int,int);
	messagesReady = QtCore.Signal(dict);
	
	currKeyId = 0

	def __init__(self,dbstore):
		super(MessageStore,self).__init__();
		
		self.store = dbstore
		self.conversations = {}
		#get unique contactId from messages
		#messages = self.store.Message.findAll(fields=["DISTINCT contact_id"])
		#for m in messages:
		#	self.loadMessages(m.getContact());
		#load messages for jids of those ids
		
		
		
	
	def deleteConversation(self,jid):
		contact = self.store.Contact.findFirst(conditions={"jid":jid})
		if contact is None:
			return
		
		conv = self.store.SingleConversation.findFirst(conditions={"contact_id":contact.id})
		
		if conv is not None:
			if self.conversations.has_key("conversation_"+str(conv.id)):
				del self.conversations["conversation_"+str(conv.id)]
			self.store.Message.delete({"conversation_id":conv.id})
			conv.delete();
	
	def loadConversations(self):
		conversations = self.store.SingleConversation.findAll();
		print "init load convs"
		for c in conversations:
			print "loading messages"
			self.loadMessages(c.id)
			print "loaded messages"
		
	
	def sendMessagesReady(self,conversationId, offset = 0,limit=50):
		#sends out chunks of conversation, prepared upon request
		
		conv = self.conversations["conversation_"+str(conversationId)]
		
		

		tmp = {}
		tmp["conversation_id"] = conversationId
		convObj =  self.store.SingleConversation.getById(conversationId);
		contact = convObj.getContact()
		tmp["user_id"] = contact.jid
		tmp["data"] = []
		
		
		
		if len(conv) < offset+limit:
			limit = len(conv)-offset
		
		offset = len(conv) - offset
		if len(conv) < offset:
			self.messagesReady.emit(tmp)
			return
		
		
		
		
		for i in range(offset-limit,offset):
			msg = conv[i].getModelData()
			msg['formattedDate'] = datetime.datetime.fromtimestamp(int(msg['timestamp'])/1000).strftime('%d-%m-%Y %H:%M')
			msg['content'] = msg['content'].decode('utf-8');
			msg['jid'] = contact.jid
			tmp["data"].append(msg)
			
			
		self.messagesReady.emit(tmp);
			
	
	
	def getUnsent(self):
		messages = self.store.Message.findAll(conditions={"status":self.store.Message.STATUS_PENDING,"type":self.store.Message.TYPE_SENT},order=["id ASC"]);
		return messages	
		
	
	def get(self,key):
		return self.store.Message.findFirst({"key":key});
		
	def getOrCreateConversationByJid(self,jid):
		contact = self.store.Contact.findFirst(conditions={"jid":jid})
		if contact is None:
			contact = self.store.Contact.create();
			contact.setData({"jid":jid,"number":jid.split('@')[0]})
			contact.save()
		
		conv = self.store.SingleConversation.findFirst(conditions={"contact_id":contact.id})
		
		if conv is None:
			conv = self.store.SingleConversation.create()
			conv.setData({"contact_id":contact.id})
			conv.save()
		
		return conv
	
	def generateKey(self,message):
		
		conv = message.getConversation();
		contact = conv.getContact();
		
		#key = str(int(time.time()))+"-"+MessageStore.currId;
		localKey = Key(contact.jid,True,str(int(time.time()))+"-"+str(MessageStore.currKeyId),"")
		
		while self.get(localKey) is not None:
			MessageStore.currKeyId += 1
			localKey = Key(contact.jid,True,str(int(time.time()))+"-"+str(MessageStore.currKeyId),"")
			
		#message.key = localKey
		
		return localKey;
		
	def loadMessages(self,conversation_id):
		print "find all messages"
		messages = self.store.Message.findAll(conditions = {"conversation_id":conversation_id},order=["id ASC"])
		print "found all messages"
		self.conversations["conversation_"+str(conversation_id)] = messages
		
		self.sendMessagesReady(conversation_id);
		return messages
	
	
	def updateStatus(self,message,status):
		print "UPDATING STATUS TO "+str(status);
		message.status = status
		message.save()
		conversation = message.getConversation()
		
		index = self.getMessageIndex(conversation.id,message.id);
		if index >= 0:
			#message is loaded
			self.conversations["conversation_"+str(conversation.id)][index] = message
			self.messageStatusUpdated.emit(message.id,status)
	
	def getMessageIndex(self,conversation_id,msg_id):
		if self.conversations.has_key("conversation_"+str(conversation_id)):
			messages = self.conversations["conversation_"+str(conversation_id)];
			for i in range(0,len(messages)):
				if msg_id == messages[i].id:
					return i
		
		return -1
			

	def pushMessage(self,message):
		conv = message.getConversation();
		
		if message.key is None:
			message.key = self.generateKey(message).toString();
		#check not duplicate
		#if not self.store.Message.findFirst({"key",message.key}):
		message.save();
		
		if self.conversations.has_key("conversation_"+str(conv.id)):
			self.conversations["conversation_"+str(conv.id)].append(message)
		else:
			self.conversations["conversation_"+str(conv.id)] = [message]
			
		self.sendMessagesReady(conv.id, offset = 0,limit=1)
		
class Key():
	def __init__(self,remote_jid, from_me,idd, remote_author):
		self.remote_jid = remote_jid;
		self.from_me = from_me;
		self.id = idd;
		self.remote_author = remote_author;

	
	def exists(self, paramKey):
		try:
			WAXMPP.message_store.get(paramKey)
			return 1
		except KeyError:
			return 0
     


	def equals(obj):
		if self == obj:
			return True;
		if self is None:
			return false;
		if type(self) != type(obj):
			return False;
		other = obj;
		if self.from_me != other.from_me:
			return false;
		if self.id is None:
			if other.id is not None:
				return False;
		elif self.id != other.id:
			return False;
		if self.remote_jid is None:
			if other.remote_jid is not None:
				return False;
		elif self.remote_jid != other.remote_jid:
			return False;
		if self.remote_author is None:
			if other.remote_author is not None:
				return False;
		elif self.remote_author != other.remote_author:
			return False;

		return True;


	def hashCode(self):
		prime = 31;
		result = 1;
		result = 31 * result + (1231 if self.from_me else 1237)
		result = 31 * result + (0 if self.id is None else Utilities.hashCode(self.id));
		result = 31 * result + (0 if self.remote_jid is None else Utilities.hashCode(self.remote_jid));
		result = 31 * result + (0 if self.remote_author is None else Utilities.hashCode(self.remote_author));
	


	def toString(self):
		return "Key(idd=\"" + self.id + "\", from_me=" + str(self.from_me) + ", remote_jid=\"" + self.remote_jid + "\", remote_author=\"" + self.remote_author + "\")";
		
