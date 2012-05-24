# -*- coding: utf-8 -*-

import time, threading, select;
from utilities import Utilities, S40MD5Digest
from protocoltreenode import BinTreeNodeWriter,BinTreeNodeReader,ProtocolTreeNode
from connengine import MySocketConnection
from walogin import WALogin;
from funstore import FunStore
from waeventbase import WAEventBase
#from contacts import WAContacts;
from messagestore import Key;
from notifier import Notifier
from connmon import ConnMonitor
import sys
from constants import WAConstants
from waexceptions import *
from PySide import QtCore
from PySide.QtCore import QThread, QTimer
from PySide.QtGui import QApplication
from waupdater import WAUpdater
import thread

class WAEventHandler(WAEventBase):
	
	connecting = QtCore.Signal()
	connected = QtCore.Signal();
	sleeping = QtCore.Signal();
	disconnected = QtCore.Signal();
	loginFailed = QtCore.Signal()
	######################################
	new_message = QtCore.Signal(dict);
	typing = QtCore.Signal(str);
	paused = QtCore.Signal(str);
	available = QtCore.Signal(str);
	unavailable = QtCore.Signal(str);
	showUI = QtCore.Signal(str);
	messageSent = QtCore.Signal(dict);
	messageDelivered = QtCore.Signal(dict);
	lastSeenUpdated = QtCore.Signal(str,int);
	updateAvailable = QtCore.Signal(dict);
	
	#########################################
	
	sendTyping = QtCore.Signal(str);
	sendPaused = QtCore.Signal(str);
	getLastOnline = QtCore.Signal(str);
	
	doQuit = QtCore.Signal();
	
	

	def __init__(self,conn):
		self.conn = conn;
		super(WAEventHandler,self).__init__();
		
		self.notifier = Notifier();
		self.connMonitor = ConnMonitor();
		
		self.connMonitor.connected.connect(self.networkAvailable);
		self.connMonitor.disconnected.connect(self.networkDisconnected);
		
		

		
		#self.connMonitor.sleeping.connect(self.networkUnavailable);
		#self.connMonitor.checked.connect(self.checkConnection);
		
		
		self.sendTyping.connect(self.conn.sendTyping);
		self.sendPaused.connect(self.conn.sendPaused);
		self.getLastOnline.connect(self.conn.getLastOnline);
		
		self.connected.connect(self.conn.resendUnsent);
		
		self.pingTimer = QTimer();
		self.pingTimer.timeout.connect(self.sendPing)
		self.pingTimer.start(180000);
		
		#self.connMonitor.start();
		
	
	def quit(self):
		Utilities.debug("got quit!!!")
		#self.connMonitor.exit()
		#self.conn.disconnect()
		
		'''del self.connMonitor
		del self.conn.inn
		del self.conn.out
		del self.conn.login
		del self.conn.stanzaReader'''
		#del self.conn
		self.doQuit.emit();
		
	
	def initialConnCheck(self):
		if self.connMonitor.isOnline():
			self.connMonitor.connected.emit()
		else:
			self.connMonitor.createSession();
		
	
	def onFocus(self):
		'''self.notifier.disable()'''
		
	def onUnfocus(self):
		'''self.notifier.enable();'''
	
	def checkConnection(self):
		try:
			if self.conn.state == 0:
				raise Exception("Not connected");
			elif self.conn.state == 2:
				self.conn.sendPing();
		except:
			print "Connection crashed, reason: %s"%sys.exc_info()[1]
			self.networkDisconnected()
			self.networkAvailable();
			
		Utilities.debug("CHECK PASSEDDDDDDDDDDDDDDD")
	
	def onLoginFailed(self):
		self.loginFailed.emit()
	
	def onLastSeen(self,jid,seconds,status):
		print "GOT LAST SEEN ON FROM %s"%(jid)
		
		if seconds is not None:
			self.lastSeenUpdated.emit(jid,int(seconds));
		
	
	def onDirty(self,categories):
		print categories
		#ignored by whatsapp?
	
	def onAccountChanged(self,account_kind,expire):
		#nothing to do here
		return;
		
	def onRelayRequest(self,pin,timeoutSeconds,idx):
		#self.wtf("RELAY REQUEST");
		return
	
	def sendPing(self):
		print "Pinging"
		if self.connMonitor.isOnline() and self.conn.state == 2:
			self.conn.sendPing();
		else:
			self.connMonitor.createSession();
	
	def onPing(self,idx):
		print "Sending PONG"
		self.conn.sendPong(idx)
		
	
	def wtf(self,what):
		print "%s, WTF SHOULD I DO NOW???"%(what)
	
		
	
	def networkAvailable(self):
		print "NET AVAILABLE"
		self.updater = WAUpdater()
		self.updater.updateAvailable.connect(self.updateAvailable)
		
		
		self.connecting.emit();
		
		#thread.start_new_thread(self.conn.changeState, (2,))
		
		self.conn.changeState(2);
		self.updater.run()
		
		#self.conn.disconnect()
		
		
		
		
	def networkDisconnected(self):
		self.sleeping.emit();
		self.conn.changeState(0);
		#thread.start_new_thread(self.conn.changeState, (0,))
		#self.conn.disconnect();
		print "NET SLEEPING"
		
	def networkUnavailable(self):
		self.disconnected.emit();
		print "NET UNAVAILABLE";
		
		
	def onUnavailable(self):
		print "SEND UNAVAILABLE"
		self.conn.sendUnavailable();
	
	
	def conversationOpened(self,jid):
		self.notifier.hideNotification(jid);
	
	def onAvailable(self):
		self.conn.sendAvailable();
	
	def send_message(self,to_id,msg_text):
		
		fmsg = WAXMPP.message_store.store.Message.create();
		conversation = WAXMPP.message_store.getOrCreateConversationByJid(to_id);
		fmsg.setData({"status":0,"content":msg_text.encode('utf-8'),"conversation_id":conversation.id,"type":1})
		WAXMPP.message_store.pushMessage(fmsg)
		
		self.conn.sendMessageWithBody(fmsg);
	
	def notificationClicked(self,jid):
		print "SHOW UI for "+jid
		self.showUI.emit(jid);

	def message_received(self,fmsg,duplicate = False):
		msg_type = "duplicate" if duplicate else "new";

		if fmsg.content is not None:
			#self.new_message.emit({"data":fmsg.content,"user_id":fmsg.getContact().jid})
			try:
				msg_contact = WAXMPP.message_store.store.getCachedContacts()[fmsg.getContact().number];
			except:
				msg_contact = WAXMPP.message_store.store.Contact.create()
				msg_contact.name= fmsg.getContact().number
				msg_contact.picture = WAConstants.DEFAULT_CONTACT_PICTURE
				msg_contact.jid = eval(fmsg.key.toString()).remote_jid
				
			
			self.notifier.newMessage(msg_contact.jid, msg_contact.name, fmsg.content,None if type(msg_contact.picture) == str else str(msg_contact.picture.path()),callback = self.notificationClicked);
			
			Utilities.debug("A {msg_type} message was received: {data}".format(msg_type=msg_type, data=fmsg.content));
		else:
			Utilities.debug("A {msg_type} message was received".format(msg_type=msg_type));

		if(fmsg.wantsReceipt):
			self.conn.sendMessageReceived(fmsg);

	
	def subjectReceiptRequested(self,to,idx):
		self.conn.sendSubjectReceived(to,idx);
		
		
			
	def presence_available_received(self,fromm):
		if(fromm == self.conn.jid):
			return
		self.available.emit(fromm)
		Utilities.debug("{Friend} is now available".format(Friend = fromm));
	
	def presence_unavailable_received(self,fromm):
		if(fromm == self.conn.jid):
			return
		self.unavailable.emit(fromm)
		Utilities.debug("{Friend} is now unavailable".format(Friend = fromm));
	
	def typing_received(self,fromm):
		Utilities.debug("{Friend} is typing ".format(Friend = fromm))
		self.typing.emit(fromm);

	def paused_received(self,fromm):
		Utilities.debug("{Friend} has stopped typing ".format(Friend = fromm))
		self.paused.emit(fromm);

	

	def message_error(self,fmsg,errorCode):
		Utilities.debug("Message Error {0}\n Error Code: {1}".format(fmsg,str(errorCode)));

	def message_status_update(self,fmsg):
		Utilities.debug("Message status updated {0}".format(fmsg.status));
		contact = fmsg.getContact();
		modelData = fmsg.getModelData();
		modelData["Contact"] = contact.getModelData();
		if fmsg.status == WAXMPP.message_store.store.Message.STATUS_SENT:
			self.messageSent.emit(modelData);
		elif fmsg.status == WAXMPP.message_store.store.Message.STATUS_DELIVERED:
			self.messageDelivered.emit(modelData); 
		

