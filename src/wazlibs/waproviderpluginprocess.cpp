/*
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
*/
#include "waproviderpluginprocess.h"
#include <QDebug>
#include <fstream>
#include <QTime>

using namespace std;

WAProviderPluginProcess::WAProviderPluginProcess()
{
    qDebug() << "Created instance" << endl;

    AccountSetup::ProviderPluginProcess* plugin = new AccountSetup::ProviderPluginProcess;
    this->isUniqueInstance = plugin == AccountSetup::ProviderPluginProcess::instance();

    qDebug() << "unique or no?";
    qDebug() << this->isUniqueInstance;

    this->accountId = 0;

    switch(plugin->setupType()){

        case AccountSetup::CreateNew:

            //qDebug() << "in create new";
            this->initType = 1;

            break;

        case AccountSetup::EditExisting:
            qDebug() << "in edit existing";
            this->initType = 2;
            this->accountId = plugin->account()->id();
            this->account = plugin->account();

            break;

       default:

           qDebug() << "in default";
           this->initType = 1;
           break;
    }

      qDebug() << "Setup type: "<< this->initType;
}


std::string WAProviderPluginProcess::accountValueAsString(string name){

    return this->account->valueAsString(QString::fromStdString(name)).toStdString();

}
