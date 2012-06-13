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
from utilities import Utilities,S40MD5Digest,ByteArray;
from waexceptions import *
class ProtocolTreeNode():
	
	def __init__(self,tag,attributes,children=None,data=None):
		self.tag = tag;
		self.attributes = attributes;
		self.children = children;
		self.data = data
		
	def toString(self):
		out = "<"+self.tag;
		if self.attributes is not None:
			for key,val in self.attributes.items():
				out+= " "+key+'="'+val+'"'
		out+= ">\n";
		if self.data is not None:
			out += self.data;
		
		if self.children is not None:
			for c in self.children:
				out+=c.toString();
		#print sel
		out+= "</"+self.tag+">\n"
		return out;
		
	
	@staticmethod	
	def tagEquals(node,string):
		return node is not None and node.tag is not None and node.tag == string;
		
		
	@staticmethod
	def require(node,string):
		if not ProtocolTreeNode.tagEquals(node,string):
			raise Exception("failed require. node: "+node+" string: "+string);
	
	
	def getChild(self,identifier):

		if self.children is None or len(self.children) == 0:
			return None
		if type(identifier) == int:
			if len(self.children) > identifier:
				return self.children[identifier]
			else:
				return None

		for c in self.children:
			if identifier == c.tag:
				return c;

		return None;
		
	def getAttributeValue(self,string):
		
		if self.attributes is None:
			return None;
		
		try:
			val = self.attributes[string]
			return val;
		except KeyError:
			return None;

	def getAllChildren(self,tag = None):
		ret = [];
		if self.children is None:
			return ret;
			
		if tag is None:
			return self.children
		
		for c in self.children:
			if tag == c.tag:
				ret.append(c)
		
		return ret;

		
	
