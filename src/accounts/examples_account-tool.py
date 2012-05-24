 #
 # This file is part of the Python bindings for Accounts-Qt library, and
 # it is based in the C++ version of the same file from Accounts-Qt source.
 #
 # Copyright (C) 2009-2011 Nokia Corporation.
 #
 # Contact: PySide team <contact@pyside.org>
 #
 # This library is free software; you can redistribute it and/or
 # modify it under the terms of the GNU Lesser General Public License
 # version 2.1 as published by the Free Software Foundation.
 #
 # This library is distributed in the hope that it will be useful, but
 # WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 # Lesser General Public License for more details.
 #
 # You should have received a copy of the GNU Lesser General Public
 # License along with this library; if not, write to the Free Software
 # Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
 # 02110-1301 USA
 #


from optparse import OptionParser, OptionGroup
import sys
from PySide.QtCore import QCoreApplication
from Accounts import *

def main():
    app = QCoreApplication([])
    
    usage = """
    %prog [-t type] [options] """

    cmd = ""
    param = ""
    accountType = ""

    parser = OptionParser(usage)

    parser.add_option("-l", action="store_true", dest="listaccounts", help="list accounts")
    parser.add_option("-L", action="store_true", dest="listaccountnames", help="list account names")
    parser.add_option("-k", action="store", dest="listkeys", help="list keys for account # specified as parameter")
    parser.add_option("-t", action="store", dest="listaccountstype", help="list accounts with type 'type'")

    (opts, args) = parser.parse_args()

    accountMgr = Manager()
    acclist = accountMgr.accountList(accountType)

    if opts.listaccounts:
        print "list accounts:"
        for acc in acclist:
            print acc

    if opts.listaccountnames:
        print "list account names:"
        for acc in acclist:
            print "Account: " + str(acc)
            account = accountMgr.account(acc)
            if account:
                print account.displayName()

    if opts.listkeys:
        param = opts.listkeys
        print "list keys:"
        for acc in acclist:
            if param == "" or int(param) == acc:
                print "Account: " + str(acc)
                account = accountMgr.account(acc)
                if account:
                    print "Display name: " + account.displayName()
                    print "CredentialsId: " + str(account.credentialsId())
                    print "Provider: " + account.providerName()
                    keylist = account.allKeys()
                    for key in keylist:
                        print "key " + key + " = " + account.valueAsString(key)

if __name__ == "__main__":
    main()
