from model import Model;

class Contact(Model):
	def __init__(self):
		self.name = "";
		self.picture = "none";
		self.alphabet = "";
	
	def setRealTimeData(self,name,picture):
		self.name = name;
		self.picture = picture;
		self.alphabet = name[0];
		
		self.modelData.append("name");
		self.modelData.append("picture");
		self.modelData.append("alphabet");
		
	
