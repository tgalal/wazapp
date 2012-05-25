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
from datastore import DataStore;
import sqlite3
import os
import shutil
from Models.contact import Contact;
from Models.message import Message;
from Models.conversation import *


class LiteStore(DataStore):
	db_dir = os.path.expanduser('~/.wazapp');
	
	def __init__(self,current_id):
		self.status = False;
		self.currentId = current_id;
		super(LiteStore,self).__init__(current_id);
		self.db_name = current_id+".db";
		self.db_path = self.get_db_path(current_id);
		
		self.cachedContacts = None;
		
		if not os.path.exists(LiteStore.db_dir):
			os.makedirs(LiteStore.db_dir);

		if not os.path.exists(self.db_path):
			self.status = False;
			#self.conn = sqlite3.connect(self.db_path)
		else:
			self.conn = sqlite3.connect(self.db_path,check_same_thread = False)
			self.status = True;
			self.c = self.conn.cursor();
			self.initModels();
	
	
	def connect(self):
		self.conn = sqlite3.connect(self.db_path,check_same_thread = False)
		self.c = self.conn.cursor();
		
	
	def initModels(self):
		self.Contact = Contact();
		self.Contact.setStore(self);
		
		self.SingleConversation = SingleConversation();
		self.SingleConversation.setStore(self);
		
		self.Conversation = self.SingleConversation
		
		self.Message = Message();
		self.Message.setStore(self);
		
	def get_db_path(self,user_id):
		return LiteStore.db_dir+"/"+self.db_name;

	
	def cacheContacts(self,contacts):
		print "CACHING"
		self.cachedContacts = contacts;
		print "CACHED"
	
	def getCachedContacts(self):
		print "GETTING"
		return self.cachedContacts;
	
	def getContacts(self):
		return self.Contact.fetchAll();

	def reset(self):
		
		self.db_path = self.get_db_path(self.currentId);
		self.conn = sqlite3.connect(self.db_path,check_same_thread = False)
		#shutil.rmtree(LiteStore.db_dir);
		
		
		c = self.conn.cursor()


		contacts_q = 'CREATE  TABLE "main"."contacts" ("id" INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , "number" VARCHAR NOT NULL  UNIQUE , "jid" VARCHAR NOT NULL, "last_seen_on" DATETIME, "status" VARCHAR)'
		#chats_q = 'CREATE  TABLE "main"."chats" ("id" INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , "contact_id" INTEGER NOT NULL , "date" DATETIME NOT NULL  DEFAULT CURRENT_TIMESTAMP, "status" INTEGER NOT NULL  DEFAULT 0, "content" TEXT NOT NULL,"key" VARCHAR NOT NULL )'
		
		#sent_q = 'CREATE  TABLE "main"."sent" ("id" INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , "contact_id" INTEGER NOT NULL , "date" DATETIME NOT NULL  DEFAULT CURRENT_TIMESTAMP, "status" INTEGER NOT NULL  DEFAULT 0, "content" TEXT NOT NULL,"key" VARCHAR NOT NULL )'
		
		#received_q = 'CREATE  TABLE "main"."received" ("id" INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , "contact_id" INTEGER NOT NULL , "date" DATETIME NOT NULL  DEFAULT CURRENT_TIMESTAMP, "content" TEXT NOT NULL,"key" VARCHAR NOT NULL )'
		
		
		messages_q = 'CREATE  TABLE "main"."messages" ("id" INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , "conversation_id" INTEGER NOT NULL, "timestamp" INTEGER NOT NULL, "status" INTEGER NOT NULL DEFAULT 0, "content" TEXT NOT NULL,"key" VARCHAR NOT NULL,"type" INTEGER NOT NULL DEFAULT 0)'
		
		conversations_q = 'CREATE TABLE "main"."singleconversations" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"contact_id" INTEGER NOT NULL, "created" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP)'#, "is_read" INTEGER NOT NULL DEFAULT 0) '
		
		#conversations_users_q = 'CREATE TABLE "main"."conversations_contacts" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, contact_id,conversation_id)'
	
		
		c.execute(contacts_q);
		#c.execute(sent_q);
		#c.execute(received_q);
		c.execute(messages_q);
		c.execute(conversations_q);
		#c.execute(conversations_users_q);
		
		
		
		self.c = c;
		
		self.status = True;
		self.initModels();
		
if __name__ == "__main__":
	l = LiteStore("1234");
	
