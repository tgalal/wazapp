import dbus
import os
parentdir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.sys.path.insert(0,parentdir)
from InterfaceHandler import InterfaceHandlerBase, InvalidSignalException, InvalidMethodException
class DBusInterfaceHandler(InterfaceHandlerBase):
	
	def __init__(self, username):
		bus = dbus.Bus()
		busObj = bus.get_object('com.yowsup.methods', '/com/yowsup/methods')
		
		initMethod = busObj.get_dbus_method("init",'com.yowsup.methods')
		
		result = initMethod(username)
		
		if result:
			self.initSignals(result)
			self.initMethods(result)
		
	def initSignals(self, connId):
		bus = dbus.Bus()
		self.signalRegistrar = bus.get_object('com.yowsup.signals', '/com/yowsup/%s/signals'%connId)

		getter = self.signalRegistrar.get_dbus_method('getSignals', 'com.yowsup.signals')
		self.signals = getter()

	def initMethods(self, connId):
		#get methods
		bus = dbus.Bus()
		self.methodsProvider = bus.get_object('com.yowsup.methods', '/com/yowsup/%s/methods'%connId)
		getter = self.methodsProvider.get_dbus_method('getMethods', 'com.yowsup.methods')
		self.methods = getter()

	
	def connectToSignal(self, signalName, callback):
		if not self.isSignal(signalName):
			raise InvalidSignalException()

		self.signalRegistrar.connect_to_signal(signalName, callback)

	def call(self, methodName, params = ()):
		if not self.isMethod(methodName):
			raise InvalidMethodException()

		
		method = self.methodsProvider.get_dbus_method(methodName, 'com.yowsup.methods')
		return method(*params)
		
