from model import Model;

class SingleConversation(Model):
	#MUST INIT BEFORE INITING MESSAGES
	def __init__(self):
		''''''
	
	def getContact(self):
		if not self.contact_id:
			return 0
			
		if not self.Contact.id:
			self.Contact = self.Contact.read(self.contact_id);
		
		return self.Contact
