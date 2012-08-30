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
from mnotification import MNotificationManager,MNotification
from PySide.QtGui import QSound
from PySide.QtCore import QUrl
from QtMobility.Feedback import QFeedbackHapticsEffect #QFeedbackEffect
from QtMobility.SystemInfo import QSystemDeviceInfo
from constants import WAConstants
from utilities import Utilities
from QtMobility.MultimediaKit import QMediaPlayer

from wadebug import NotifierDebug

class Notifier():
	def __init__(self,audio=False,vibra=True):
		_d = NotifierDebug();
		self._d = _d.d;
		
		self.manager = MNotificationManager('wazappnotify','WazappNotify');
		self.vibra = vibra
		
		
		
		self.newMessageSound = WAConstants.DEFAULT_SOUND_NOTIFICATION #fetch from settings
		self.devInfo = QSystemDeviceInfo();
		
		self.devInfo.currentProfileChanged.connect(self.profileChanged);
		
		
		if audio:
			self.audio = QMediaPlayer(); 
			self.audio.setVolume(100);
		else:
			self.audio = False
			
		self.enabled = True
		self.notifications = {}
		
		if self.vibra:
			self.vibra = QFeedbackHapticsEffect();
			self.vibra.setIntensity(1.0);
			self.vibra.setDuration(200);
	
	
	
	def profileChanged(self):
		self._d("Profile changed");
	
	def enable(self):
		self.enabled = True
	
	def disable(self):
		self.enabled = False
	
	def saveNotification(self,jid,data):
		self.notifications[jid] = data;
		
	
	def getCurrentSoundPath(self):
		activeProfile = self.devInfo.currentProfile();
		
		if activeProfile in (QSystemDeviceInfo.Profile.NormalProfile,QSystemDeviceInfo.Profile.LoudProfile):
			if self.enabled:
				return self.newMessageSound;
			else:
				return WAConstants.FOCUSED_SOUND_NOTIFICATION
				
		elif activeProfile  == QSystemDeviceInfo.Profile.BeepProfile:
			return WAConstants.DEFAULT_BEEP_NOTIFICATION 
		else:
			return WAConstants.NO_SOUND
		
	
	
	def hideNotification(self,jid):
		if self.notifications.has_key(jid):
			#jid = jids[0]
			nId = self.notifications[jid]["id"];
			del self.notifications[jid]
			self._d("DELETING NOTIFICATION BY ID "+str(nId));
			self.manager.removeNotification(nId);
		
				
	def notificationCallback(self,jid):
		#nId = 0
		#jids = [key for key,value in self.notifications.iteritems() if value["id"]==nId]
		#if len(jids):
		if self.notifications.has_key(jid):
			#jid = jids[0]
			nId = self.notifications[jid]["id"];
			self.notifications[jid]["callback"](jid);
			del self.notifications[jid]
			#self.manager.removeNotification(nId);
		
				
	def newMessage(self,jid,contactName,message,picture=None,callback=False):
		
		activeConvJId = self.ui.getActiveConversation()
		
		max_len = min(len(message),20)
		
		if self.enabled:
			
			
			if(activeConvJId == jid or activeConvJId == ""):
				if self.vibra:
					self.vibra.start()
				return
			
			n = MNotification("wazapp.message.new",contactName, message);
			n.image = picture
			n.manager = self.manager;
			action = lambda: self.notificationCallback(jid)
			
			n.setAction(action);
		
			notifications = n.notifications();
			
			
			if self.notifications.has_key(jid):
				nId = self.notifications[jid]['id'];
				
				
				for notify in notifications:
					if int(notify[0]) == nId:
						n.id = nId
						break
				
				if n.id != nId:
					del self.notifications[jid]
			
				
			if(n.publish()):
				nId = n.id;
				self.saveNotification(jid,{"id":nId,"callback":callback});
		
		
		#if self.vibra:
		#	self.vibra.start()
		
		if self.audio:
			soundPath = self.getCurrentSoundPath();
			self._d(soundPath)
			self.audio.setMedia(QUrl.fromLocalFile(soundPath));
			self.audio.play();
			
			
	
if __name__=="__main__":
	n = Notifier();
	n.newMessage("tgalal@WHATEVER","Tarek Galal","HELLOOOOOOOOOOOO","/usr/share/icons/hicolor/80x80/apps/waxmppplugin80.png");
	n.newMessage("tgalal@WHATEVER","Tarek Galal","YOW","/usr/share/icons/hicolor/80x80/apps/waxmppplugin80.png");
