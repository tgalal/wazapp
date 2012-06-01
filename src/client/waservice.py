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
    
    
class WAService(dbus.service.Object):
	
	
	
	DEFAULT_NAME = 'com.tgalal.meego.Wazapp'
	DEFAULT_PATH = '/'
	DEFAULT_INTF = 'com.tgalal.meego.Wazapp'
	
	
	
	def __init__(self,ui):
		source_name = "WAService"
		self.ui = ui
		dbus_main_loop = dbus.glib.DBusGMainLoop(set_as_default=True)
		session_bus = dbus.SessionBus(dbus_main_loop)
		self.userId = os.geteuid();
		
		self.local_name = '.'.join([self.DEFAULT_NAME, source_name])
		print  self.local_name
		bus_name = dbus.service.BusName(self.local_name, bus=session_bus)

		dbus.service.Object.__init__(self,object_path=self.DEFAULT_PATH,bus_name=bus_name)
		
		
		
		
		#o = session_bus.get_object(self.INTERFACE, self.PATH)
		#self.proxy = dbus.Interface(o, self.INTERFACE)
		
	
	@dbus.service.method(DEFAULT_INTF)
	def launch(self):
		print "GOTCHAAA"
		self.ui.showFullScreen();
	
	@dbus.service.method(DEFAULT_INTF)
	def show(self):
		print "GOTCHAAA"
		self.ui.showFullScreen();
		
