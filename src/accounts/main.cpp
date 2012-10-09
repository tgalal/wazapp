/***************************************************************************
**
** Copyright (c) 2012, Tarek Galal <tarek@wazapp.im>
**
** This file is part of Wazapp, an IM application for Meego Harmattan
** platform that allows communication with Whatsapp users.
**
** Wazapp is free software: you can redistribute it and/or modify it under
** the terms of the GNU General Public License as published by the
** Free Software Foundation, either version 2 of the License, or
** (at your option) any later version.
**
** Wazapp is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
** See the GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with Wazapp. If not, see http://www.gnu.org/licenses/.
**
****************************************************************************/
#include <MLocale>
#include <QTranslator>
#include <QFile>
#include <QtGui/QApplication>
#include "qmlapplicationviewer.h"
#include <QDeclarativeContext>

#include "waaccount.h"
#include "wacoderequest.h"
#include "waexistsrequest.h"
#include <QDebug>

#include <fstream>

using namespace std;

ofstream logfile;

#include "utilities.h"

using namespace WA_UTILITIES::Utilities;

void SimpleLoggingHandler(QtMsgType type, const char *msg) {
    switch (type) {
        case QtDebugMsg:
            logfile << QTime::currentTime().toString().toAscii().data() << " Debug: " << msg << "\n";
            break;
        case QtCriticalMsg:
            logfile << QTime::currentTime().toString().toAscii().data() << " Critical: " << msg << "\n";
            break;
        case QtWarningMsg:
            logfile << QTime::currentTime().toString().toAscii().data() << " Warning: " << msg << "\n";
            break;
        case QtFatalMsg:
            logfile << QTime::currentTime().toString().toAscii().data() <<  " Fatal: " << msg << "\n";
            abort();
        }

    logfile.flush();
    }


bool accountExists(){

    Accounts::Manager *manager;
    manager = new Accounts::Manager();
    Accounts::AccountIdList accl = manager->accountList();
    Accounts::Account *a;
    Accounts::ServiceList ss;
    for(int i =0; i<accl.length(); i++)
    {

        a = manager->account(accl[i]);
        ss = a->services();

        for (int j=0; j<ss.length(); j++){

            if(ss[j]->name()=="waxmpp"){

                if(a->valueAsString("imsi") == Utilities::getImsi()){
                    return true;
                }
            }
         }
     }
    return false;
}

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QScopedPointer<QApplication> app(createApplication(argc, argv));
    QScopedPointer<QmlApplicationViewer> viewer(QmlApplicationViewer::create());
    logfile.open("/home/user/.wazapp/reglog", ios::app);
    qInstallMsgHandler(SimpleLoggingHandler);

    qDebug()<<"HELLO";

    MLocale myLocale;
    QString lang = myLocale.language();
    QTranslator translator;

    if (QFile::exists("/opt/waxmppplugin/qml/waxmppplugin/i18n/tr_"+ lang + ".qm"))
    {
        //qDebug() << "TRANSLATION:" << lang;
        translator.load("/opt/waxmppplugin/qml/waxmppplugin/i18n/tr_" + lang);
        app->installTranslator(&translator);
    }


    AccountSetup::ProviderPluginProcess* plugin = new AccountSetup::ProviderPluginProcess;
    if ( plugin != AccountSetup::ProviderPluginProcess::instance() )
        qFatal("Instance not unique\n");

    viewer->parentWindowId = plugin->parentWindowId();


    viewer->rootContext()->setContextProperty("initType", plugin->setupType());

    viewer->debug("debug init");



   // QObject *rootObject = dynamic_cast<QObject*>(viewer.data()->rootObject());


  //  QObject::connect(viewer.data(),SIGNAL(statusUpdated(QVariant)),rootObject,SLOT(setLoadingState(QVariant)));

    plugin->setReturnToAccountsList(true);

    switch(plugin->setupType()) {

        case AccountSetup::CreateNew:
            {
            viewer->init(1);
            viewer->rootContext()->setContextProperty("mccCode",Utilities::getMcc());
    }
            break;

        case AccountSetup::EditExisting:
            {

            viewer->account = plugin->account();
            QString userId = plugin->account()->valueAsString("username");
            viewer->rootContext()->setContextProperty("currPhoneNumber",userId);
            viewer->rootContext()->setContextProperty("currPushName",plugin->account()->valueAsString("pushName"));
            viewer->init(2);
    }
            break;

       default:{
            viewer->init(1);
            viewer->rootContext()->setContextProperty("mccCode",Utilities::getMcc());
             }


    }


    if(plugin->setupType() != AccountSetup::EditExisting && accountExists()){
         qDebug()<<"Z";
         viewer->setMainQmlFile(QLatin1String("/opt/waxmppplugin/qml/waxmppplugin/exists.qml"));
    }
    else
    {
           qDebug()<<"Y";
         viewer->setMainQmlFile(QLatin1String("/opt/waxmppplugin/qml/waxmppplugin/main.qml"));
      }


    viewer->setOrientation(QmlApplicationViewer::ScreenOrientationLockPortrait);
    viewer->showExpanded();






    return app->exec();
}

