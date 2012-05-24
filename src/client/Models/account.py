class Account():
	def __init__(self,cc,phoneNumber,username,status,pushName,imsi,password):
		
		self.pushName = pushName.encode('utf-8')
		self.cc = cc;
		self.phoneNumber = cc+phoneNumber;
		self.jid = username+"@s.whatsapp.net";
		self.username = username;
		self.password = password
		self.imsi = imsi
		self.status = status
		
		
		
		print "ACCOUNT INFO"
		print pushName
		print cc
		print phoneNumber
		print self.jid
		#print password
		print imsi
		print status
		print "END ACCNT INFO"
		
	def setAccountInstance(self,instance):
		self.accountInstance = instance
	
	def updateStatus(self,status):
		self.accountInstance.setValue("status",status);
		self.accountInstance.sync()
