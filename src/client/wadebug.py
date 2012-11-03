from constants import WAConstants
import time

class WADebug():
	
	def __init__(self):
		self.enabled = True
		
		cname = self.__class__.__name__
		self.type= cname[:cname.index("Debug")]
	
	@staticmethod
	def attach(instance):
		d = WADebug();
		d.type = instance.__class__.__name__;
		instance._d = d.d
	
	@staticmethod
	def stdDebug(message,messageType="General"):
		#enabledTypes = ["general","stanzareader","sql","conn","waxmpp","wamanager","walogin","waupdater","messagestore"];
		disabledTypes = ["sql"]
		if messageType.lower() not in disabledTypes:
			try:
				print message;
			except UnicodeEncodeError:
				print "Skipped debug message because of UnicodeEncodeError"
	
	def formatMessage(self,message):
		#default = "{type}:{time}:\t{message}"
		t = time.time()
		message = "%s:\t%s"%(self.type,message)
		return message

	def debug(self,message):
		if self.enabled:
			WADebug.stdDebug(self.formatMessage(message),self.type)
		
	def d(self,message):#shorthand
		self.debug(message)
		message = message
		logline = "" #self.formatMessage(message)+"\n"
		if not "Sql:" in logline:
			try:
				# This tries to open an existing file but creates a new file if necessary.
				logfile = open(WAConstants.STORE_PATH + "/log.txt", "a")
				try:
					logfile.write(logline)
				finally:
					logfile.close()
			except IOError:
				pass

class JsonRequestDebug(WADebug):
	pass

class StatusRequestDebug(WADebug):
	pass

class EventHandlerDebug(WADebug):
	pass

class WaxmppDebug(WADebug):
	pass

class SqlDebug(WADebug):
	pass
	
class ConnDebug(WADebug):
	pass

class GeneralDebug(WADebug):
	pass

class ManagerDebug(WADebug):
	pass

class NotifierDebug(WADebug):
	pass

class MessageStoreDebug(WADebug):
	pass
	
class ConnMonDebug(WADebug):
	pass
	
class ContactsDebug(WADebug):
	pass

class UIDebug(WADebug):
	pass

class UpdaterDebug(WADebug):
	pass

class MediaHandlerDebug(WADebug):
	pass
	
class AccountsDebug(WADebug):
	pass
	
class LoginDebug(WADebug):
	pass
	
class WARequestDebug(WADebug):
	pass
	
		
