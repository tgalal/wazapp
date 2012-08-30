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
import time,datetime,re
from dateutil import tz

class WATime():
	def parseIso(self,iso):
		d=datetime.datetime(*map(int, re.split('[^\d]', iso)[:-1]))
		return d
		
	def utcToLocal(self,dt):
		utc = tz.gettz('UTC');
		local = tz.tzlocal()
		dtUtc =  dt.replace(tzinfo=utc);
		
		return dtUtc.astimezone(local)
	
	def datetimeToTimestamp(self,dt):
		return time.mktime(dt.timetuple());
		

if __name__=="__main__":
	ds = "2012-06-16T15:24:36Z"
	watime = WATime();
	
	print ds
	
	parsed = watime.parseIso(ds)
	print parsed
	
	local = watime.utcToLocal(parsed)
	print local
	
	stamp = watime.datetimeToTimestamp(local)
	print stamp
	
	
