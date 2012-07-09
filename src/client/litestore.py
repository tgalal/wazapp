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
from datastore import DataStore;
import sqlite3
import os
import shutil
from Models.contact import Contact;
from Models.message import Message, Groupmessage;
from Models.conversation import *
from Models.mediatype import Mediatype
from Models.media import Media

from wadebug import SqlDebug


class LiteStore(DataStore):
	db_dir = os.path.expanduser('~/.wazapp');
	
	def __init__(self,current_id):
		self._d = SqlDebug();
		
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
			self.conn = sqlite3.connect(self.db_path,check_same_thread = False,isolation_level=None)
			self.status = True;
			self.c = self.conn.cursor();
			#self.initModels();
	
	
	def connect(self):
		self.conn = sqlite3.connect(self.db_path,check_same_thread = False,isolation_level=None)
		self.c = self.conn.cursor();
		
	
	def initModels(self):
		self.Contact = Contact();
		self.Contact.setStore(self);
		
		self.Conversation = Conversation();
		self.Conversation.setStore(self);
		
		self.ConversationManager = ConversationManager();
		self.ConversationManager.setStore(self);
		
		self.Groupconversation = Groupconversation();
		self.Groupconversation.setStore(self);
		
		self.GroupconversationsContacts = GroupconversationsContacts();
		self.GroupconversationsContacts.setStore(self);
		
		self.Mediatype = Mediatype();
		self.Mediatype.setStore(self);
		
		
		self.Media = Media()
		self.Media.setStore(self)
		
		self.Message = Message();
		self.Message.setStore(self);
		
		self.Groupmessage = Groupmessage();
		self.Groupmessage.setStore(self);
		
		#self.Groupmedia = Groupmedia()
		#self.Groupmedia.setStore(self)
		
	def get_db_path(self,user_id):
		return LiteStore.db_dir+"/"+self.db_name;

	
	def cacheContacts(self,contacts):
		self.cachedContacts = contacts;
	
	def getCachedContacts(self):
		return self.cachedContacts;
	
	def getContacts(self):
		return self.Contact.fetchAll();
	
	
	def reset(self):
		
		self.db_path = self.get_db_path(self.currentId);
		self.conn = sqlite3.connect(self.db_path,check_same_thread = False,isolation_level=None)
		#shutil.rmtree(LiteStore.db_dir);
		
		
			
		self.c = self.conn.cursor()
		
		self.prepareBase();
		self.prepareGroupConversations();
		
		self.status = True;
		#self.initModels();
		
	
	
	def tableExists(self,tableName):
		c = self.conn.cursor()
		q = "SELECT name FROM sqlite_master WHERE type='table' AND name='%s'" % tableName;
		c.execute(q);
		return len(c.fetchall())
	
	def columnExists(self,tableName,columnName):
		q = "PRAGMA table_info(%s)"%tableName
		c = self.conn.cursor()
		c.execute(q)
		
		for item in c.fetchall():
			if item[1] == columnName:
				return True
		
		return False
		
	def updateDatabase(self):
		
		
		
		##>0.2.6 check that singleconversations is renamed to conversations
		
		self._d.d("Checking > 0.2.6 updates")
		
		if not self.tableExists("conversations"):
			self._d.d("Renaming single conversations to conversations")
			
			q = "ALTER TABLE singleconversations RENAME TO conversations;"
			c = self.conn.cursor()
			c.execute(q);
			
			#q = "PRAGMA writable_schema = 1";
			#UPDATE SQLITE_MASTER SET SQL = 'CREATE TABLE BOOKS ( title TEXT NOT NULL, publication_date TEXT)' WHERE NAME = 'BOOKS';
			#q = "PRAGMA writable_schema = 0";
		
		self._d.d("Checking addition of media_id and created columns in messages")
		
		q = "PRAGMA table_info(messages)"
		c = self.conn.cursor()
		c.execute(q)
		
		media_id = self.columnExists("messages","media_id");
		created = self.columnExists("messages","created");
		
		if not media_id:
			self._d.d("media_id Not found, altering table")
			c.execute("Alter TABLE messages add column 'media_id' INTEGER")
		
		if not created:
			self._d.d("created Not found, altering table")
			c.execute("Alter TABLE messages add column 'created' INTEGER")
			
			self._d.d("Copying data from timestamp to created col")
			c.execute("update messages set created = timestamp")
			
			
		self._d.d("Checking addition of 'new' column to conversation")
		
		newCol = self.columnExists("conversations","new");
		
		if not newCol:
			self._d.d("'new' not found in conversations. Creating")
			c.execute("ALTER TABLE conversations add column 'new' INTEGER NOT NULL DEFAULT 0")
			
		

	def prepareBase(self):
		contacts_q = 'CREATE  TABLE "main"."contacts" ("id" INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , "number" VARCHAR NOT NULL  UNIQUE , "jid" VARCHAR NOT NULL, "last_seen_on" DATETIME, "status" VARCHAR)'
		
		
		messages_q = 'CREATE  TABLE "main"."messages" ("id" INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , "conversation_id" INTEGER NOT NULL, "timestamp" INTEGER NOT NULL, "status" INTEGER NOT NULL DEFAULT 0, "content" TEXT NOT NULL,"key" VARCHAR NOT NULL,"type" INTEGER NOT NULL DEFAULT 0,"media_id" INTEGER,"created" INTEGER NOT NULL DEFAULT CURRENT_TIMESTAMP)'
		
		conversations_q = 'CREATE TABLE "main"."conversations" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"contact_id" INTEGER NOT NULL, "created" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP)'
		
		self.c.execute(contacts_q);
		self.c.execute(messages_q);
		self.c.execute(conversations_q);
		self.conn.commit()

	def prepareGroupConversations(self):
		
		groupmessages_q = 'CREATE TABLE IF NOT EXISTS "main"."groupmessages" ("id" INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , "contact_id" INTEGER NOT NULL, "groupconversation_id" INTEGER NOT NULL,"timestamp" INTEGER NOT NULL, "status" INTEGER NOT NULL DEFAULT 0, "content" TEXT NOT NULL,"key" VARCHAR NOT NULL,"media_id" INTEGER, "type" INTEGER NOT NULL DEFAULT 0,"created" INTEGER NOT NULL DEFAULT CURRENT_TIMESTAMP)'
		
		groupconversations_q = 'CREATE TABLE IF NOT EXISTS "main"."groupconversations" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"jid" VARCHAR NOT NULL,contact_id INTEGER,"picture" VARCHAR,"subject" VARCHAR, "subject_owner" INTEGER,"subject_timestamp" INTEGER, "created" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,"new" INTEGER NOT NULL DEFAULT 0)'
		
		groupconversations_contacts_q = 'CREATE TABLE IF NOT EXISTS "main".groupconversations_contacts ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"groupconversation_id" INTEGER NOT NULL,"contact_id" INTEGER NOT NULL)'
		
		c = self.conn.cursor()
		c.execute(groupmessages_q);
		c.execute(groupconversations_q);
		c.execute(groupconversations_contacts_q);
		self.conn.commit()
	
	def prepareMedia(self):
		if not self.tableExists("mediatypes"):
			q = 'CREATE TABLE IF NOT EXISTS "main"."mediatypes" ("id" INTEGER PRIMARY KEY NOT NULL, "type" VARCHAR NOT NULL, "enabled" INTEGER NOT NULL DEFAULT 1)'
		
			
			c = self.conn.cursor()
			c.execute(q);
			self.conn.commit()
			

			c.execute("INSERT INTO mediatypes(id,type,enabled) VALUES (1,'text',1)")
			c.execute("INSERT INTO mediatypes(id,type,enabled) VALUES (2,'image',0)")
			c.execute("INSERT INTO mediatypes(id,type,enabled) VALUES (3,'video',0)")
			c.execute("INSERT INTO mediatypes(id,type,enabled) VALUES (4,'voice',0)")
			c.execute("INSERT INTO mediatypes(id,type,enabled) VALUES (5,'location',0)")
			c.execute("INSERT INTO mediatypes(id,type,enabled) VALUES (6,'vcf',0)")
			
			
			q = 'CREATE TABLE IF NOT EXISTS "main"."media" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "mediatype_id" INTEGER NOT NULL, "preview" VARCHAR,"remote_url" VARCHAR, "local_path" VARCHAR, transfer_status INTEGER NOT NULL DEFAULT 0)'
			
			c.execute(q)
			
			qgroup = 'CREATE TABLE IF NOT EXISTS "main"."groupmedia" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "mediatype_id" INTEGER NOT NULL,"preview" VARCHAR, "remote_url" VARCHAR, "local_path" VARCHAR, groupmessage_id INTEGER NOT NULL,transfer_status INTEGER NOT NULL DEFAULT 0)'
			
			#c.execute(qgroup)
			
			self.conn.commit()
		


	def prepareSettings(self):
	
		if not self.tableExists('settingtypes') or not self.tableExists('settings'):
			types = 'CREATE TABLE IF NOT EXISTS "main".settingtypes ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "label" VARCHAR NOT NULL,"description" VARCHAR,"order" INTEGER NOT NULL DEFAULT 999,"visible" INTEGER NOT NULL)'
		
			settings = 'CREATE TABLE IF NOT EXISTS "settings" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"settingtype_id" INTEGER NOT NULL,"label" VARCHAR NOT NULL, "description" VARCHAR, "selector" VARCHAR NOT NULL,"order" INTEGER NOT NULL DEFAULT 999,"visible" INTEGER NOT NULL DEFAULT 1, "value" VARCHAR)'
		
			selector_unique = "CREATE UNIQUE INDEX IF NOT EXISTS SettingSelector ON settings (selector)"
			
			c = self.conn.cursor()
			c.execute(types);
			c.execute(settings);
			c.execute(selector_unique);
			self.conn.commit()
			
			####Define Basic Settings####
			#group notifications
				#tone
				#vibra
			#message notifications
				#tone
				#vibra
			#Conversation settings
				#enter is send
				#conversation sounds
	
