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

from PySide import QtCore
from PySide.QtCore import QObject, QThread, Qt
from PySide.QtGui import QImage
from constants import WAConstants
from wadebug import WADebug
import os
import mimetypes
import shutil, sys

from Yowsup.Media.downloader import MediaDownloader
from Yowsup.Media.uploader import MediaUploader
from utilities import async, Utilities


class WAMediaHandler(QObject):
	progressUpdated = QtCore.Signal(int,int) #%,progress,mediaid
	error = QtCore.Signal(str,int)
	success = QtCore.Signal(str,int,str,str, str)
	
	def __init__(self,jid,message_id,url,mediaType_id,mediaId,account,resize=False):
		
		WADebug.attach(self);
		path = self.getSavePath(mediaType_id);
		
		filename = url.split('/')[-1]
		
		if path is None:
			raise Exception("Unknown media type")
		
		if not os.path.exists(path):
			os.makedirs(path)
		
		
		self.uploadHandler = MediaUploader(jid, account, self.onUploadSuccess, self.onError, self.onProgressUpdated)
		self.downloadHandler = MediaDownloader(self.onDownloadSuccess, self.onError, self.onProgressUpdated)

		self.url = url
		self._path = path+"/"+filename

		ext = os.path.splitext(filename)[1]

		self.downloadPath = Utilities.getUniqueFilename(path + "/" + self.getFilenamePrefix(mediaType_id) + ext)

		self.resize = resize
		self.mediaId = mediaId
		self.message_id = message_id
		self.jid = jid

		super(WAMediaHandler,self).__init__();
	

	def onError(self):
		self.error.emit(self.jid,self.message_id)
	
	def onUploadSuccess(self, url):

		#filename = os.path.basename(self._path)
		#filesize = os.path.getsize(self._path)
		#data = url + "," + filename + "," + str(filesize);
		self.success.emit(self.jid,self.message_id, self._path, "upload", url)

	def onDownloadSuccess(self, path):
		try:
			shutil.copyfile(path, self.downloadPath)
			os.remove(path)
			self.success.emit(self.jid, self.message_id, self.downloadPath, "download", "")
		except:
			print("Error occured at transfer %s"%sys.exc_info()[1])
			self.error.emit(self.jid, self.message_id)

	def onProgressUpdated(self,progress):
		self.progressUpdated.emit(progress, self.mediaId);

	@async
	def pull(self):
		self.action = "download"
		self.downloadHandler.download(self.url)

	@async
	def push(self, uploadUrl):
		self.action = "upload"

		path = self.url.replace("file://","")

		filename = os.path.basename(path)
		filetype = mimetypes.guess_type(filename)[0]
		
		self._path = path
		self.uploadHandler.upload(path, uploadUrl)
	
	def getFilenamePrefix(self, mediatype_id):
		if mediatype_id == WAConstants.MEDIA_TYPE_IMAGE:
			return "owhatsapp_image"
		
		if mediatype_id == WAConstants.MEDIA_TYPE_AUDIO:
			return "owhatsapp_audio"
		
		if mediatype_id == WAConstants.MEDIA_TYPE_VIDEO:
			return "owhatsapp_video"

		if mediatype_id == WAConstants.MEDIA_TYPE_VCARD:
			return "owhatsapp_vcard"
			
		return ""
	
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