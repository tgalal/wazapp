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
from Models.account import Account as WAAccount;
from Accounts import *

from utilities import Utilities


from wadebug import AccountsDebug;

class AccountsManager():
	def __init__():
		_d = AccountsDebug()
		self._d = _d.d;
		
	@staticmethod
	def getCurrentAccount():
		account = AccountsManager.findAccount()
		
		return account
		
	
	@staticmethod	
	def findAccount():
		d = AccountsDebug()
		_d = d.d;
		imsi = Utilities.getImsi()
		_d("Looking for %s "%(imsi))
		m = Manager()
		accountIds = m.accountList()
		
		for aId in accountIds:
			a = m.account(aId)
			services = a.services()
			for s in services:
				if s.name() == "waxmpp":
					_d("found waxmpp account with imsi: %s"%(a.valueAsString("imsi")))
					if a.valueAsString("imsi") == imsi:
						account = a
						waaccount = WAAccount(account.valueAsString("cc"),account.valueAsString("phoneNumber"),account.valueAsString("username"),account.valueAsString("status"),account.valueAsString("pushName"),account.valueAsString("imsi"),account.valueAsString("password"));
						waaccount.setAccountInstance(a)
						
						return waaccount
		
		return None
		
		
