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
import base64

class AccountsManager():

	manager = Manager()
		
	@staticmethod
	def getCurrentAccount():
		account = AccountsManager.findAccount()
		
		return account

	@staticmethod
	def setPushName(pushname):
		d = AccountsDebug()
		_d = d.d;
		_d("Finding account for push name update")
		account = AccountsManager.findAccount()
		if account:
			account.accountInstance.setValue("pushName",pushname)
			account.accountInstance.sync()

	@staticmethod
	def getAccountById(accountId):
		account = AccountsManager.manager.account(accountId)
		waaccount = WAAccount(account.valueAsString("cc"),account.valueAsString("phoneNumber"),account.valueAsString("username"),account.valueAsString("status"),account.valueAsString("pushName"),account.valueAsString("imsi"),account.valueAsString("password"));
		waaccount.setAccountInstance(account)
		return waaccount

	@staticmethod	
	def findAccount():
		d = AccountsDebug()
		_d = d.d;
		imsi = Utilities.getImsi()
		_d("Looking for %s "%(imsi))
		accountIds = AccountsManager.manager.accountList()

		for aId in accountIds:
			a = AccountsManager.manager.account(aId)
			services = a.services()
			for s in services:
				if s.name() in ("waxmpp"):
					_d("found waxmpp account with imsi: %s"%(a.valueAsString("imsi")))
					if a.valueAsString("imsi") == imsi:
						account = a
						waaccount = WAAccount(account.valueAsString("cc"),
											account.valueAsString("phoneNumber"),
											account.valueAsString("username"),
											account.valueAsString("status"),
											account.valueAsString("pushName"),
											account.valueAsString("imsi"),
											base64.b64decode(account.valueAsString("password")) 
												if account.valueAsString("penc") == "b64" 
												else account.valueAsString("password")); #to ensure backwards compatibility for non-blocked accounts

						if account.valueAsString("wazapp_version"): #rest of data exist
							waaccount.setExtraData(account.valueAsString("kind"), 
													account.valueAsString("expiration"),
													account.valueAsString("cost"), 
													account.valueAsString("currency"),
													account.valueAsString("price"), 
													account.valueAsString("price_expiration"))
						
						waaccount.setAccountInstance(a)
						
						return waaccount
		
		return None
		
		
