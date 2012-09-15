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
from wadebug import WADebug

from connengine import MySocketConnection
import os, mimetypes, socket, hashlib, ssl, urllib
from time import sleep

class WAMediaHandler(QObject):
	progressUpdated = QtCore.Signal(int,int) #%,jid,message.id
	error = QtCore.Signal(str,int,int)
	success = QtCore.Signal(str,int,str,str,int)
	
	def __init__(self,jid,message_id,url,mediaType_id,mediaId,account,resize=False):
		
		WADebug.attach(self);
		path = self.getSavePath(mediaType_id);
		
		filename = url.split('/')[-1]
		
		if path is None:
			raise Exception("Unknown media type")
		
		if not os.path.exists(path):
			os.makedirs(path)
		
		self.httpHandler = WAHTTPHandler(jid,account,mediaId,resize,url,path+"/"+filename)
		self.httpHandler.progressUpdated.connect(self.onProgressUpdated)
		self.httpHandler.success.connect(self.onSuccess)
		self.httpHandler.error.connect(self.onError)
		
		self.mediaId = mediaId
		self.message_id = message_id
		self.jid = jid

		super(WAMediaHandler,self).__init__();
	
	
	def onError(self):
		self.error.emit(self.jid,self.message_id,self.mediaId)
	
	def onSuccess(self, data, action):
		self.success.emit(self.jid,self.message_id,data,action,self.mediaId)	
	
	def onProgressUpdated(self,progress):
		self.progressUpdated.emit(progress,self.mediaId);
	
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
	success = QtCore.Signal(str,str);
	progressUpdated = QtCore.Signal(int)
	
	def __init__(self,jid,account,mediaId,resize,url,savePath,action="pull"):
		self.url = url
		self.savePath = savePath
		self.jid = jid
		self.account = account
		self.action = "push" if action =="push" else "pull"
		self.resizeImages = resize
		self.mediaId = mediaId
		super(WAHTTPHandler,self).__init__();
		
		
		
	def run(self):
		if self.action == "pull":
			self.pull(self.url,self.savePath);
		if self.action == "push":
			self.push(self.url);
			
	
	def push(self,image):
		#image = urllib.quote(image)
		image = image.replace("file://","")

		self.sock = MySocketConnection();
		HOST, PORT = 'mms.whatsapp.net', 443
		self.sock.connect((HOST, PORT));
		ssl_sock = ssl.wrap_socket(self.sock)

		filename = os.path.basename(image)
		filetype = mimetypes.guess_type(filename)[0]
		filesize = os.path.getsize(image)

		if self.resizeImages is True and "image" in filetype:
			user_img = QImage(image)
			preimg = user_img
			if user_img.height() > user_img.width() and user_img.width() > 600:
				preimg = user_img.scaledToWidth(600, Qt.SmoothTransformation)
			elif user_img.height() < user_img.width() and user_img.height() > 800:
				preimg = user_img.scaledToHeight(800, Qt.SmoothTransformation)
			elif user_img.height() == user_img.width() and user_img.height() > 600:
				preimg = user_img.scaled(600, 600, Qt.KeepAspectRatioByExpanding, Qt.SmoothTransformation)
			preimg.save("/home/user/.cache/wazapp/" + os.path.basename(image))
			image = "/home/user/.cache/wazapp/" + os.path.basename(image)

			filename = os.path.basename(image)
			filetype = mimetypes.guess_type(filename)[0]
			filesize = os.path.getsize(image)

		print "Uploading " + image + " - type: " + filetype + " - resize:" + str(self.resizeImages);


		m = hashlib.md5()
		m.update(filename)
		crypto = m.hexdigest() + os.path.splitext(filename)[1]

		boundary = "-------" + m.hexdigest() #"zzXXzzYYzzXXzzQQ"
		contentLength = 0
		
		hBAOS = bytearray()
		hBAOS += "--" + boundary + "\r\n"
		hBAOS += "Content-Disposition: form-data; name=\"to\"\r\n\r\n"
		hBAOS += self.jid + "\r\n"
		hBAOS += "--" + boundary + "\r\n"
		hBAOS += "Content-Disposition: form-data; name=\"from\"\r\n\r\n"
		hBAOS += self.account.replace("@whatsapp.net","").encode() + "\r\n"

		hBAOS += "--" + boundary + "\r\n"
		hBAOS += "Content-Disposition: form-data; name=\"file\"; filename=\"" + crypto.encode() + "\"\r\n"
		hBAOS += "Content-Type: " + filetype + "\r\n\r\n"

		fBAOS = bytearray()
		fBAOS += "\r\n--" + boundary + "--\r\n"
		
		contentLength += len(hBAOS)
		contentLength += len(fBAOS)
		contentLength += filesize

		userAgent = "WhatsApp/2.8.4 S60Version/5.2 Device/C7-00"

		POST = bytearray()
		POST += "POST https://mms.whatsapp.net/client/iphone/upload.php HTTP/1.1\r\n"
		POST += "Content-Type: multipart/form-data; boundary=" + boundary + "\r\n"
		POST += "Host: mms.whatsapp.net\r\n"
		POST += "User-Agent: WhatsApp/2.8.14 S60Version/5.3 Device/C7-00\r\n"
		POST += "Content-Length: " + str(contentLength) + "\r\n\r\n"

		print "sending REQUEST "
		print hBAOS
		ssl_sock.write(str(POST))
		ssl_sock.write(str(hBAOS))

		totalsent = 0
		buf = 1024
		f = open(image, 'r')
		stream = f.read()
		f.close()
		status = 0
		lastEmit = 0

		while totalsent < int(filesize):
			#print "sending " + str(totalsent) + " to " + str(totalsent+buf) + " - real: " + str(len(stream[:buf]))
			ssl_sock.write(str(stream[:buf]))
			status = totalsent * 100 / filesize
			if lastEmit!=status and status!=100 and filesize>12288:
				self.progressUpdated.emit(status)
			lastEmit = status
			stream = stream[buf:]
			totalsent = totalsent + buf

		ssl_sock.write(str(fBAOS))

		if self.resizeImages is True and "image" in filetype:
			os.remove("/home/user/.cache/wazapp/" + os.path.basename(image))

		sleep(1)
		print "Done!"
		print "Reading response..."
		data = ssl_sock.recv(8192)
		data += ssl_sock.recv(8192)
		data += ssl_sock.recv(8192)
		data += ssl_sock.recv(8192)
		data += ssl_sock.recv(8192)
		data += ssl_sock.recv(8192)
		data += ssl_sock.recv(8192)
		print data;
		self.progressUpdated.emit(100)

		if "<string>https://mms" in data:
			n = data.find("<string>https://mms") +8
			url = data[n:]
			n = url.find("</string>")
			url = url[:n]
			#print "MMS ADDRESS: "+url
			self.success.emit(url + "," + filename + "," + str(filesize), "upload")

		else:
			self.error.emit()



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
			
			self.success.emit(self.savePath, "download")
			
		except:
			self.error.emit()


def onSuccess(jid,msgId,data):
	print "SUCCESS: %s %s %i"%(data,jid,msgId)
	
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
	
