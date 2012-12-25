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

from PySide.QtDeclarative import QDeclarativeView,QDeclarativeProperty
from PySide import QtCore
from wadebug import WADebug
from PySide.QtCore import QUrl
from accountsmanager import AccountsManager
from utilities import Utilities
from Yowsup.Registration.v2.coderequest import WACodeRequest
from Yowsup.Registration.v2.regrequest import WARegRequest
from Yowsup.Registration.v2.existsrequest import WAExistsRequest
from Yowsup.Common.utilities import Utilities as YowsupUtils
from Yowsup.Common.debugger import Debugger as YowsupDebugger
import threading, time
from constants import WAConstants
import datetime
#from smshandler import SMSHandler

class RegistrationUI(QDeclarativeView):

    statusUpdated = QtCore.Signal(str); #status 
    registrationFailed = QtCore.Signal(str); #reason
    registrationSuccess = QtCore.Signal(str); #phoneNumber
    verificationSuccess = QtCore.Signal()
    verificationFailed = QtCore.Signal(str)
    codeRequestCancelled = QtCore.Signal();
    voiceRequestCancelled = QtCore.Signal();
    voiceCodeRequested = QtCore.Signal();

    gotAccountData = QtCore.Signal(dict) # internally used signal to create the new account in main thread

    def __init__(self, accountId = 0):
        super(RegistrationUI, self).__init__()
        WADebug.attach(self)
        
        YowsupDebugger.enabled = True
        self.deviceIMEI = Utilities.getImei()
        self.account = None #waccount
        self.accountInstance = None #real account
        self.smsHandler = None
        self.number = ""
        self.cc = ""
        
        self.gotAccountData.connect(self.createOrUpdateAccount)
        #AccountsManager.manager.accountCreated.connect(self.onAccountCreated)
        
        if accountId:
            account = AccountsManager.getAccountById(accountId)
            if account:
                self.account = account
                self.cc = account.cc
                self.number = account.phoneNumber
                self.accountInstance = account.accountInstance
                self.setupEditMode()
            else:
                raise Exception("Got account Id but couldn't find account")
        else:
            
            #this is a new account request
            #check existence of an old one 
            account = AccountsManager.findAccount()
            if account:
                self.account = account
                self.cc = account.cc
                self.number = account.phoneNumber
                self.accountInstance = account.accountInstance
                self.setupEditMode()
            else:
                self.setupNewMode()

        src = QUrl('/opt/waxmppplugin/bin/wazapp/UI/Registration/regmain.qml')
        self.setSource(src)

        self.registrationFailed.connect(self.rootObject().onRegistrationFailed)
        self.registrationSuccess.connect(self.rootObject().onRegistrationSuccess)
        self.voiceCodeRequested.connect(self.rootObject().onVoiceCodeRequested)
        self.statusUpdated.connect(self.rootObject().onStatusUpdated)
        self.verificationSuccess.connect(self.rootObject().onVerifySuccess)
        self.verificationFailed.connect(self.rootObject().onVerifyFailed)

        self.rootObject().savePushName.connect(self.savePushname)
        self.rootObject().abraKadabra.connect(self.abraKadabra)
        self.rootObject().codeRequest.connect(self.codeRequest)
        #self.rootObject().stopCodeRequest.connect(self.stopCodeRequest)
        self.rootObject().registerRequest.connect(self.registerRequest)
        self.rootObject().deleteAccount.connect(self.deleteAccount)
        self.rootObject().verifyAccount.connect(self.existsRequest)
        
    def setupEditMode(self):
        
        if self.account is None:
            raise Exception("Requested edit mode with account not set")

        self.rootContext().setContextProperty("initType", 2);
        self.rootContext().setContextProperty("username", self.account.username);
        self.rootContext().setContextProperty("currPhoneNumber", self.account.username);
        self.rootContext().setContextProperty("currPushName", self.account.pushName);

        self.rootContext().setContextProperty("accountKind", self.account.kind);
        
        if self.account.expiration is not None:
            formatted = datetime.datetime.fromtimestamp(self.account.expiration).strftime(WAConstants.DATE_FORMAT)
            self.rootContext().setContextProperty("accountExpiration", formatted);


    def setupNewMode(self):
        self.rootContext().setContextProperty("initType", 1);
        self.rootContext().setContextProperty("mcc", Utilities.getMcc());
        
        #self.smsHandler = SMSHandler()
        #self.smsHandlerThread = QThread()
        #self.smsHandler.moveToThread(self.smsHandlerThread)
        #self.smsHandlerThread.started.connect(self.smsHandler.initManager)
        #self.smsHandlerThread.start()

    def savePushname(self, pushName):
        self.account.accountInstance.setValue("pushName", pushName)
        self.account.accountInstance.sync()

    def abraKadabra(self):
        self._d("ABRA KADABRA!")
        self.registerRequest("919177")
    
    def async(fn):
        def wrapped(self, *args):
            threading.Thread(target = fn, args = (self,) + args).start()

        return wrapped

    @async
    def codeRequest(self, cc, number, reqType):
        
        self.number = number
        self.cc = cc

        if reqType in ("sms", "voice"):
            result = WACodeRequest(cc, number, YowsupUtils.processIdentity(self.deviceIMEI), reqType).send()

            if reqType == "sms":
                self.statusUpdated.emit("reg_a")
            
            if "status" in result:
            
                self._d(result["status"])
                
                if result["status"] == "sent":
                    if reqType == "voice":
                        self.voiceCodeRequested.emit()
                    else:
                        self.statusUpdated.emit("reg_b");
                elif result["status"] == "ok":
                    self.gotAccountData.emit(result)
                else:
                    reason = result["status"]
                    if result["reason"] is not None:
                        reason = reason + " reason: %s" % result["reason"]

                    if result["retry_after"] is not None:
                        reason = reason + " retry after %s" % result["retry_after"]

                    if result["param"] is not None:
                        reason = reason + ": %s" % result["param"]

                    self.registrationFailed.emit(reason)  
            else:
                self.registrationFailed.emit("Err: No status received")

    @async
    def registerRequest(self, code):
        code = "".join(code.split('-')) #remove hyphen
        self._d("should register with code %s" % code)
        result = WARegRequest(self.cc, self.number, code, YowsupUtils.processIdentity(self.deviceIMEI)).send()
        
        if "status" in result and result["status"] is not None:
            if result["status"] == "ok":
                self.gotAccountData.emit(result)
            else:
                errMessage = "Failed!"
                if result["reason"] is not None:
                    errMessage = errMessage + " Server said '%s'." % result["reason"]
                
                if result["retry_after"] is not None:
                    errMessage = errMessage + " Retry after: %s" % result["retry_after"]
                    
                self.registrationFailed.emit(errMessage)
        else:
            self.registrationFailed.emit("Err: No status received")
    
    
    @async
    def existsRequest(self):
        result = WAExistsRequest(self.cc, self.number, YowsupUtils.processIdentity(self.deviceIMEI)).send()

        if "status" in result and result["status"] is not None:
            if result["status"] == "ok":
                self.gotAccountData.emit(result)
            else:
                self.verificationFailed.emit("")
        else:
            self.verificationFailed.emit("Err: No status received. Try again.")
      
    
    def createOrUpdateAccount(self, data):

        if self.accountInstance is None:
            self.accountInstance = AccountsManager.manager.createAccount("waxmpp")
            self.accountInstance.sync()
            self.setAccountData(self.accountInstance.id(), data,  True)
        else:
            self.setAccountData(self.accountInstance.id(), data,  False)

    def setAccountData(self, accountId, data, isNew):
            result = data
            account = self.accountInstance

            account.setValue("username", result["login"]);
            account.setValue("jid", result["login"]+"@s.whatsapp.net");
            account.setValue("password", result["pw"]);
            account.setValue("penc", "b64")
            account.setValue("kind", result["kind"])
            account.setValue("expiration", result["expiration"])
            account.setValue("cost", result["cost"])
            account.setValue("price", result["price"])
            account.setValue("price_expiration", result["price_expiration"])
            account.setValue("currency", result["currency"])
            account.setValue("wazapp_lastUpdated", int(time.time()))
            account.setValue("wazapp_version", Utilities.waversion)
            account.setEnabled(True);

            if isNew:
                account.setValue("name", self.cc + self.number);
                account.setValue("status", WAConstants.INITIAL_USER_STATUS);
                account.setValue("imsi", Utilities.getImsi());
                account.setValue("cc", self.cc);
                account.setValue("phoneNumber", self.number);
                account.setValue("pushName", self.cc + self.number);
                account.sync();
                self.registrationSuccess.emit(result["login"])
            else:
                account.sync();
                self.verificationSuccess.emit()

            self.rootContext().setContextProperty("accountKind", result["kind"]);

            if result["expiration"]:
                formatted = datetime.datetime.fromtimestamp(int(result["expiration"])).strftime(WAConstants.DATE_FORMAT)
                self.rootContext().setContextProperty("accountExpiration", formatted);

    def deleteAccount(self):
        self.accountInstance.remove()
        self.accountInstance.sync()
        self.engine().quit.emit()