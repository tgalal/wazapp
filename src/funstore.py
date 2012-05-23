class FunStore():
	
	def __init__(self):
		self.container = {}

	def clear(self):
		self.container = {}
	
	def get(self,paramKey):
		try:
			return self.container[paramKey.toString()];
		except KeyError:
			return None

	def put(self,paramKey,paramFMessage):
		self.container[paramKey.toString()] = paramFMessage;

	def elements(self):
		return self.container
	
	def remove(self,paramKey):
		self.container.pop(paramKey.toString());