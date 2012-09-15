# -*- coding: utf-8 -*-
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
# -*- coding: utf-8 -*-

'''
Copyright (c) 2012, Tarek Galal <tare2.galal@gmail.com>

This file is part of python-notifications, a library that allows you to post 
notifications on Harmattan platform

python-notifications is free software: you can redistribute it and/or modify it 
under the terms of the GNU Lesser General Public License as published by the 
Free Software Foundation, either version 3 of the License, or (at your option) 
any later version.

python-notifications is distributed in the hope that it will be useful, but WITHOUT ANY 
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR 
A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more 
details.

You should have received a copy of the GNU General Public License along with 
python-notifications. If not, see http://www.gnu.org/licenses/.
'''

'''
This file is a derivative of Python Event Feed library by Thomas Perl 
Copyright (c) 2011, Thomas Perl <m@thp.io>

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.
'''

# Dependency on PySide for encoding/decoding like MRemoteAction
from PySide.QtCore import QBuffer, QIODevice, QDataStream, QByteArray
from PySide.QtCore import QCoreApplication


# Python D-Bus Library dependency for communcating with the service
import dbus
import dbus.service
import dbus.mainloop
import dbus.glib
import sys,os

# MRemoteAction::toString()
# http://apidocs.meego.com/1.0/mtf/mremoteaction_8cpp_source.html
def qvariant_encode(value):
    buffer = QBuffer()
    buffer.open(QIODevice.ReadWrite)
    stream = QDataStream(buffer)
    stream.writeQVariant(value)
    buffer.close()
    return buffer.buffer().toBase64().data().strip()

# MRemoteAction::fromString()
# http://apidocs.meego.com/1.0/mtf/mremoteaction_8cpp_source.html
def qvariant_decode(data):
    byteArray = QByteArray.fromBase64(data)
    buffer = QBuffer(byteArray)
    buffer.open(QIODevice.ReadOnly)
    stream = QDataStream(buffer)
    result = stream.readQVariant()
    buffer.close()
    return result
    
    
