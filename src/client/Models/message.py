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
		if self.getConversation():
			if not self.Conversation.Contact.id:
				self.Contact = self.Conversation.getContact();
		else:
			return 0
		
		return self.Contact	
			
class GroupMessage(MessageBase):

	def storeConnected(self):
		self.Conversation = self.store.GroupConversation
		self.conn.text_factory = str
