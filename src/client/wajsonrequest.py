'''
Copyright (c) 2012, Tarek Galal <tarek@wazapp.im>

This file is part of Wazapp, an IM application for Meego Harmattan platform that
allows communication with Whatsapp users

Wazapp is free software: you can redistribute it and/or modify it under the 
terms of the GNU General Public License as published by the Free Software 
Foundation, either version 3 of the License, or (at your option) any later 
version.

Wazapp is distributed in the hope that it will be useful, but WITHOUT ANY 
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A 
PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with 
Wazapp. If not, see http://www.gnu.org/licenses/.
'''
import httplib,urllib
from utilities import Utilities

import threading
from PySide import QtCore
from PySide.QtCore import QThread
from warequest import WARequest
import json
class WAJsonRequest(WARequest):


	#BASE_URL = [ 97, 61, 100, 123, 114, 103, 96, 114, 99, 99, 61, 125, 118, 103 ];
	status = None
	result = None
	params = []
	#v = "v1"
	#method = None
	conn = None
	
	done = QtCore.Signal(dict);
	fail = QtCore.Signal();

			
	def addParam(self,name,value):
		self.params.append({name:value});
	
	def getUrl(self):
		return  self.base_url+self.req_file;

	def getUserAgent(self):
		#agent = "WhatsApp/1.2 S40Version/microedition.platform";
		agent = "WhatsApp/2.6.61 S60Version/5.2 Device/C7-00";
		return agent;	

	def sendRequest(self):
		try:
			self.params =  [param.items()[0] for param in self.params];

			params = urllib.urlencode(self.params);
		
			Utilities.debug("Opening connection to "+self.base_url);
			self.conn = httplib.HTTPConnection(self.base_url,80);
			headers = {"User-Agent":self.getUserAgent(),
				"Content-Type":"application/x-www-form-urlencoded",
				"Accept":"text/json"
				};
		
			#Utilities.debug(headers);
			#Utilities.debug(params);
		
			self.conn.request("GET",self.req_file,params,headers);
			resp=self.conn.getresponse()
	 		response=resp.read();
	 		#Utilities.debug(response);
	 		
	 		self.done.emit(json.loads(response));
	 		return json.loads(response);
	 	except:
	 		self.fail.emit()
		#response_node  = doc.getElementsByTagName("response")[0];

		#for (name, value) in response_node.attributes.items():
		#self.onResponse(name,value);
