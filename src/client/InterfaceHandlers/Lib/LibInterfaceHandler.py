import os
parentdir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.sys.path.insert(0,parentdir)
from InterfaceHandler import InterfaceHandlerBase, InvalidSignalException, InvalidMethodException

import sys
#sys.path.append("/home/tarek/Projects/")
#sys.path.append("/home/tarek/Projects/yowsup")

#sys.path.append("/home/developer/")
#sys.path.append("/home/developer/yowsup")

from Yowsup.connectionmanager import YowsupConnectionManager

class LibInterfaceHandler(InterfaceHandlerBase):
	
	def __init__(self, username):
		self.connectionManager = YowsupConnectionManager()
		
		self.signalInterface = self.connectionManager.getSignalsInterface()
		self.methodInterface = self.connectionManager.getMethodsInterface()
		
		super(LibInterfaceHandler,self).__init__();
		
		self.initSignals()
		self.initMethods()

	def initSignals(self):		
		self.signals = self.signalInterface.getSignals()


	def initMethods(self):
		#get methods
		self.methods = self.methodInterface.getMethods()
	
	def connectToSignal(self, signalName, callback):
		if not self.isSignal(signalName):
			raise InvalidSignalException()
		
		self.signalInterface.registerListener(signalName, callback)

	def call(self, methodName, params = ()):
		if not self.isMethod(methodName):
			raise InvalidMethodException()

		return self.methodInterface.call(methodName, params)
		
