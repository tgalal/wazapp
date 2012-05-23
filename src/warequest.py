import httplib,urllib
from utilities import Utilities
from xml.dom import minidom

import threading
from PySide import QtCore
from PySide.QtCore import QThread

class WARequest(QThread):


	#BASE_URL = [ 97, 61, 100, 123, 114, 103, 96, 114, 99, 99, 61, 125, 118, 103 ];
	status = None
	result = None
	params = []
	#v = "v1"
	#method = None
	conn = None
	
	done = QtCore.Signal(str);
	fail = QtCore.Signal();

	

	def onResponse(self, name, value):
		if name == "status":
			self.status = value
		elif name == "result":
			self.result = value
			
	def addParam(self,name,value):
		self.params.append({name:value.encode('utf-8')});

		
	
	def getUrl(self):
		return  self.base_url+self.req_file;

	def getUserAgent(self):
		#agent = "WhatsApp/1.2 S40Version/microedition.platform";
		agent = "WhatsApp/2.6.61 S60Version/5.2 Device/C7-00";
		return agent;	
	
	

	def sendRequest(self):


		
		self.params =  [param.items()[0] for param in self.params];
		
		params = urllib.urlencode(self.params);
		
		Utilities.debug("Opening connection to "+self.base_url);
		self.conn = httplib.HTTPSConnection(self.base_url,443);
		headers = {"User-Agent":self.getUserAgent(),
			"Content-Type":"application/x-www-form-urlencoded",
			"Accept":"text/xml"
			};
		
		Utilities.debug(headers);
		Utilities.debug(params);
		
		self.conn.request("POST",self.req_file,params,headers);
		resp=self.conn.getresponse()
 		response=resp.read();
 		Utilities.debug(response);
 		doc = minidom.parseString(response);
 		self.done.emit(response);
 		return response;
		#response_node  = doc.getElementsByTagName("response")[0];

		#for (name, value) in response_node.attributes.items():
		#self.onResponse(name,value);
