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
import md5
import string

from QtMobility.SystemInfo import QSystemDeviceInfo,QSystemNetworkInfo
class Utilities():

	debug_mode = 1;
	
	waversion = "0.9.15.1"
	

	
	@staticmethod
	def getImsi():
		#return "000000000000000"
		dev_info = QSystemDeviceInfo();
		return dev_info.imsi();
		
	@staticmethod	
	def getProfile():
		dev_info = QSystemDeviceInfo();
		return dev_info.currentProfile();
	
	@staticmethod
	def getCountryCode():
		net_info = QSystemNetworkInfo();
		return net_info.homeMobileCountryCode();
	
	@staticmethod
	def getMcc():
		net_info = QSystemNetworkInfo();
		return net_info.currentMobileCountryCode();
	
	@staticmethod
	def getMnc():
		net_info = QSystemNetworkInfo();
		return net_info.currentMobileNetworkCode();
		
	@staticmethod
	def getImei():
		dev_info = QSystemDeviceInfo();
		return dev_info.imei();
	
	@staticmethod
	def hashCode(string):
		h = 0;
		off =0;
		for i  in range (0,len(string)):
			h = 31*h + ord(string[off]);
			off+=1;

		return h;



	@staticmethod
	def decodeString(url):
		res = "";
		
		for char in url:
			ored = char ^ 0x13
			res = res+chr(ored);
		return res;
	
	@staticmethod
	def encodeString(string):
		res = [];
		for char in string:
			res.append(ord(char))
		return res;
	
	@staticmethod
	def byteArrayToStr(bytearray):
		res = "";
		for b in bytearray:
			res = res+chr(b);
		
		return res;

			

	@staticmethod
	def str( number, radix ):
	   """str( number, radix ) -- reverse function to int(str,radix) and long(str,radix)"""

	   if not 2 <= radix <= 36:
	      raise ValueError, "radix must be in 2..36"

	   abc = string.digits + string.letters

	   result = ''

	   if number < 0:
	      number = -number
	      sign = '-'
	   else:
	      sign = ''

	   while True:
	      number, rdigit = divmod( number, radix )
	      result = abc[rdigit] + result
	      if number == 0:
		 return sign + result

	@staticmethod	
	def getChatPassword():
		imei = Utilities.getImei();
		
		
		buffer_str = imei[::-1];
		digest = S40MD5Digest();
		digest.reset();
		digest.update(buffer_str);
		bytes = digest.digest();
		buffer_str = ""
		for b in bytes:
			tmp = b+128;
			c = (tmp >> 8) & 0xff
			f = tmp & 0xff
			buffer_str+=Utilities.str(f,16);
		return buffer_str;
	


class ByteArray():
	def __init__(self,size=0):
		self.size = size;
		self.buf = bytearray(size);	
	
	def toByteArray(self):
		res = ByteArray();
		for b in self.buf:
			res.buf.append(b);
			
		return res;

	def reset(self):
		self.buf = bytearray(self.size);
		
	def getBuffer(self):
		return self.buf
		
	def read(self):
		return self.buf.pop(0);
		
	def read2(self,b,off,length):
		'''reads into a buffer'''
		if off < 0 or length < 0 or (off+length)>len(b):
			raise Exception("Out of bounds");
		
		if length == 0:
			return 0;
		
		if b is None:
			raise Exception("XNull pointerX");
		
		count = 0;
		
		while count < length:
			
			#self.read();
			#print "OKIIIIIIIIIIII";
			#exit();
			b[off+count]=self.read();
			count= count+1;
		
	
		return count;
		
	def write(self,data):
		if type(data) is int:
			self.writeInt(data);
		elif type(data) is chr:
			self.buf.append(ord(data));
		elif type(data) is str:
			self.writeString(data);
		elif type(data) is bytearray:
			self.writeByteArray(data);
		else:
			raise Exception("Unsupported datatype "+str(type(data)));
			
	def writeByteArray(self,b):
		for i in b:
			self.buf.append(i);
	
	def writeInt(self,integer):
		self.buf.append(integer);
	
	def writeString(self,string):
		for c in string:
			self.writeChar(c);
			
	def writeChar(self,char):
		self.buf.append(ord(char))
		

class S40MD5Digest():
	m = None;
	def __init__(self):
		self.m= md5.new()
		
	def update(self,string):
		#Utilities.debug("update digestion");
		self.m.update(str(string));
		
	def reset(self):	
		self.m = md5.new();
		
	def digest(self):
		#res = self.m.digest();
		#return res;
		arr = bytearray(128);
		res = 0;
		res = self.m.digest();
		resArr = bytearray(res);
		
		return resArr;
