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
from model import Model;

class Conversation(Model):
	#MUST INIT BEFORE INITING MESSAGES
	def __init__(self):
		''''''
		self.type="single"
		self.messages = []
	
	def getContact(self):
		if not self.contact_id:
			return 0
			
		if not self.Contact.id:
			self.Contact = self.Contact.read(self.contact_id);
		
		return self.Contact
		
	def getJid(self):
		if not self.contact_id:
			convObj =  self.store.Conversation.getById(self.id);
			contact = convObj.getContact()
		else:
			contact = self.getContact()
			
		return contact.jid
	
	def clearNew(self):
		self.new = 0;
		self.save();
		
	def incrementNew(self):
		self.new = self.new+1;
		self.save();
		
	def getLastMessage(self):
		messages = self.store.Message.findAll(conditions = {"conversation_id":self.id}, order=["timestamp DESC"], first=0, limit=1)
		if len(messages):
			self.lastMessage = messages[0];
			return self.lastMessage;
		
		self.lastMessage = self.store.Message.create();
		self.lastMessage.timestamp = 0
		return None;
		
		
	def loadMessages(self,offset = 0,first=0,limit=50):
		print "find some messages"
		conditions = {"conversation_id":self.id}
		
		if offset:
			conditions["id<",offset];
		
		messages = self.store.Message.findAll(conditions,order=["id DESC"],first=first,limit=limit)
		
		messages.reverse();
		
		print "found some messages"
		
		cpy = messages[:]
		messages.extend(self.messages);
		self.messages = messages
		
		return cpy

class Groupconversation(Model):
	
	def __init__(self):
		print "init a group convo"
		self.type="group"
		self.messages = []
	
	def clearNew(self):
		self.new = 0;
		self.save();
	
	def incrementNew(self):
		self.new = self.new+1;
		self.save();
	
	def getJid(self):
		return self.jid;
		
		
	def getLastMessage(self):
		messages = self.store.Groupmessage.findAll(conditions = {"groupconversation_id":self.id}, order=["timestamp DESC"], first=0, limit=1)
		if len(messages):
			self.lastMessage = messages[0];
			return self.lastMessage;
		
		self.lastMessage = self.store.Groupmessage.create();
		self.lastMessage.timestamp = 0
		return None;
		
	def loadMessages(self,offset = 0,first=0,limit=50):
		print "group: find some messages"
		conditions = {"groupconversation_id":self.id}
		
		if offset:
			conditions["id<",offset];
		
		messages = self.store.Groupmessage.findAll(conditions,order=["id DESC"],first=first,limit=limit)
		
		messages.reverse();
		
		print "found some messages"
		
		cpy = messages[:]
		messages.extend(self.messages);
		self.messages = messages
		
		return cpy
	

class ConversationManager():
	def __init__(self):
		''''''
	
	def setStore(self,store):
		self.store = store;
	
	def findAll(self):
		convs = self.store.Conversation.findAll();
		gconvs = self.store.Groupconversation.findAll();
		
		convs.extend(gconvs);
		
		for c in convs:
			c.getLastMessage();
		
		
		convs.sort(key=lambda k: k.lastMessage.timestamp,reverse = True);
		
		return convs;
		
		
		
class GroupconversationsContacts(Model):
	def __init__(self):
		''''''

	
		
		
		
		
		
		
		
		
		
		
		
