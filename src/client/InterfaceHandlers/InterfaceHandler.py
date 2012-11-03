class InterfaceHandlerBase(object):
	def __init__(self):
		self.signals = []
		self.methods = []

	def connectToSignal(self, signalName, callback):
		pass

	def call(self, methodName, params = ()):
		pass

	def initSignals(self):
		pass

	def initMethods(self):
		pass

	def isSignal(self, signalName):
		try:
			self.signals.index(signalName)
			return True
		except:
			return False


	def isMethod(self, methodName):
		try:
			self.methods.index(methodName)
			return True
		except:
			return False


class InvalidSignalException(Exception):
	pass

class InvalidMethodException(Exception):
	pass
