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
from wadebug import MessageStoreDebug


class MessageStore(QObject):


	messageStatusUpdated = QtCore.Signal(str,int,int);
	messagesReady = QtCore.Signal(dict);
	conversationReady = QtCore.Signal(dict);
	
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

	
	
	
	def loadConversations(self):
		conversations = self.store.ConversationManager.findAll();
		self._d("init load convs")
		for c in conversations:
			self._d("loading messages")
			jid = c.getJid();
			c.loadMessages();
			self.conversations[jid] = c
			
			print "loaded messages"
			
			self.sendConversationReady(jid);
			self.sendMessagesReady(jid,c.messages);
		

	def loadMessages(self,jid,offset=0, limit=10):
	
		self._d("Load more messages requested");
		
		messages = self.conversations[jid].loadMessages(offset,limit);
		
		self.sendMessagesReady(jid,messages);
		return messages
	
	
	def sendConversationReady(self,jid):
		tmp = {}
		'''
			jid,subject,id,contacts..etc
			messages
		'''
		c = self.conversations[jid];
		tmp = c.getModelData();
		tmp["isGroup"] = c.isGroup()
		tmp["jid"]=c.getJid();
		
		if c.isGroup():
			tmp["contacts"]=c.getContacts();
			
		self.conversationReady.emit(tmp);
	
	def sendMessagesReady(self,jid,messages):
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
			
		self.messagesReady.emit(tmp);
			
	
	
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
		
class Key():
	def __init__(self,remote_jid, from_me,idd):
		self.remote_jid = remote_jid;
		self.from_me = from_me;
		self.id = idd;

	
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

		return True;


	def hashCode(self):
		prime = 31;
		result = 1;
		result = 31 * result + (1231 if self.from_me else 1237)
		result = 31 * result + (0 if self.id is None else Utilities.hashCode(self.id));
		result = 31 * result + (0 if self.remote_jid is None else Utilities.hashCode(self.remote_jid));
	


	def toString(self):
		return "Key(idd=\"" + self.id + "\", from_me=" + str(self.from_me) + ", remote_jid=\"" + self.remote_jid + "\")";
		
