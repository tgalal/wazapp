'''
Copyright (c) 2012, Tarek Galal <tarek@wazapp.im>

This file is part of Wazapp, an IM application for Meego Harmattan platform that
allows communication with Whatsapp users

Wazapp is free software: you can redistribute it and/or modify it under the 
terms of the GNU General Public License as published by the Free Software 
Foundation, either version 3 of the License, or (at your option) any later 
version.

Wazapp is distributed in the hope that it will be useful, but WITHOUT ANY 
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A 
PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with 
Wazapp. If not, see http://www.gnu.org/licenses/.
'''
from Models.account import Account as WAAccount;
from Accounts import *

from utilities import Utilities

class AccountsManager():
	def __init__():
		''''''
	@staticmethod
	def getCurrentAccount():
		account = AccountsManager.findAccount()
		
		return account
		
	
	@staticmethod	
	def findAccount():
		imsi = Utilities.getImsi()
		print "Looking for %s "%(imsi)
		m = Manager()
		accountIds = m.accountList()
		
		for aId in accountIds:
			a = m.account(aId)
			services = a.services()
			for s in services:
				if s.name() == "waxmpp":
					print "found waxmpp account with imsi: %s"%(a.valueAsString("imsi"))
					if a.valueAsString("imsi") == imsi:
						account = a
						waaccount = WAAccount(account.valueAsString("cc"),account.valueAsString("phoneNumber"),account.valueAsString("username"),account.valueAsString("status"),account.valueAsString("pushName"),account.valueAsString("imsi"),account.valueAsString("password"));
						waaccount.setAccountInstance(a)
						
						return waaccount
		
		return None
		
		