class MNotificationManager(dbus.service.Object):
	INTERFACE="com.meego.core.MNotificationManager"
	PATH="/notificationmanager"
	
	
	DEFAULT_NAME = 'com.tgalal.meego.MNotificationManager'
	DEFAULT_PATH = '/MNotificationManager'
	DEFAULT_INTF = 'com.tgalal.meego.MNotificationManager'
	
	def __init__(self,source_name, source_display_name, on_data_received=None):
		dbus_main_loop = dbus.glib.DBusGMainLoop(set_as_default=True)
		session_bus = dbus.SessionBus(dbus_main_loop)
		self.userId = 0#os.geteuid();
		
		self.local_name = '.'.join([self.DEFAULT_NAME, source_name])
		print  self.local_name
		bus_name = dbus.service.BusName(self.local_name, bus=session_bus)

		dbus.service.Object.__init__(self,object_path=self.DEFAULT_PATH,bus_name=bus_name)
		
		
		
		self.next_action_id = 1
		self.actions = {}
		self.source_name = source_name
		self.source_display_name = source_display_name
		self.on_data_received = on_data_received
		
		o = session_bus.get_object(self.INTERFACE, self.PATH)
		self.proxy = dbus.Interface(o, self.INTERFACE)
		
		self.userId = self.proxy.notificationUserId()
	
	def notificationList(self):
		return self.proxy.notificationList(self.userId)
		
	def notificationIdList(self):
		return self.proxy.notificationIdList(self.userId)
		
	def notificationGroupList(self):
		return self.proxy.notificationGroupList(self.userId)
	
	
	@dbus.service.method(DEFAULT_INTF)
	def ReceiveActionCallback(self, action_id):
	
		action_id = int(action_id)
		callable = self.actions[action_id]
		callable()

	@dbus.service.method(DEFAULT_INTF)
	def ReceiveActionData(self, *args):
		print 'Received data:'
		if self.on_data_received is not None:
		    self.on_data_received(*args)
		
	def addNotification(self, groupId, eventType, summary, body, action, imageURI, count):
		
		data = {}
		data["eventType"]=eventType;
		data["summary"] = summary;
		data["body"] = body;
		#data["action"] = action;
		if imageURI is not None:
			data["imageId"]=imageURI;
		data["count"]=count;
		
		
		if action is not None:
		    remote_action = [
		            self.local_name,
		            self.DEFAULT_PATH,
		            self.DEFAULT_INTF,
		    ]

		    if action is not None:
		        action_id = self.next_action_id
		        self.next_action_id += 1
		        self.actions[action_id] = action
		        remote_action.extend([
		            'ReceiveActionCallback',
		            qvariant_encode(action_id),
		        ])
		    else: # action_data is not None
		    	print "IN ELSE"
		        remote_action.append('ReceiveActionData')
		        remote_action.extend([qvariant_encode(x) for x in action_data])

		    data['action'] = ' '.join(remote_action)

        	
		return self.proxy.addNotification(self.userId, groupId,data);
	
	#def notifications(self):

	
	def addNonVisualNotification(self,groupId, eventType):
		return self.proxy.addNotification(self.userId,groupId,{'eventType':eventType});
		
	def updateNotification(self, notificationId, eventType, summary, body, action ,imageURI, count):
		data = {}
		data["eventType"]=eventType;
		data["summary"] = summary;
		data["body"] = body;
		
		
		if action is not None:
		    remote_action = [
		            self.local_name,
		            self.DEFAULT_PATH,
		            self.DEFAULT_INTF,
		    ]

		    if action is not None:
		        action_id = self.next_action_id
		        self.next_action_id += 1
		        self.actions[action_id] = action
		        remote_action.extend([
		            'ReceiveActionCallback',
		            qvariant_encode(action_id),
		        ])
		    else: # action_data is not None
		    	print "IN ELSE"
		        remote_action.append('ReceiveActionData')
		        remote_action.extend([qvariant_encode(x) for x in action_data])

		    data['action'] = ' '.join(remote_action)
		
		
		if imageURI is not None:
			data["imageId"]=imageURI;
		
		data["count"]=count;
		
		return self.proxy.updateNotification(self.userId,notificationId, data);
		
	def updateNonVisualNotification(self,notificationId, eventType):
		return self.proxy.addNotification(self.userId,notificationId,{'eventType':eventType});
		
	
	def removeNotification(self,notificationId):
		return self.proxy.removeNotification(self.userId, notificationId);	
		
		
	def addGroup(self, eventType, summary, body, action, imageURI, count):
		
		data = {}
		data["eventType"]=eventType;
		data["summary"] = summary;
		data["body"] = body;
		data["action"] = action;
		data["imageURI"]=imageURI;
		data["count"]=count;
	
		return self.proxy.addGroup(self.userId,data);
	
	def addNonVisualGroup(self, eventType):
		return self.proxy.addNotification(self.userId,{'eventType':eventType});
		
		
	def updateGroup(self, groupId, eventType, summary, body, action ,imageURI, count):
		data = {}
		data["eventType"]=eventType;
		data["summary"] = summary;
		data["body"] = body;
		data["action"] = action;
		data["imageURI"]=imageURI;
		data["count"]=count;
		
		return self.proxy.updateNotification(self.userId,groupId, data);
		
	def updateNonVisualGroup(self,notificationId, eventType):
		return self.proxy.addNotification(self.userId,groupId,{'eventType':eventType});
		
	
	
	def removeGroup(self,groupId):
		return self.proxy.removeGroup(self.userId, groupId);


