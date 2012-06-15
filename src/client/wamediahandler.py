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

import httplib,urllib2,os,sys
from constants import WAConstants

from PySide import QtCore
from PySide.QtCore import QThread

from PySide.QtCore import *
from PySide.QtGui import *
from wadebug import MediaHandlerDebug

class WAMediaHandler(QObject):
	progressUpdated = QtCore.Signal(int,str,int) #%,jid,message.id
	error = QtCore.Signal(str,int)
	success = QtCore.Signal(str,int,str)
	
	def __init__(self,jid,message_id,url,mediaType_id):
		
		_d = WAMediaDebug();
		self._d = _d.d;
		path = self.getSavePath(mediaType_id);
		
		filename = url.split('/')[-1]
		
		if path is None:
			raise Exception("Unknown media type")
		
		if not os.path.exists(path):
			os.makedirs(path)
		
		self.httpHandler = WAHTTPHandler(url,path+"/"+filename)
		self.httpHandler.progressUpdated.connect(self.onProgressUpdated)
		self.httpHandler.success.connect(self.onSuccess)
		self.httpHandler.error.connect(self.onError)
		
		self.message_id = message_id
		self.jid = jid
		
		super(WAMediaHandler,self).__init__();
	
	
	def onError(self):
		self.error.emit(self.jid,self.message_id)
	
	def onSuccess(self,savePath):
		self.success.emit(self.jid,self.message_id,savePath)	
	
	def onProgressUpdated(self,progress):
		self.progressUpdated.emit(progress,self.jid,self.message_id);
	
	def pull(self):
		self.httpHandler.action = "pull"
		self.httpHandler.start()
		
	def push(self):
		self.httpHandler.action = "push"
		self.httpHandler.start()
		
	def getSavePath(self,mediatype_id):
		
		if mediatype_id == WAConstants.MEDIA_TYPE_IMAGE:
			return WAConstants.IMAGE_PATH
		
		if mediatype_id == WAConstants.MEDIA_TYPE_AUDIO:
			return WAConstants.AUDIO_PATH
		
		if mediatype_id == WAConstants.MEDIA_TYPE_VIDEO:
			return WAConstants.VIDEO_PATH

		if mediatype_id == WAConstants.MEDIA_TYPE_VCARD:
			return WAConstants.VCARD_PATH
			
		return None

class WAVCardHandler(WAMediaHandler):
	
	def __init__(self,jid,message_id,data):
		
		self.contactName = name
		self.contactData = data
		
		super(WAVCardHandler,self).__init__(jid,message_id,data,WAConstants.MEDIA_TYPE_VCARD)
	
	def pull(self):
		path = self.getSavePath(WAConstants.MEDIA_TYPE_VCARD);
		savePath = "%s/%i-%s.vcf"%(path,self.message_id,self.contactName)
		textFile = open(savePath, "w")
		#n = msgdata.find(">") +1
		#msgdata = msgdata[n:]
		#text_file.write(msgdata.replace("</vcard>",""))
		textFile.write(self.contactData)
		textFile.close()
		self.success.emit(self.jid,self.message_id,savePath)
		
		


class WAHTTPHandler(QThread):
	
	error = QtCore.Signal();
	success = QtCore.Signal(str);
	progressUpdated = QtCore.Signal(int)
	
	def __init__(self,url,savePath,action="pull"):
		self.url = url
		self.savePath = savePath
		self.action = "push" if action =="push" else "pull"
		super(WAHTTPHandler,self).__init__();
		
		
		
	def run(self):
		if self.action == "pull":
			self.pull(self.url,self.savePath);
			
			
			

	def pull(self,url,savePath):
		try:
			u = urllib2.urlopen(url)
			f = open(savePath, 'wb')
			meta = u.info()
			fileSize = int(meta.getheaders("Content-Length")[0])
		
			fileSizeDl = 0
			blockSz = 8192
			lastEmit = 0
			while True:
			
			
				buffer = u.read(blockSz)
				if not buffer:
					break

				fileSizeDl += len(buffer)
				f.write(buffer)
				status = (fileSizeDl * 100 / fileSize)
			
				if lastEmit != status:
					self.progressUpdated.emit(status)
					lastEmit = status;
			
			self.success.emit(self.savePath)
			
		except:
			self.error.emit()


def onSuccess(jid,msgId):
	print "SUCCESS: %s %i"%(jid,msgId)
	
def onError(jid,msgId):
	print "ERROR: %s %i"%(jid,msgId)

def onProgress(amnt, jid,message_id):
	status = "%s %i: %i"%(jid,message_id,amnt)
	#status += chr(8)*(len(status)+1)
	print status

if __name__=="__main__":
	app = QApplication(sys.argv)
	
	wam = WAMediaHandler("tare2.galal@gmail.com", 12, "http://download.thinkbroadband.com/10MB.zip","downloaded.zip",2);
	
	wam.progressUpdated.connect(onProgress);
	wam.success.connect(onSuccess)
	wam.error.connect(onError)
	
	wam.pull();
	sys.exit(app.exec_())
	
