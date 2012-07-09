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
import sqlite3
import copy
import time

from wadebug import SqlDebug

class Model(object):

	def setConnection(self,connection):
		_d = SqlDebug();
		self._d = _d.d;
		
		self.table = self.getTableName();
		self.conn = connection
		try:
			self.cursor  = connection.cursor()
		except sqlite3.ProgrammingError as e:
			self._d(e)
			self.store.connect()
			self.conn = self.store.conn
			self.cursor = self.conn.cursor()
			
		#Get table description
		q = "PRAGMA table_info('%s')" % self.table
		res = self.runQuery(q)
		self.columns = [];
		self.modelData = [];
		self.hasManytoMany=[];
		
		for item in res:
			relattrib = str(item[1]).split('_id')
			if len(relattrib) == 2 and relattrib[1]=='':
				
				m2mTest = relattrib[0].split('_')
				if len(m2mTest) == 2:
					foreignOne = m2mTest[0].lower()
					foreignOne = foreignOne[0].upper()+foreignOne[1:]
					foreignTwo = m2mTest[1].lower()
					foreignTwo = foreignTwo[0].upper()+foreignTwo[1:]
					foreign = foreignOne + foreignTwo
					
					#foreignInstance = getattr(self.store,foreignOne)
					#self.setInstanceVariable(foreignOne,foreignInstance.create());
					
					#foreignInstance = getattr(self.store,foreignTwo)
					#self.setInstanceVariable(foreignTwo,foreignInstance.create());
				else:	
					foreign = relattrib[0].lower();
					foreign = foreign[0].upper()+foreign[1:]
				
				foreignInstance = getattr(self.store,foreign)
				self.setInstanceVariable(foreign,foreignInstance.create());
				
			self.setInstanceVariable(str(item[1]));
			self.columns.append(str(item[1]));
			self.modelData.append(str(item[1]));
			
	
			
	def getTableName(self):
		if vars(self).has_key("table"):
			return self.table

		table = self.whoami().lower()
		if table[-2:] == "ia":
			return table
		else:
			return table + "s"
		
		
		
	def storeConnected(self):
		''''''
	
	
	def setStore(self,store):
		self.store = store;
		self.setConnection(store.conn);
		self.storeConnected()

	def save(self):
		if self.id:
			self.update();
		else:
			self.insert();
	
	def _getColumnsWithValues(self):
		data = {};
		for c in self.columns:
			data[c] = vars(self)[c];
		
		return data;
		
		
	def getModelData(self):
		data = {};
		for c in self.modelData:
			data[c] = vars(self)[c];
		
		return data;
				
	def getData(self):
		data = self._getColumnsWithValues();	
		
		if vars(self).has_key('name'):
			data['name'] = vars(self)['name'];
		
		return data;	
	
		
	def read(self,idx):
		self = self.create();
		self.setData(self.getById(idx).getData());
		return self
	
	
	def deleteAll(self):
		q = "DELETE FROM %s "%self.table
		
		c = self.conn.cursor();
		c.execute(q)
		self.conn.commit()
		
	
	def delete(self,conds = None):
		
		q = "DELETE FROM %s "%self.table
			
		if conds is not None:
			q+="WHERE %s"%self.buildConds(conds);
		elif self.id:
			q+="WHERE id=%d"%self.id
		else:
			self._d("USE deleteAll to delete all, cancelled!")
			
		c = self.conn.cursor();
		c.execute(q)
		self.conn.commit()
		

	
	def insert(self):
		data = self._getColumnsWithValues();
		
		fields = [];
		values = [];

		for k,v in data.items():
			if k == "id":
				continue;
			if v is None:
				continue
				
			fields.append(k);
			values.append(v);
		
		wq = ['?' for i in values]
		wq = ','.join(wq);
		wq = "("+wq+")";
		fields = ','.join(fields)
		fields = "("+fields+")";
		
		q = "INSERT INTO %s %s VALUES %s" %(self.table,fields,wq);
		c = self.conn.cursor();
		self._d(q)
		self._d(values)
		c.execute(q,values);
		self.conn.commit();
		
		self.id = c.lastrowid;
	
	def update(self):
		data = self._getColumnsWithValues();
		
		updateData = [];
		updateValues = ()
		for k,v in data.items():
			if k == "id":
				continue;
			updateData.append("%s=?"%(k));
			updateValues+=(v,)
		
		q = "UPDATE %s SET %s WHERE id = %d"%(self.table,','.join(updateData),self.id);
		
		try:
			c  = self.conn.cursor()
		except sqlite3.ProgrammingError as e:
			self.reconnect();
		
		c = self.conn.cursor();
		
		self._d(q);
		self._d(updateValues);
		
		try:
			c.execute(q,updateValues);
			self.conn.commit();
		except:
			'''nothing'''
	
	
	def reconnect(self):
		self.store.connect()
		self.conn = self.store.conn
		self.cursor = self.conn.cursor()	
		
	def getById(self,idx):
		q = "SELECT * FROM %s WHERE id=?" %(self.table);
		c= self.conn.cursor();
		c.execute(q,[idx]);
		return self.createInstance(c.fetchone());
		
	
	
	def createInstance(self,resultItem):
		#modelInstance = copy.deepcopy(self);
		modelInstance = self.create();
		
		
		for i in range(0,len(resultItem)):
			modelInstance.setInstanceVariable(self.columns[i],resultItem[i]);
		
			
		return modelInstance;
	
	def fetchAll(self):
		q = "SELECT * FROM %s" % (self.table);
		c = self.conn.cursor();
		c.execute(q)
		data = []
		for item in c.fetchall():
			data.append(self.createInstance(item));
		
		return data
			
	
	
	def create(self):
		c = self.__class__
		instance =  c();
		instance.setStore(self.store);
		return instance;
	
	def setData(self,data):
		for k,v in data.items():
			try:
				self.columns.index(k)
				self.setInstanceVariable(k,v)
			except ValueError:
				continue
	
	def setInstanceVariable(self,variable,value=None):
		#variable = "idx" if variable == "id" else variable
		if ((variable == "timestamp" or variable == "created") and value is None):
			value =	int(time.time()*1000);
			
		vars(self)[variable] = value
	
	def findFirst(self,conditions,fields = []):
		res = self.findAll(conditions,fields);
		
		if len (res):
			return res[0];
		
		return None;
	
	
	def getComparator(self,key):
		signs = ['<','>','<=','>=','<>','=']
		signs.sort()
		key = key.strip()
		
		for s in signs:
			try:
				index = key.index(s)
				return s
			except:
				continue
		
		return False
			
	def buildConds(self,conditions):
		q = [];
		for k,v in conditions.items():
			comparator = self.getComparator(k)
			
			if comparator:
				index = k.index(comparator)
				k = k[:index]
			else:
				comparator = '='
				
			if type(v) == list:
			
				tmp = []
				for val in v:
					tmp.append("%s %s '%s'" % (k, comparator, str(val)))
				
				tmpStr = ' OR '.join(tmp)
			
				q.append("(%s)"%(tmpStr))
			else:
				q.append("%s %s '%s'" % (k, comparator, str(v)))
	
		condsStr = " AND ".join(q);
		
		return condsStr;
		
	def findCount(self,conditions=""):
		condsStr = "";
		if type(conditions) == dict:
			condsStr = self.buildConds(conditions);
			
		elif type(conditions) == str:
			condsStr = conditions
		else:
			raise "UNKNOWN COND TYPE "+ type(conditions)
			
		
		query = "SELECT COUNT(*) FROM %s " % (self.table)
		
		if len (condsStr):
			query = query +"WHERE %s" % condsStr;
		
		results = self.runQuery(query);
		
		return results[0][0];
		
	
	def findAll(self, conditions="", fields=[], order=[], first=None, limit=None):

		condsStr = "";
		if type(conditions) == dict:
			condsStr = self.buildConds(conditions);
			
		elif type(conditions) == str:
			condsStr = conditions
		else:
			raise "UNKNOWN COND TYPE "+ type(conditions)
			
		
		
		fieldsStr= "*"
		if len(fields):
			fieldsStr = ",".join(fields)
				
		query = "SELECT %s FROM %s " % (fieldsStr,self.table)
		
		if len (condsStr):
			query = query +"WHERE %s" % condsStr;
			
			
		if len(order):
			query = query+" ORDER BY ";
			orderStr = ",".join(order);
			query = query + orderStr;
		

		if limit is not None and type(limit) == int:
			query=query+" LIMIT %i"%limit


		if first is not None and type(first) == int:
			query=query+" OFFSET %i"%first
		

		results = self.runQuery(query);
		
		data = []
		for r in results:
			data.append(self.createInstance(r));
		return data
		
	def whoami(self):
		return self.__class__.__name__
	
	def runQuery(self,query,whereValues = []):
		self._d(query);
		c = self.conn.cursor();
		
		if len(whereValues):
			c.execute(query,whereValues)
		else:
			c.execute(query)
		
		return c.fetchall()
	