class MNotification():
	
	DeviceEvent = "device";
	DeviceAddedEvent = "device.added";
	DeviceErrorEvent = "device.error";
	DeviceRemovedEvent = "device.removed";
	EmailEvent = "email";
	EmailArrivedEvent = "email.arrived";
	EmailBouncedEvent = "email.bounced";
	ImEvent = "im";
	ImErrorEvent = "im.error";
	ImReceivedEvent = "im.received";
	NetworkEvent = "network";
	NetworkConnectedEvent = "network.connected";
	NetworkDisconnectedEvent = "network.disconnected";
	NetworkErrorEvent = "network.error";
	PresenceEvent = "presence";
	PresenceOfflineEvent = "presence.offline";
	PresenceOnlineEvent = "presence.online";
	TransferEvent = "transfer";
	TransferCompleteEvent = "transfer.complete";
	TransferErrorEvent = "transfer.error";
	MessageEvent = "x-nokia.message";
	MessageArrivedEvent = "x-nokia.message.arrived";
	
	
	def __init__(self, eventType, summary="",body=""):
	
		self.image = "";
		self.action = "";
		self.count = 1;
		self.id = 0; 
		self.groupId = 0;
		
		
	
		self.eventType = eventType;
		self.summary = summary;
		self.body = body;
		
		
	def id_(self):
		return self.id;
		
	def isPublished(self):
		return self.id != 0;
		
	def setEventType(self,eventType):
		self.eventType
	
	def setGroup(self,group):
		self.groupId = group.id_();
	
	def eventType(self):
		return self.eventType;
	
	def setSummary(self,summary):
		self.summary = summary;
	
	def setBody(self,body):
		self.body = body;
	
	def body(self):
		return self.body;
	
	def setImage(self,image):
		self.image = image;
	
	def image(self):
		return self.image;
	
	#MRemoteAction
	def setAction(self,action):
		self.action = action;
	
	def setCount(self,count):
		self.count = count;
	
	
	
	def remove(self):
		success = False;
		
		if isPublished():
			n_id = self.id;
			self.id = 0;
			success = self.manager.removeNotification(n_id);
		
		return success;
	
	
	def notifications(self):
		return self.manager.notificationList();	
	
	def publish(self):
		success = False;
		
		if self.id == 0:
			if self.summary != "" or self.body !="" or self.image !="" or self.action !="":
				self.id = self.manager.addNotification(self.groupId,self.eventType,self.summary,self.body,self.action,self.image,self.count);
			else:
				self.id = self.manager.addNonVisualNotification(self.groupId, self.eventType);
			
			success = self.id !=0;
		else:
			if self.summary !="" or self.body !="" or self.image !="" or self.action !="":
				success = self.manager.updateNotification(self.id,self.eventType,self.summary,self.body,self.action,self.image,self.count);
			else:
				success = self.manager.updateNonVisualNotification(self.id,self.eventType);

		return success;
	 

class MNotificationGroup(MNotification):

	
	def publish(self):
		success = False;
		
		if self.id == 0:
			if self.summary != "" or self.body !="" or self.image !="" or self.action !="":
				self.id = self.manager.addGroup(self.eventType,self.summary,self.body,self.action,self.image,self.count);
			else:
				self.id = self.manager.addNonVisualGroup(self.eventType);
			
			success = self.id !=0;
		else:
			if self.summary !="" or self.body !="" or self.image !="" or self.action !="":
				success = self.manager.updateGroup(self.id,self.eventType,self.summary,self.body,self.action,self.image,self.count);
			else:
				success = self.manager.updateNonVisualGroup(self.id,self.eventType);

		return success;
		
	def remove(self):
		if not self.isPublished():
			return False;
		else:
			g_id = self.id;
			self.id = 0;
			return self.manager.removeGroup(g_id);
	

	

def sayHello():
	print "HELLOOOOOO"


def on_data_received(*args):
    print 'CLIENT received DATA:', args



if __name__ == "__main__":
	
	app = QCoreApplication(sys.argv)
	manager = MNotificationManager('wazapp_notify','Wazapp Notify');
	
	
	
	#group = MNotificationGroup(MNotification.ImReceivedEvent,"Message from Reem","tikoooooooooooo");
	#group.manager = manager;
	#group.setImage('/usr/share/icons/hicolor/80x80/apps/waxmppplugin80.png');
	#print group.publish();
	
	
	n = MNotification(MNotification.MessageArrivedEvent,"Reem", "Ezayak?");
	n.manager = manager;
	#n.setAction(sayHello);
	n.setImage('/usr/share/icons/hicolor/80x80/apps/waxmppplugin80.png');
	#n.setGroup(group);
	res = n.publish();
	print res;
	'''
	n.setSummary("CHANGED");
	print n.publish();
	'''
	#n.addNotification(0,MNotification.ImReceivedEvent,"THIS IS SUMMARY", "THIS IS BODY", "NONE", "NONE", 1);
		
	app.exec_()		


