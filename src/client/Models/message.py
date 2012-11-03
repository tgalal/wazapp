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
import time;
from model import Model;
from mediatype import Mediatype

class MessageBase(Model):
	
	TYPE_RECEIVED = 0
	TYPE_SENT = 1
	
	STATUS_PENDING = 0
	STATUS_SENT = 1
	STATUS_DELIVERED = 2
	
	
	generating_id = 0;
	generating_header = str(int(time.time()))+"-";
	
	def __init__(self):
		
		self.TYPE_RECEIVED = Message.TYPE_RECEIVED
		self.TYPE_SENT = Message.TYPE_SENT
		self.STATUS_PENDING = Message.STATUS_PENDING
		self.STATUS_SENT = Message.STATUS_SENT
		self.STATUS_DELIVERED = Message.STATUS_DELIVERED
		self.Media = None
		self.media_id = None

		super(MessageBase,self).__init__();
		
		
	
	def getMedia(self):
		if self.media_id is not None:
			if self.Media.id is not None and self.Media.id != 0:
				return self.Media
			else:
				media = self.store.Media.create()
				self.Media = media.findFirst({"id":self.media_id})
				return self.Media

		return None;
		
		
	def setConversation(self,conversation):
		self.conversation_id = conversation.id
		self.Conversation = conversation
	
	def getConversation(self):
		if not self.conversation_id:
			return 0;
			
		if not self.Conversation.id:
			self.Conversation = self.Conversation.read(self.conversation_id)
		
		return self.Conversation	
		
class Message(MessageBase):

	def storeConnected(self):
		self.Conversation = self.store.Conversation
		self.conn.text_factory = str
			
	def getContact(self):
		conversation = self.getConversation();
		
		if not conversation.Contact.id:
			conversation.Contact = conversation.getContact();
		
		
		return conversation.Contact	
			
class Groupmessage(MessageBase):


	def storeConnected(self):
		self.Conversation = self.store.Groupconversation
		self.conn.text_factory = str
	
	
	def setConversation(self,conversation):
		self.groupconversation_id = conversation.id
		self.Groupconversation = conversation
	
	def setContact(self,contact):
		self.contact_id = contact.id;
		self.Contact = contact
		
	
		
	
	def getConversation(self):
		if not self.groupconversation_id:
			return 0;
			
		if not self.Groupconversation.id:
			self.Groupconversation = self.Groupconversation.read(self.groupconversation_id)
		
		return self.Groupconversation	
	
	def getContact(self):
		if not self.contact_id:
			return 0
			
		if not self.Contact.id:
			self.Contact = self.Contact.read(self.contact_id);
		
		return self.Contact
	
