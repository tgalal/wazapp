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

#include "utilities.h";
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

    AccountSetup::ProviderPluginProcess* plugin = new AccountSetup::ProviderPluginProcess;
    if ( plugin != AccountSetup::ProviderPluginProcess::instance() )
        qFatal("Instance not unique\n");

    viewer->parentWindowId = plugin->parentWindowId();


    viewer->rootContext()->setContextProperty("initType", plugin->setupType());

    viewer->debug("debug init");



   // QObject *rootObject = dynamic_cast<QObject*>(viewer.data()->rootObject());


  //  QObject::connect(viewer.data(),SIGNAL(statusUpdated(QVariant)),rootObject,SLOT(setLoadingState(QVariant)));

    switch(plugin->setupType()) {

        case AccountSetup::CreateNew:
            {
            viewer->init(1);
            plugin->setReturnToAccountsList(true);
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
            plugin->setReturnToAccountsList(true);
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


    viewer->setOrientation(QmlApplicationViewer::ScreenOrientationAuto);
    viewer->showExpanded();






    return app->exec();
}

