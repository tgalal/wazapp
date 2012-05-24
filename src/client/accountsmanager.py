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
		
		
