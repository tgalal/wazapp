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
from whatsapp import WAXMPP;

class Key():
	def __init__(self,remote_jid, from_me,idd):
		self.remote_jid = remote_jid;
		self.from_me = from_me;
		self.id = idd;

	
	def exists(self, paramKey):
		try:
			WAXMPP.message_store.get(paramKey)
			return 1
		except KeyError:
			return 0
     


	def equals(obj):
		if self == obj:
			return True;
		if self is None:
			return false;
		if type(self) != type(obj):
			return False;
		other = obj;
		if self.from_me != other.from_me:
			return false;
		if self.id is None:
			if other.id is not None:
				return False;
		elif self.id != other.id:
			return False;
		if self.remote_jid is None:
			if other.remote_jid is not None:
				return False;
		elif self.remote_jid != other.remote_jid:
			return False;

		return True;


	def hashCode(self):
		prime = 31;
		result = 1;
		result = 31 * result + (1231 if self.from_me else 1237)
		result = 31 * result + (0 if self.id is None else Utilities.hashCode(self.id);
		result = 31 * result + (0 if self.remote_jid is None else Utilities.hashCode(self.remote_jid));
	


	def toString(self):
		return "Key[id=" + self.id + ", from_me=" + self.from_me + ", remote_jid=" + self.remote_jid + "]";







class FMessage():
	generating_id = 0;
	generating_header = str(int(time.time()))+"-";
	def __init__(self,key, remote_jid = None,from_me=None,data=None,image=None):

		if key is not None:
			self.key = key;
			WAXMPP.message_store.put(key,self);
		else:
			localKey = Key(remote_jid,from_me,self.generating_header+int(generating_id))

			while message_store.get(localKey) is not None:
				generating_id += 1
				localKey = Key(remote_jid,from_me,self.generating_header+int(generating_id))
				
			self.message_store.put(localKey,self);
			self.key = localKey;
			if data is not None:
				self.data = data;
				self.thumb_image = image;
				self.timestamp = int(time.time())*1000;
			
			
