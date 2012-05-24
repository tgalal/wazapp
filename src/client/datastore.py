import abc
from accountsmanager import AccountsManager;
class DataStore():
	

	
	def __init__(self,current_id):
		self.user_id = current_id;
		self.account = AccountsManager.getCurrentAccount();

	__metaclass__ = abc.ABCMeta

	
	@abc.abstractmethod
	def getContacts(self):
		'''get contacts'''

	def saveContact(self,contact):
		'''save contact'''

	def getConversation(self,contact_id):
		'''fetches chats for this contact'''

	def deleteConversation(self,contact_id):
		'''deletes all chats for this contact'''
	
	def logChat(self,FMsg):
		'''logs a message'''
		
	
