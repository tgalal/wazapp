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
import base64, random;
from utilities import Utilities,S40MD5Digest,ByteArray;
from protocoltreenode import ProtocolTreeNode
from PySide import QtCore
from PySide.QtCore import QThread
import socket
from waexceptions import *
from wadebug import WADebug

class WALogin(QThread):
	
	dictionary = [ None, None, None, None, None, "1", "1.0", "ack", "action", "active", "add", "all", "allow", "apple", "audio", "auth", "author", "available", "bad-request", "base64", "Bell.caf", "bind", "body", "Boing.caf", "cancel", "category", "challenge", "chat", "clean", "code", "composing", "config", "conflict", "contacts", "create", "creation", "default", "delay", "delete", "delivered", "deny", "DIGEST-MD5", "DIGEST-MD5-1", "dirty", "en", "enable", "encoding", "error", "expiration", "expired", "failure", "false", "favorites", "feature", "field", "free", "from", "g.us", "get", "Glass.caf", "google", "group", "groups", "g_sound", "Harp.caf", "http://etherx.jabber.org/streams", "http://jabber.org/protocol/chatstates", "id", "image", "img", "inactive", "internal-server-error", "iq", "item", "item-not-found", "jabber:client", "jabber:iq:last", "jabber:iq:privacy", "jabber:x:delay", "jabber:x:event", "jid", "jid-malformed", "kind", "leave", "leave-all", "list", "location", "max_groups", "max_participants", "max_subject", "mechanism", "mechanisms", "media", "message", "message_acks", "missing", "modify", "name", "not-acceptable", "not-allowed", "not-authorized", "notify", "Offline Storage", "order", "owner", "owning", "paid", "participant", "participants", "participating", "particpants", "paused", "picture", "ping", "PLAIN", "platform", "presence", "preview", "probe", "prop", "props", "p_o", "p_t", "query", "raw", "receipt", "receipt_acks", "received", "relay", "remove", "Replaced by new connection", "request", "resource", "resource-constraint", "response", "result", "retry", "rim", "s.whatsapp.net", "seconds", "server", "session", "set", "show", "sid", "sound", "stamp", "starttls", "status", "stream:error", "stream:features", "subject", "subscribe", "success", "system-shutdown", "s_o", "s_t", "t", "TimePassing.caf", "timestamp", "to", "Tri-tone.caf", "type", "unavailable", "uri", "url", "urn:ietf:params:xml:ns:xmpp-bind", "urn:ietf:params:xml:ns:xmpp-sasl", "urn:ietf:params:xml:ns:xmpp-session", "urn:ietf:params:xml:ns:xmpp-stanzas", "urn:ietf:params:xml:ns:xmpp-streams", "urn:xmpp:delay", "urn:xmpp:ping", "urn:xmpp:receipts", "urn:xmpp:whatsapp", "urn:xmpp:whatsapp:dirty", "urn:xmpp:whatsapp:mms", "urn:xmpp:whatsapp:push", "value", "vcard", "version", "video", "w", "w:g", "w:p:r", "wait", "x", "xml-not-well-formed", "xml:lang", "xmlns", "xmlns:stream", "Xylophone.caf", "account","digest","g_notify","method","password","registration","stat","text","user","username","event","latitude","longitude"]
	
	dictionaryIn = ["w:profile:picture"]

	'''dictionary = [ None, None, None, None, None, "account", "ack", "action", "active", "add", "after", "ib", "all", "allow", "apple", "audio", "auth", "author", "available", "bad-protocol", "bad-request", "before", "Bell.caf", "body", "Boing.caf", "cancel", "category", "challenge", "chat", "clean", "code", "composing", "config", "conflict", "contacts", "count", "create", "creation", "default", "delay", "delete", "delivered", "deny", "digest", "DIGEST-MD5-1", "DIGEST-MD5-2", "dirty", "elapsed", "broadcast", "enable", "encoding", "duplicate", "error", "event", "expiration", "expired", "fail", "failure", "false", "favorites", "feature", "features", "field", "first", "free", "from", "g.us", "get", "Glass.caf", "google", "group", "groups", "g_notify", "g_sound", "Harp.caf", "http://etherx.jabber.org/streams", "http://jabber.org/protocol/chatstates", "id", "image", "img", "inactive", "index", "internal-server-error", "invalid-mechanism", "ip", "iq", "item", "item-not-found", "user-not-found", "jabber:iq:last", "jabber:iq:privacy", "jabber:x:delay", "jabber:x:event", "jid", "jid-malformed", "kind", "last", "latitude", "lc", "leave", "leave-all", "lg", "list", "location", "longitude", "max", "max_groups", "max_participants", "max_subject", "mechanism", "media", "message", "message_acks", "method", "microsoft", "missing", "modify", "mute", "name", "nokia", "none", "not-acceptable", "not-allowed", "not-authorized", "notification", "notify", "off", "offline", "order", "owner", "owning", "paid", "participant", "participants", "participating", "password", "paused", "picture", "pin", "ping", "platform", "pop_mean_time", "pop_plus_minus", "port", "presence", "preview", "probe", "proceed", "prop", "props", "p_o", "p_t", "query", "raw", "reason", "receipt", "receipt_acks", "received", "registration", "relay", "remote-server-timeout", "remove", "Replaced by new connection", "request", "required", "resource", "resource-constraint", "response", "result", "retry", "rim", "s.whatsapp.net", "s.us", "seconds", "server", "server-error", "service-unavailable", "set", "show", "sid", "silent", "sound", "stamp", "unsubscribe", "stat", "status", "stream:error", "stream:features", "subject", "subscribe", "success", "sync", "system-shutdown", "s_o", "s_t", "t", "text", "timeout", "TimePassing.caf", "timestamp", "to", "Tri-tone.caf", "true", "type", "unavailable", "uri", "url", "urn:ietf:params:xml:ns:xmpp-sasl", "urn:ietf:params:xml:ns:xmpp-stanzas", "urn:ietf:params:xml:ns:xmpp-streams", "urn:xmpp:delay", "urn:xmpp:ping", "urn:xmpp:receipts", "urn:xmpp:whatsapp", "urn:xmpp:whatsapp:account", "urn:xmpp:whatsapp:dirty", "urn:xmpp:whatsapp:mms", "urn:xmpp:whatsapp:push", "user", "username", "value", "vcard", "version", "video", "w", "w:g", "w:p", "w:p:r", "w:profile:picture", "wait", "x", "xml-not-well-formed", "xmlns", "xmlns:stream", "Xylophone.caf", "1", "WAUTH-1" ]'''




	''' new items: "ib", "DIGEST-MD5-2", "duplicate", "fail", "user-not-found", "s.us", "unsubscribe", "timeout", "urn:xmpp:whatsapp:account", "WAUTH-1" '''

	#unsupported yet:
	''',"true","after","before", "broadcast","count","features","first", "index","invalid-mechanism", "last","max","offline", "proceed","required","sync","elapsed","ip","microsoft","mute","nokia","off","pin","pop_mean_time","pop_plus_minus","port","reason", "server-error","silent","timout", "lc", "lg", "bad-protocol", "none", "remote-server-timeout", "service-unavailable", "w:p", "w:profile:picture", "notification"];'''
	nonce_key = "nonce=\""
	
	
	loginSuccess = QtCore.Signal()
	loginFailed = QtCore.Signal()
	connectionError = QtCore.Signal()
	
	
	def __init__(self,conn,reader,writer,digest):
		super(WALogin,self).__init__();
		
		WADebug.attach(self);
		
		self.conn = conn
		self.out = writer;
		self.inn = reader;
		self.digest = digest;
		
		self._d("WALOGIN INIT");
		
		
	
	def setConnection(self, conn):
		self.connection = conn;

	def run(self):
	
		HOST, PORT = 'bin-nokia.whatsapp.net', 443
		try:
			self.conn.connect((HOST, PORT));
			
			self.conn.connected = True
			self._d("Starting stream");
			self.out.streamStart(self.connection.domain,self.connection.resource);
	
			self.sendFeatures();
			self._d("Sent Features");
			self.sendAuth();
			self._d("Sent Auth");
			self.inn.streamStart();
			self._d("read stream start");
			challengeData = self.readFeaturesAndChallenge();
			self._d("read features and challenge");
			#self._d(challengeData);
			self.sendResponse(challengeData);
			self._d("read stream start");
		
			self.readSuccess();
			#print self.out.out.recv(1638400);
			#sock.send(string)
			#reply = sock.recv(16384)  # limit reply to 16K
			
		except socket.error:
			return self.connectionError.emit()
		except ConnectionClosedException:
			return self.connectionError.emit()
		
	
	def sendFeatures(self):
		toWrite = ProtocolTreeNode("stream:features",None,[ ProtocolTreeNode("receipt_acks",None,None),ProtocolTreeNode("w:profile:picture",{"type":"all"},None), ProtocolTreeNode("w:profile:picture",{"type":"group"},None),ProtocolTreeNode("notification",{"type":"participant"},None), ProtocolTreeNode("status",None,None) ]);
		#toWrite = ProtocolTreeNode("stream:features",None,[ ProtocolTreeNode("receipt_acks",None,None),ProtocolTreeNode("w:profile:picture",{"type":"group"},None) ]);
		#toWrite = ProtocolTreeNode("stream:features",None,[ ProtocolTreeNode("receipt_acks",None,None) ]);
		self.out.write(toWrite);
		#self.out.out.write(0); #HACK
		#self.out.out.write(7); #HACK
		#self.out
		
	def sendAuth(self):
		node = ProtocolTreeNode("auth",{"xmlns":"urn:ietf:params:xml:ns:xmpp-sasl","mechanism":"DIGEST-MD5-1"});
		self.out.write(node);
		
	def readFeaturesAndChallenge(self):
		server_supports_receipt_acks = True;
		root = self.inn.nextTree();
		
		while root is not None:
			if ProtocolTreeNode.tagEquals(root,"stream:features"):
				#self._d("GOT FEATURES !!!!");
				server_supports_receipt_acks = root.getChild("receipt_acks") is not None;
				root = self.inn.nextTree();
				
				continue;
			
			if ProtocolTreeNode.tagEquals(root,"challenge"):
				#self._d("GOT CHALLENGE !!!!");
				self.connection.supports_receipt_acks = self.connection.supports_receipt_acks and server_supports_receipt_acks;
				#String data = new String(Base64.decode(root.data.getBytes()));
				data = base64.b64decode(root.data);
				return data;
		raise Exception("fell out of loop in readFeaturesAndChallenge");
		
		
	def sendResponse(self,challengeData):
		#self.out.out.write(0);  #HACK
		#self.out.out.write(255); #HACK
		response = self.getResponse(challengeData);
		node = ProtocolTreeNode("response",{"xmlns":"urn:ietf:params:xml:ns:xmpp-sasl"}, None, str(base64.b64encode(response)));
		#print "THE NODE::";
		#print node.toString();
		#exit();
		self.out.write(node);
		#clear buf
		self.inn.inn.buf = [];
	
	def getResponse(self,challenge):
		
		i = challenge.index(WALogin.nonce_key);
		
		i+=len(WALogin.nonce_key);
		j = challenge.index('"',i);
		
		nonce = challenge[i:j];
		cnonce = Utilities.str(abs(random.getrandbits(64)),36);
		nc = "00000001";
		bos = ByteArray();
		bos.write(self.md5Digest(self.connection.user + ":" + self.connection.domain + ":" + self.connection.password));
		bos.write(58);
		bos.write(nonce);
		bos.write(58);
		bos.write(cnonce);
		
		digest_uri = "xmpp/"+self.connection.domain;
		
		A1 = bos.toByteArray();
		A2 = "AUTHENTICATE:" + digest_uri;
		
		KD = str(self.bytesToHex(self.md5Digest(A1.getBuffer()))) + ":"+nonce+":"+nc+":"+cnonce+":auth:"+str(self.bytesToHex(self.md5Digest(A2)));
		
		response = str(self.bytesToHex(self.md5Digest(KD)));
		bigger_response = "";
		bigger_response += "realm=\"";
		bigger_response += self.connection.domain
		bigger_response += "\",response=";
		bigger_response += response
		bigger_response += ",nonce=\"";
		bigger_response += nonce
		bigger_response += "\",digest-uri=\""
		bigger_response += digest_uri
		bigger_response += "\",cnonce=\""
		bigger_response += cnonce
		bigger_response += "\",qop=auth";
		bigger_response += ",username=\""
		bigger_response += self.connection.user
		bigger_response += "\",nc="
		bigger_response += nc
		
		
		return bigger_response;

	
	def forDigit(self, b):
		if b < 10:
			return (48+b);
		
		return (97+b-10);
	
	
	def bytesToHex(self,bytes):
		ret = bytearray(len(bytes)*2);
		i = 0;
		for c in range(0,len(bytes)):	
			ub = bytes[c];
			if ub < 0:
				ub+=256;
			ret[i] = self.forDigit(ub >> 4);
			i+=1;
			ret[i] = self.forDigit(ub % 16);
			i+=1;
		
		return ret;
			

	def md5Digest(self,inputx):
		self.digest.reset();
		self.digest.update(inputx);
		return self.digest.digest();	
	
	
	
	def readSuccess(self):
		node = self.inn.nextTree();
		self._d("Login Status: %s"%(node.tag));
		
		
		
		if ProtocolTreeNode.tagEquals(node,"failure"):
			self.loginFailed.emit()
			raise Exception("Login Failure");
		
		ProtocolTreeNode.require(node,"success");
		
		expiration = node.getAttributeValue("expiration");
		
		
		if expiration is not None:
			self._d("Expires: "+str(expiration));
			self.connection.expire_date = expiration;
			
	
		kind = node.getAttributeValue("kind");
		self._d("Account type: %s"%(kind))
		
		if kind == "paid":
			self.connection.account_kind = 1;
		elif kind == "free":
			self.connection.account_kind = 0;
		else:
			self.connection.account_kind = -1;
			
		status = node.getAttributeValue("status");
		self._d("Account status: %s"%(status));
		
		if status == "expired":
			self.loginFailed.emit()
			raise Exception("Account expired on "+str(self.connection.expire_date));
		
		if status == "active":
			if expiration is None:	
				#raise Exception ("active account with no expiration");
				'''@@TODO expiration changed to creation'''
		else:
			self.connection.account_kind = 1;

		self.inn.inn.buf = [];
		
		self.loginSuccess.emit()
	
if __name__ == "__main__":
	w = WALogin(1,2,3)
