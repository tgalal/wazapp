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
from utilities import Utilities
from wamediauploader import WAMediaUploader
from PySide.QtCore import QObject
from PySide import QtCore;
import thread

class WAMediaUpload(WAMediaUploader):

	def __init__(self,store):
		self.store = store;
		self.base_url = "mms.whatsapp.net";
		self.req_file = "/client/iphone/upload.php";
		super(WAMediaUpload,self).__init__();

	def upload(self, image, name):
		print "TRYING TO UPLOAD FILE..." + image;
		'''self.clearParams();
		self.addParam("me",self.store.account.phoneNumber);
		self.addParam("s",msg)
		self.addParam("cc","31")
		data = self.sendRequest();'''
		data = self.sendRequest(image, name);
		self.exit();

		
	def onRefreshing(self):
		self.start();

	def run(self):
		try:
			self.sync();
		except:
			print sys.exc_info()[1]
		#self.exec_();

if __name__ == "__main__":
	uf = WAMediaUpload();
	uf.start();
