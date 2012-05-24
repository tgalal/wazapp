'''
Copyright (c) 2012, Tarek Galal <tarek@wazapp.im>

This file is part of Wazapp, an IM application for Meego Harmattan platform that allows communication with Whatsapp users

Wazapp is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

Wazapp is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with Wazapp. If not, see http://www.gnu.org/licenses/.
'''
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
		
	
