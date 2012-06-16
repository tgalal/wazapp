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
	
	
