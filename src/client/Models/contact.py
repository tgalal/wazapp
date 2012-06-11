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
from model import Model;

class Contact(Model):
	def __init__(self):
		self.name = "";
		self.picture = "none";
		self.alphabet = "";
		self.falphabet = "";
	
	def setRealTimeData(self,name,picture):
		self.name = name;
		self.picture = picture;
		self.alphabet = name[0].upper();
		self.falphabet = name[0].upper();
		
		self.modelData.append("name");
		self.modelData.append("picture");
		self.modelData.append("alphabet");
		
	
	def getOrCreateContactByJid(self,jid):
		
		contact = self.findFirst({'jid':jid})
		
		if not contact:
			contact = self.create()
			contact.setData({"jid":jid,"number":jid.split('@')[0]})
			contact.save()
		
		return contact
			
			
			
			
			
			
			
			
			
			
