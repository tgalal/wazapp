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
#import abc
from PySide.QtCore import QObject
class WAEventBase(QObject):

	def __init__(self):
			super(WAEventBase,self).__init__();

	#__metaclass__ = abc.ABCMeta

	'''
		This class acts as a facilator between GUI and Communication backend
	'''
	#@abc.abstractmethod
	def message_received(self,fmsg,duplicate):
		'''triggered when a new message is msg_recieved'''
	
	#@abc.abstractmethod
	def presence_available_received(self,fromm):
		'''triggered when a user becomes available'''
	
	#@abc.abstractmethod
	def presence_unavailable_received(self):
		'''triggered when a user becomes unavailable'''
	
	#@abc.abstractmethod
	def typing_received(self,fromm):
		'''triggered when user is typing'''
	
	#@abc.abstractmethod
	def paused_received(self,fromm):
		'''triggered when a user pauses typing'''


	#@abc.abstractmethod
	def message_status_update(self,fmsg):
		'''triggered when message status is updated '''
