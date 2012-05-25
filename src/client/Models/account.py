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
class Account():
	def __init__(self,cc,phoneNumber,username,status,pushName,imsi,password):
		
		self.pushName = pushName.encode('utf-8')
		self.cc = cc;
		self.phoneNumber = cc+phoneNumber;
		self.jid = username+"@s.whatsapp.net";
		self.username = username;
		self.password = password
		self.imsi = imsi
		self.status = status
		
		
		
		print "ACCOUNT INFO"
		print pushName
		print cc
		print phoneNumber
		print self.jid
		#print password
		print imsi
		print status
		print "END ACCNT INFO"
		
	def setAccountInstance(self,instance):
		self.accountInstance = instance
	
	def updateStatus(self,status):
		self.accountInstance.setValue("status",status);
		self.accountInstance.sync()