class StanzaReader(QThread):
	def __init__(self,connection):
		self.connection = connection
		self.inn = connection.inn;
		self.eventHandler = None;
		self.groupEventHandler = None;
		super(StanzaReader,self).__init__();
		self.requests = {};

	def setEventHandler(self,handler):
		self.eventHandler = handler;

	def run(self):
		flag = True;
		Utilities.debug("Read thread started");
		while flag == True:
			
			Utilities.debug("waiting");
			ready = select.select([self.inn.rawIn], [], [])
			if ready[0]:
				try:
					node = self.inn.nextTree();
				except ConnectionClosedException:
					print "Socket closed, got 0 bytes"
					
					if self.eventHandler.connMonitor.isOnline():
						self.eventHandler.connMonitor.connected.emit()
					return
				except:
					print "Unhandled error: %s .restarting connection " % sys.exc_info()[1]
					if self.eventHandler.connMonitor.isOnline():
						self.eventHandler.connMonitor.connected.emit()
					else:
						print "Not online, aborting restart"
					return
					
					

				self.lastTreeRead = int(time.time())*1000;
			    
			    
			    
			    
			    
			    
			    
			    
				if node is not None:
					if ProtocolTreeNode.tagEquals(node,"iq"):
						iqType = node.getAttributeValue("type")
						idx = node.getAttributeValue("id")
						jid = node.getAttributeValue("from");
						
						if iqType is None:
							raise Exception("iq doesn't have type")
						
						if iqType == "result":
							if self.requests.has_key(idx):
								self.requests[idx](node,jid)
								del self.requests[idx]
							elif idx.startswith(self.connection.user):
								accountNode = node.getChild(0)
								ProtocolTreeNode.require(accountNode,"account")
								kind = accountNode.getAttributeValue("kind")
								
								if kind == "paid":
									self.connection.account_kind = 1
								elif kind == "free":
									self.connection.account_kind = 0
								else:
									self.connection.account_kind = -1
								
								expiration = accountNode.getAttributeValue("expiration")
								
								if expiration is None:
									raise Exception("no expiration")
								
								try:
									self.connection.expire_date = long(expiration)
								except ValueError:
									raise IOError("invalid expire date %s"%(expiration))
								
								self.eventHandler.onAccountChanged(self.connection.account_kind,self.connection.expire_date)
						elif iqType == "error":
							if self.requests.has_key(idx):
								self.requests[idx](node)
								del self.requests[idx]
						elif iqType == "get":
							childNode = node.getChild(0)
							if ProtocolTreeNode.tagEquals(childNode,"ping"):
								self.eventHandler.onPing(idx)
							elif ProtocolTreeNode.tagEquals(childNode,"query") and jid is not None and "http://jabber.org/protocol/disco#info" == childNode.getAttributeValue("xmlns"):
								pin = childNode.getAttributeValue("pin");
								timeoutString = childNode.getAttributeValue("timeout");
								try:
									timeoutSeconds = int(timeoutString) if timoutString is not None else None
								except ValueError:
									raise Exception("relay-iq exception parsing timeout %s "%(timeoutString))
								
								if pin is not None:
									self.eventHandler.onRelayRequest(pin,timeoutSeconds,idx)
						elif iqType == "set":
							childNode = node.getChild(0)
							if ProtocolTreeNode.tagEquals(childNode,"query"):
								xmlns = childNode.getAttributeValue("xmlns")
								
								if xmlns == "jabber:iq:roster":
									itemNodes = childNode.getAllChildren("item");
									ask = ""
									for itemNode in itemNodes:
										jid = itemNode.getAttributeValue("jid")
										subscription = itemNode.getAttributeValue("subscription")
										ask = itemNode.getAttributeValue("ask")
						else:
							raise Exception("Unkown iq type %s"%(iqType))
					
					elif ProtocolTreeNode.tagEquals(node,"presence"):
						xmlns = node.getAttributeValue("xmlns")
						jid = node.getAttributeValue("from")
						
						if (xmlns is None or xmlns == "urn:xmpp") and jid is not None:
							presenceType = node.getAttributeValue("type")
							if presenceType == "unavailable":
								self.eventHandler.presence_unavailable_received(jid);
							elif presenceType is None or presenceType == "available":
								self.eventHandler.presence_available_received(jid);
						
						elif xmlns == "w" and jid is not None:
							add = node.getAttributeValue("add");
							remove = node.getAttributeValue("remove")
							status = node.getAttributeValue("status")
							
							if add is not None:
								print "GROUP EVENT ADD"
							elif remove is not None:
								print "GROUP EVENT REMOVE"
							elif status == "dirty":
								categories = self.parseCategories(node);
								self.eventHandler.onDirty(categories);
					elif ProtocolTreeNode.tagEquals(node,"message"):
						self.parseMessage(node)	

				
				'''
				if self.eventHandler is not None:
					if ProtocolTreeNode.tagEquals(node,"presence"):

						fromm = node.getAttributeValue("from");
						
						if node.getAttributeValue("type") == "unavailable":
							self.eventHandler.presence_unavailable_received(fromm);
						else:
							self.eventHandler.presence_available_received(fromm);
					
					elif ProtocolTreeNode.tagEquals(node,"message"):
						self.parseMessage(node);
					else:
						Utilities.debug("Not implemented");
				'''
	
	
	def handlePingResponse(self,node,fromm):
		print "Ping response received"
		    		
			    		
	def handleLastOnline(self,node,jid=None):
		firstChild = node.getChild(0);
		ProtocolTreeNode.require(firstChild,"query");
		seconds = firstChild.getAttributeValue("seconds");
		status = None
		status = firstChild.data
		
		try:
			if seconds is not None and jid is not None:
				self.eventHandler.onLastSeen(jid,int(seconds),status);
		except:
			print "Ignored exception in handleLastOnline "+ sys.exc_info()[1]
			
			

	def parseCategories(self,dirtyNode):
		categories = {}
		if dirtyNode.children is not None:
			for childNode in dirtyNode.getAllChildren():
				if ProtocolTreeNode.tagEquals(childNode,"category"):
					cname = childNode.getAttributeValue("name");
					timestamp = childNode.getAttributeValue("timestamp")
					categories[cname] = timestamp
		
		return categories

	def parseMessage(self,messageNode):
	
		#throw media in the garbage
		
		if messageNode.getChild("media") is not None:
			return
	
		fmsg = WAXMPP.message_store.store.Message.create()
		
		fmsg.wantsReceipt = False
		
		
		msg_id = messageNode.getAttributeValue("id");
		attribute_t = messageNode.getAttributeValue("t");
		fromAttribute = messageNode.getAttributeValue("from");
		author = messageNode.getAttributeValue("author");

		typeAttribute = messageNode.getAttributeValue("type");

		if typeAttribute == "error":
			errorCode = 0;
			errorNodes = messageNode.getAllChildren("error");
			for errorNode in errorNodes:
				codeString = errorNode.getAttributeValue("code")
				try:
					errorCode = int(codeString);
				except ValueError:
					'''catch value error'''
			message = None;
			if fromAttribute is not None and msg_id is not None:
				key = Key(fromAttribute,True,msg_id);
				message = message_store.get(key.toString());

			if message is not None:
				message.status = 7
				self.eventHandler.message_error(message,errorCode);
		
		elif typeAttribute == "subject":
			receiptRequested = False;
			requestNodes = messageNode.getAllChildren("request");
			for requestNode in requestNodes:
				if requestNode.getAttributeValue("xmlns") == "urn:xmpp:receipts":
					receiptRequested = True;
			
			bodyNode = messageNode.getChild("body");
			newSubject = None if bodyNode is None else bodyNode.data;

			if newSubject is not None and self.groupEventHandler is not None:
				self.groupEventHandler.group_new_subject(fromAttribute,author,newSubject,int(attribute_t));
			
			if receiptRequested and self.eventHandler is not None:
				self.eventHandler.subjectReceiptRequested(fromAttribute,msg_id);

		elif typeAttribute == "chat":
			duplicate = False;
			wantsReceipt = False;
			messageChildren = [] if messageNode.children is None else messageNode.children

			for childNode in messageChildren:
				if ProtocolTreeNode.tagEquals(childNode,"composing"):
						if self.eventHandler is not None:
							self.eventHandler.typing_received(fromAttribute);
				elif ProtocolTreeNode.tagEquals(childNode,"paused"):
						if self.eventHandler is not None:
							self.eventHandler.paused_received(fromAttribute);
				
				elif ProtocolTreeNode.tagEquals(childNode,"body") and msg_id is not None:
					msgdata = childNode.data;
					key = Key(fromAttribute,False,msg_id);
					ret = WAXMPP.message_store.get(key.toString());

					
					if ret is None:
						conversation = WAXMPP.message_store.getOrCreateConversationByJid(fromAttribute);
						fmsg.setData({"status":0,"key":key.toString(),"content":msgdata,"conversation_id":conversation.id,"type":WAXMPP.message_store.store.Message.TYPE_RECEIVED});
						
						WAXMPP.message_store.pushMessage(fmsg)
						fmsg.key = key
						
						#if self.eventHandler is not None:
						#self.eventHandler.message_received(fmsg);
					else:
						fmsg.key = eval(ret.key)
						duplicate = True;
				elif not (ProtocolTreeNode.tagEquals(childNode,"active")):
					if ProtocolTreeNode.tagEquals(childNode,"request"):
						fmsg.wantsReceipt = True;
					
					elif ProtocolTreeNode.tagEquals(childNode,"notify"):
						fmsg.notify_name = childNode.getAttributeValue("name");
					elif ProtocolTreeNode.tagEquals(childNode,"x"):
						xmlns = childNode.getAttributeValue("xmlns");
						if "jabber:x:event" == xmlns and msg_id is not None:
							
							key = Key(fromAttribute,True,msg_id);
							message = WAXMPP.message_store.get(key.toString());
							if message is not None:
								WAXMPP.message_store.updateStatus(message,WAXMPP.message_store.store.Message.STATUS_SENT)
								
								if self.eventHandler is not None:
									self.eventHandler.message_status_update(message);
						elif "jabber:x:delay" == xmlns:
							continue; #TODO FORCED CONTINUE, WHAT SHOULD I DO HERE? #wtf?
							stamp_str = childNode.getAttributeValue("stamp");
							if stamp_str is not None:
								stamp = stamp_str	
								fmsg.timestamp = stamp;
								fmsg.offline = True;
					else:
						if ProtocolTreeNode.tagEquals(childNode,"delay") or not ProtocolTreeNode.tagEquals(childNode,"received") or msg_id is None:
							continue;
						key = Key(fromAttribute,True,msg_id);
						message = WAXMPP.message_store.get(key.toString());
						if message is not None:
							WAXMPP.message_store.updateStatus(message,WAXMPP.message_store.store.Message.STATUS_DELIVERED)
							if self.eventHandler is not None:
								self.eventHandler.message_status_update(message);
							print  self.connection.supports_receipt_acks
							if self.connection.supports_receipt_acks:
								
								receipt_type = childNode.getAttributeValue("type");
								if receipt_type is None or receipt_type == "delivered":
									self.connection.sendDeliveredReceiptAck(fromAttribute,msg_id); 
								elif receipt_type == "visible":
									self.connection.sendVisibleReceiptAck(fromAttribute,msg_id);  
					
			
			
			if fmsg.timestamp is None:
				fmsg.timestamp = time.time()*1000;
				fmsg.offline = False;
			
			if self.eventHandler is not None:
				self.eventHandler.message_received(fmsg,duplicate);
			



