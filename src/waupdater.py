from wajsonrequest import WAJsonRequest
from PySide import QtCore
from distutils.version import StrictVersion
from utilities import Utilities
class WAUpdater(WAJsonRequest):
	updateAvailable = QtCore.Signal(dict)
	
	def __init__(self):
		self.base_url = "wazapp.im"
		self.req_file = "/whatsup/"
		
	
		super(WAUpdater,self).__init__();
	
	def run(self):
		print "Checking for updates"
		res = self.sendRequest()
		if res:
			#current = self.version.split('.');
			#latest = res['v'].split('.')
			if StrictVersion(str(res['l'])) > Utilities.waversion:
				print "UPDATE AVAILABLE!"
				self.updateAvailable.emit(res)
