import time;
from model import Model;

class Message(Model):
	
	TYPE_RECEIVED = 0
	TYPE_SENT = 1
	
	STATUS_PENDING = 0
	STATUS_SENT = 1
	STATUS_DELIVERED = 2
	
	PARTY_SINGLE = 0
	PARTY_GROUP = 1
	
	generating_id = 0;
	generating_header = str(int(time.time()))+"-";
	
	def __init__(self, convType= PARTY_SINGLE):
		self.convType = convType
			
			
		
		self.TYPE_RECEIVED = Message.TYPE_RECEIVED
		self.TYPE_SENT = Message.TYPE_SENT
		self.STATUS_PENDING = Message.STATUS_PENDING
		self.STATUS_SENT = Message.STATUS_SENT
		self.STATUS_DELIVERED = Message.STATUS_DELIVERED
	
	def storeConnected(self):
		if self.convType == Message.PARTY_SINGLE:
			self.Conversation = self.store.SingleConversation
			
		self.conn.text_factory = str
			
		
	def getContact(self):
		if self.getConversation():
			if not self.Conversation.Contact.id:
				self.Contact = self.Conversation.getContact();
		else:
			return 0
		
		return self.Contact	
			
	def getConversation(self):
		if not self.conversation_id:
			return 0;
			
		if not self.Conversation.id:
			self.Conversation = self.Conversation.read(self.conversation_id)
		
		return self.Conversation
		
			