class BinTreeNodeReader():
	def __init__(self,inputstream,dictionary):
		Utilities.debug('Reader init');
		self.tokenMap = dictionary;
		self.rawIn = inputstream;
		self.inn = ByteArray();
		self.buf = bytearray(1024);
		self.bufSize = 0;
		self.readSize = 1;
		
		
	def streamStart(self):
		stanzaSize = self.readInt16(self.rawIn,1);
		self.fillBuffer(stanzaSize);
		tag = self.inn.read();
		size = self.readListSize(tag);
		tag = self.inn.read();
		if tag != 1:
			Utilities.debug(tag);
			raise Exception("expecting STREAM_START in streamStart");
		attribCount = (size - 2 + size % 2) / 2;
		attributes = self.readAttributes(attribCount);
	
	def readInt8(self,i):
		return i.read();
		
	def readInt16(self,i,socketOnly=0):
		intTop = i.read(socketOnly);
		intBot = i.read(socketOnly);
		#Utilities.debug(str(intTop)+"------------"+str(intBot));
		value = (intTop << 8) + intBot;
		return value;
	
	
	def readInt24(self,i):
		int1 = i.read();
		int2 = i.read();
		int3 = i.read();
		value = (int1 << 16) + (int2 << 8) + (int3 << 0);
		return value;
		

	
	def readListSize(self,token):
		size = 0;
		if token == 0:
			size = 0;
		else:
			if token == 248:
				size = self.readInt8(self.inn);
			else:
				if token == 249:
					size = self.readInt16(self.inn);
				else:
					#size = self.readInt8(self.inn);
					raise Exception("invalid list size in readListSize: token " + str(token));
		return size;
	
	def readAttributes(self,attribCount):
		attribs = {};
		for i in range(0,attribCount):
			key = self.readString(self.inn.read());
			value = self.readString(self.inn.read());
			attribs[key]=value;
		return attribs;
	
	def getToken(self,token):
		if (token >= 0 and token < len(self.tokenMap)):
			ret = self.tokenMap[token];
		else:
			raise Exception("invalid token/length in getToken %i "%token);
		
		return ret;
		
	
	def readString(self,token):
		
		if token == -1:
			raise Exception("-1 token in readString");
		
		if token > 4 and token < 245:
			return self.getToken(token);
		
		if token == 0:
			return None;
			

		if token == 252:
			size8 = self.readInt8(self.inn);
			buf8 = bytearray(size8);
			
			self.fillArray(buf8,len(buf8),self.inn);
			#print self.inn.buf;
			return str(buf8);
			#return size8;
			
		
		if token == 253:
			size24 = self.readInt24(self.inn);
			buf24 = bytearray(size24);
			self.fillArray(buf24,len(buf24),self.inn);
			return str(buf24);
			
		if token == 254:
			token = self.inn.read();
			return self.getToken(245+token);
		if token == 250:
			user = self.readString(self.inn.read());
			server = self.readString(self.inn.read());
			if user is not None and server is not None:
				return user + "@" + server;
			if server is not none:
				return server;
			raise Exception("readString couldn't reconstruct jid");
		
		raise Exception("readString couldn't match token");
		
	def nextTree(self):
		stanzaSize = self.readInt16(self.rawIn,1);
		self.inn.buf = [];
		self.fillBuffer(stanzaSize);
		ret = self.nextTreeInternal();
		Utilities.debug("<<")
		if ret is not None:
			Utilities.debug(ret.toString());
		return ret;
	
	def fillBuffer(self,stanzaSize):
		if len(self.buf) < stanzaSize:
			newsize = max(len(self.buf)*3/2,stanzaSize);
			self.buf = bytearray(newsize);
		self.bufSize = stanzaSize;
		self.fillArray(self.buf, stanzaSize, self.rawIn);
		self.inn = ByteArray();
		self.inn.write(self.buf);
		
		#this.in = new ByteArrayInputStream(this.buf, 0, stanzaSize);
		#self.inn.setReadSize(stanzaSize);
		#Utilities.debug(str(len(self.buf))+":::"+str(stanzaSize));
	
	def fillArray(self, buf,length,inputstream):
		count = 0;
		while count < length:
			count+=inputstream.read2(buf,count,length-count);
			
			
	
	
	
	
	
	
	
	def nextTreeInternal(self):
		
		b = self.inn.read();
		
		size = self.readListSize(b);
		b = self.inn.read();
		if b == 2:
			return None;
		
		
		tag = self.readString(b);
		if size == 0 or tag is None:
			raise ConnectionClosedException("nextTree sees 0 list or null tag");
		
		attribCount = (size - 2 + size%2)/2;
		attribs = self.readAttributes(attribCount);
		if size % 2 ==1:
			return ProtocolTreeNode(tag,attribs);
			
		b = self.inn.read();

		if self.isListTag(b):
			return ProtocolTreeNode(tag,attribs,self.readList(b));
		
		return ProtocolTreeNode(tag,attribs,None,self.readString(b));
		
	def readList(self,token):
		size = self.readListSize(token);
		listx = []
		for i in range(0,size):
			listx.append(self.nextTreeInternal());
		
		return listx;
	

	
	
		
	def isListTag(self,b):
		 return (b == 248) or (b == 0) or (b == 249);
		
		
		
	
	 