class WAXMPP():
	message_store = None
	def __init__(self,domain,resource,user,push_name,password):
	
		self.domain = domain;
		self.resource = resource;
		self.user=user;
		self.push_name=push_name;
		self.password = password;
		self.jid = user+'@'+domain
		self.fromm = user+'@'+domain+'/'+resource;
		self.supports_receipt_acks = False;
		self.msg_id = 0;
		self.state = 0 #0 disconnected 1 connecting 2 connected
		self.retry = True
		self.eventHandler = WAEventHandler(self);
		self.conn =MySocketConnection();		
		self.stanzaReader = None
		self.login = None;
		
		self.disconnectRequested = False
		
		self.connTries = 0;
		
		self.verbose = True
		self.iqId = 0;
		self.lock = threading.Lock()
		
		self.waiting = 0;
		
		#super(WAXMPP,self).__init__();
		
		self.eventHandler.initialConnCheck();
		
		#self.do_login();
		
	
	
	
	def setContactsManager(self,contactsManager):
		self.contactsManager = contactsManager
		
	def setReceiptAckCapable(self,can):
		#print "Switching to True"
		self.supports_receipt_acks = True;
		#print self.supports_receipt_acks

		
	
	
	
	def onLoginSuccess(self):
		self.changeState(4)
		
		self.connectionTries = 0
		c = StanzaReader(self);
		
		c.setEventHandler(self.eventHandler);
		
		#initial presence
		self.stanzaReader = c
		
		self.stanzaReader.start();
		
		
		self.sendClientConfig('','',False,'');
		self.sendAvailableForChat();
		self.eventHandler.connected.emit();
		
		

	def onConnectionError(self):
		self.login.wait()
		self.conn.close()	

		self.changeState(3)
		
		'''
		if self.connTries < 4:
			print "trying connect "+str(self.connTries)
			self.retryLogin()
		else:
			print "Too many tries, trying in 30000"
			t = QTimer.singleShot(30000,self.retryLogin)
		'''
	
	
	
	def disconnect(self):
		self.conn.close()
	
	def retryLogin(self):
		self.changeState(3);
	
	def changeState(self,newState):
		print "Entering critical area"
		self.waiting+=1
		self.lock.acquire()
		self.waiting-=1
		print "inside critical area"
		
		if self.state == 0:
			if newState == 2:
				self.state = 1
				self.do_login();
				
		elif self.state == 1:
			#raise Exception("mutex violated! I SHOULDN'T BE HERE !!!")
			if newState == 0:
				self.retry = False
			elif newState == 2:
				self.retry = True
			elif newState == 3: #failed
				if self.retry:
					
					
					if self.connTries >= 3:
						print "%i or more failed connections. Will try again in 30 seconds" % self.connTries
						QTimer.singleShot(30000,self.retryLogin)
						self.connTries-=1
						
					else:	
						self.do_login()
						self.connTries+=1
				else:
					self.connTries = 0
					self.state = 0
					self.retry = True
					
			elif newState == 4:#connected
				self.connTries = 0
				self.retry = True
				self.state = 2
		elif self.state == 2:
			if newState == 2:
				self.disconnect()
				self.state = 1
				self.do_login()
			elif newState == 0:
				self.disconnect()
				self.state = 0
		
		
		print "Releasing lock"
		self.lock.release()
		
		
			

	def do_login(self):
		
		self.conn = conn = MySocketConnection();
		#conn.connect((HOST, PORT));

		self.inn = BinTreeNodeReader(conn,WALogin.dictionary);
		self.out = BinTreeNodeWriter(conn,WALogin.dictionary);
		
		
		self.login = WALogin(conn,self.inn,self.out,S40MD5Digest());
		
		
		self.login.setConnection(self);
		
		self.login.loginSuccess.connect(self.onLoginSuccess)
		self.login.loginFailed.connect(self.eventHandler.onLoginFailed);
		
		self.login.connectionError.connect(self.onConnectionError)
		self.login.start();
		
		'''try:
			self.login.login();
		except:
			print "LOGIN FAILED"
			#sys.exit()
			return
		'''
		



		#fmsg = FMessage();
		#fmsg.setData('201006960035@s.whatsapp.net',True,"Hello World");
		
		#self.sendIq();
		#self.inn.nextTree();
		#print self.inn.inn.buf;
		#exit();
		#self.inn.nextTree();
		
		
		
		#self.sendMessageWithBody("ok");
		#node = self.inn.nextTree();
		#print node.toString();

		#self.sendSubscribe("201006960035@s.whatsapp.net");
		
		#self.sendMessageWithBody("OK");
		#self.sendMessageWithBody("OK");
		#node = self.inn.nextTree();
		#print node.toString();
		#raw_input();
		#self.sendMessageWithBody(fmsg);
	
	
	def resendUnsent(self):
		'''
			Resends all unsent messages, should invoke on connect
		'''
		
		
		messages = WAXMPP.message_store.getUnsent();
		print "Resending %i old messages"%(len(messages))
		for m in messages:
			self.sendMessageWithBody(m);
		
		
	
	def sendTyping(self,jid):
		print "SEND TYPING TO JID"
		composing = ProtocolTreeNode("composing",{"xmlns":"http://jabber.org/protocol/chatstates"})
		message = ProtocolTreeNode("message",{"to":jid,"type":"chat"},[composing]);
		self.out.write(message);
		
	
		
	def sendPaused(self,jid):
		print "SEND PAUSED TO JID"
		composing = ProtocolTreeNode("paused",{"xmlns":"http://jabber.org/protocol/chatstates"})
		message = ProtocolTreeNode("message",{"to":jid,"type":"chat"},[composing]);
		self.out.write(message);

	
	
	def getSubjectMessage(self,to,msg_id,child):
		messageNode = ProtocolTreeNode("message",{"to":to,"type":"subject","id":msg_id},[child]);
		
		return messageNode
	
	def sendSubjectReceived(self,to,msg_id):
		print "Sending subject recv receipt"
		receivedNode = ProtocolTreeNode("received",{"xmlns": "urn:xmpp:receipts"});
		messageNode = self.getSubjectMessage(to,msg_id,receivedNode);
		self.out.write(messageNode);

	def sendMessageReceived(self,fmsg):
		receivedNode = ProtocolTreeNode("received",{"xmlns": "urn:xmpp:receipts"})
		messageNode = ProtocolTreeNode("message",{"to":fmsg.key.remote_jid,"type":"chat","id":fmsg.key.id},[receivedNode]);
		self.out.write(messageNode);


	def sendDeliveredReceiptAck(self,to,msg_id):
		self.out.write(self.getReceiptAck(to,msg_id,"delivered"));
	
	def sendVisibleReceiptAck(self,to,msg_id):
		self.out.write(self.getReceiptAck(to,msg_id,"visible"));
	
	def getReceiptAck(self,to,msg_id,receiptType):
		ackNode = ProtocolTreeNode("ack",{"xmlns":"urn:xmpp:receipts","type":receiptType})
		messageNode = ProtocolTreeNode("message",{"to":to,"type":"chat","id":msg_id},[ackNode]);
		return messageNode;

	def makeId(self,prefix):
		self.iqId += 1
		idx = ""
		if self.verbose:
			idx += prefix + str(self.iqId);
		else:
			idx = "%x" % self.iqId
		
		return idx
		 	
	
	def sendPing(self):
		
		idx = self.makeId("ping_")
		self.stanzaReader.requests[idx] = self.stanzaReader.handlePingResponse;
		
		pingNode = ProtocolTreeNode("ping",{"xmlns":"w:p"});
		iqNode = ProtocolTreeNode("iq",{"id":idx,"type":"get","to":self.domain},[pingNode]);
		self.out.write(iqNode);
		
	
	def sendPong(self,idx):
		iqNode = ProtocolTreeNode("iq",{"type":"result","to":self.domain,"id":idx})
		self.out.write(iqNode);
	
	def getLastOnline(self,jid):
		
		if len(jid.split('-')) == 2: #SUPER CANCEL SUBSCRIBE TO GROUP
			return
		
		self.sendSubscribe(jid);
		
		print "presence request Initiated for %s"%(jid)
		idx = self.makeId("last_")
		self.stanzaReader.requests[idx] = self.stanzaReader.handleLastOnline;
		
		query = ProtocolTreeNode("query",{"xmlns":"jabber:iq:last"});
		iqNode = ProtocolTreeNode("iq",{"id":idx,"type":"get","to":jid},[query]);
		self.out.write(iqNode)
	
	
	def sendIq(self):
		node = ProtocolTreeNode("iq",{"to":"g.us","type":"get","id":str(int(time.time()))+"-0"},None,'expired');
		self.out.write(node);

		node = ProtocolTreeNode("iq",{"to":"s.whatsapp.net","type":"set","id":str(int(time.time()))+"-1"},None,'expired');
		self.out.write(node);

	def sendAvailableForChat(self):
		presenceNode = ProtocolTreeNode("presence",{"name":self.push_name})
		self.out.write(presenceNode);
		
	def sendAvailable(self):
		if self.state != 2:
			return
		presenceNode = ProtocolTreeNode("presence",{"type":"available"})
		self.out.write(presenceNode);
	
	
	def sendUnavailable(self):
		if self.state != 2:
			return
		presenceNode = ProtocolTreeNode("presence",{"type":"unavailable"})
		self.out.write(presenceNode);
		

	def sendSubscribe(self,to):
			presenceNode = ProtocolTreeNode("presence",{"type":"subscribe","to":to});
			
			self.out.write(presenceNode);

	def sendMessageWithBody(self,fmsg):
			#bodyNode = ProtocolTreeNode("body",None,message.data);
			#self.out.write(self.getMessageNode(message,bodyNode));

			bodyNode = ProtocolTreeNode("body",None,None,fmsg.content);
			self.out.write(self.getMessageNode(fmsg,bodyNode));
			self.msg_id+=1;

	
	def sendClientConfig(self,sound,pushID,preview,platform):
		idx = self.makeId("config_");
		configNode = ProtocolTreeNode("config",{"xmlns":"urn:xmpp:whatsapp:push","sound":sound,"id":pushID,"preview":"1" if preview else "0","platform":platform})
		iqNode = ProtocolTreeNode("iq",{"id":idx,"type":"set","to":self.domain},[configNode]);
		
		self.out.write(iqNode);
		
	
	def getMessageNode(self,fmsg,child):
			requestNode = None;
			serverNode = ProtocolTreeNode("server",None);
			xNode = ProtocolTreeNode("x",{"xmlns":"jabber:x:event"},[serverNode]);
			childCount = (0 if requestNode is None else 1) +2;
			messageChildren = [None]*childCount;
			i = 0;
			if requestNode is not None:
				messageChildren[i] = requestNode;
				i+=1;
			#System.currentTimeMillis() / 1000L + "-"+1
			messageChildren[i] = xNode;
			i+=1;
			messageChildren[i]= child;
			i+=1;
			
			key = eval(fmsg.key)
			messageNode = ProtocolTreeNode("message",{"to":key.remote_jid,"type":"chat","id":key.id},messageChildren)
			
			
			return messageNode;




class FMessage():
	generating_id = 0;
	generating_header = str(int(time.time()))+"-";
	def __init__(self,key = None, remote_jid = None,from_me=None,data=None,image=None):
		self.data = data;
		self.wantsReceipt = False;
		self.timestamp = None;
		if key is not None:
			self.setKey(key);
		elif remote_jid is not None and from_me is not None and data is not None:
			self.setData(remote_jid,from_me,data,image)
	
	def setKey(self,key):
		self.key = key;
		WAXMPP.message_store.put(key,self);

	def setData(self, remote_jid ,from_me,data,image=None):
		localKey = Key(remote_jid,from_me,FMessage.generating_header+str(FMessage.generating_id))

		while WAXMPP.message_store.get(localKey) is not None:
			FMessage.generating_id += 1
			localKey = Key(remote_jid,from_me,FMessage.generating_header+str(FMessage.generating_id))
			
		WAXMPP.message_store.put(localKey,self);
		self.key = localKey;
		if data is not None:
			self.data = data;
			self.thumb_image = image;
			self.timestamp = int(time.time())*1000;