class BinTreeNodeWriter():
	STREAM_START = 1;
	STREAM_END = 2;
	LIST_EMPTY = 0;
	LIST_8 = 248;
	LIST_16 = 249;
	JID_PAIR = 250;
	BINARY_8 = 252;
	BINARY_24 = 253;
	TOKEN_8 = 254;
	#socket out; #FunXMPP.WAByteArrayOutputStream
	#socket realOut;
	tokenMap={}
	
	def __init__(self,o,dictionary):
		self.realOut = o;
		#self.out = o;
		self.tokenMap = {}
		self.out = ByteArray();
		#this.tokenMap = new Hashtable(dictionary.length);
		for i in range(0,len(dictionary)):
			if dictionary[i] is not None:
				self.tokenMap[dictionary[i]]=i
		
		#Utilities.debug(self.tokenMap);
		'''
		for (int i = 0; i < dictionary.length; i++)
			if (dictionary[i] != null)
				this.tokenMap.put(dictionary[i], new Integer(i));
		'''
	def streamStart(self,domain,resource):
		
		self.realOut.write(87);
		self.realOut.write(65);
		self.realOut.write(1);
		self.realOut.write(0);
		
		#self.out.write(0); ##HACK FOR WHAT BUFFER FLUSH SENDS IN JAVA
		#self.out.write(26); ##HACK FOR WHAT BUFFER FLUSH SENDS IN JAVA
		
		streamOpenAttributes  = {"to":domain,"resource":resource};


		self.writeListStart(len(streamOpenAttributes )*2+1);
		
		#self.flushBuffer(False);
		
		
		self.out.write(1);
		self.writeAttributes(streamOpenAttributes);
		self.flushBuffer(False);
		#self.out.write(0); #HACK
		#self.out.write(8); #HACK
		
		
		'''
		 FunXMPP.KeyValue[] streamOpenAttributes = { new FunXMPP.KeyValue("to", domain), new FunXMPP.KeyValue("resource", resource) };
		/*      */ 
		/* 2561 */       writeListStart(streamOpenAttributes.length * 2 + 1);
		/* 2562 */       this.out.write(1);
		/* 2563 */       writeAttributes(streamOpenAttributes);
		/* 2564 */       flushBuffer(false);

		'''
	
	
	def write(self, node,needsFlush = 0):
		if node is None:
			self.out.write(0);
		else:
			Utilities.debug(">>");
			Utilities.debug(node.toString());
			self.writeInternal(node);
		
		self.flushBuffer(needsFlush);
		self.out.buf = [];
		

	
	def flushBuffer(self, flushNetwork):
		'''define flush buffer here '''
		size = len(self.out.getBuffer());
		if (size & 0xFFFF0000) != 0:
			raise Exception("Buffer too large: "+str(size));
		
		self.writeInt16(size,self.realOut);
		self.realOut.write(self.out.getBuffer());
		self.out.reset();
		
		if flushNetwork:
			self.realOut.flush();
		
		
		
		
		
	def writeInternal(self,node):
		'''define write internal here'''
		
		x = 1 + (0 if node.attributes is None else len(node.attributes) * 2) + (0 if node.children is None else 1) + (0 if node.data is None else 1);
	
		
	
		
		
		self.writeListStart(1 + (0 if node.attributes is None else len(node.attributes) * 2) + (0 if node.children is None else 1) + (0 if node.data is None else 1));
		
		self.writeString(node.tag);
		self.writeAttributes(node.attributes);
		
		if node.data is not None:
			self.writeBytes(bytearray(node.data));
		
		if node.children is not None:
			self.writeListStart(len(node.children));
			for c in node.children:
				self.writeInternal(c);
	
	
	def writeAttributes(self,attributes):
		if attributes is not None:
			for key, value in attributes.items():
				self.writeString(key);
				self.writeString(value);
		
		
	def writeBytes(self,bytes):

		length = len(bytes);
		if length >= 256:
			self.out.write(253);
			self.writeInt24(length);
		else:
			self.out.write(252);
			self.writeInt8(length);
			
		for b in bytes:
			self.out.write(b);
		
	def writeInt8(self,v):
		self.out.write(v & 0xFF);

	
	def writeInt16(self,v, o = None):
		if o is None:
			o = self.out;

		o.write((v & 0xFF00) >> 8);
		o.write((v & 0xFF) >> 0);

	
	def writeInt24(self,v):
		self.out.write((v & 0xFF0000) >> 16);
		self.out.write((v & 0xFF00) >> 8);
		self.out.write((v & 0xFF) >> 0);
	

	def writeListStart(self,i):
		#Utilities.debug("list start "+str(i));
		if i == 0:
			self.out.write(0)
		elif i < 256:
			self.out.write(248);
			self.writeInt8(i);
		else:
			self.out.write(249);
			self.writeInt16(i);
			
		
	def writeToken(self, intValue):
		if intValue < 245:
			self.out.write(intValue)
		elif intvalue <=500:
			self.out.write(254)
			self.out.write(intValue - 245);
	
	def writeString(self,tag):
		try:
			key = self.tokenMap[tag];
			self.writeToken(key);
		except KeyError:
			try:
				atIndex = tag.index('@');
				
				if atIndex < 1:
					 raise ValueError("atIndex < 1");
				else:
					server = tag[atIndex+1:];
					user = tag[0:atIndex];
					#Utilities.debug("GOT "+user+"@"+server);
					self.writeJid(user, server);
					
			except ValueError:
				Utilities.debug("INEX");
				self.writeBytes(Utilities.encodeString(tag));
   
	
	def writeJid(self,user,server):
		self.out.write(250);
		if user is not None:
			self.writeString(user);
		else:
			self.writeToken(0);
		self.writeString(server);

		
	def getChild(self,string):
		if self.children is None:
			return None
		
		for c in self.children:
			if string == c.tag:
				return c;
		return None;
		
	def getAttributeValue(self,string):
		
		if self.attributes is None:
			return None;
		
		try:
			val = self.attributes[string]
			return val;
		except KeyError:
			return None;
