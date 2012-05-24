#include "waregrequest.h"
#include <QDebug>
#include "utilities.h"
using namespace Utilities;

WARegRequest::WARegRequest(QString cc, QString number, QString method)
{

    this->addParam("cc",cc);
    this->addParam("in",number);
   // this->addParam("me",cc+number);
    this->addParam("udid",getChatPassword());
    this->addParam("method",method);

    connect(this,SIGNAL(trigger(QString)),this,SLOT(sendRequest(QString)));
    connect(this,SIGNAL(done(QString)),this,SLOT(onDone(QString)));
}

void WARegRequest::go(QString code)
{
    this->addParam("code",code);
    this->start();
}

void WARegRequest::onDone(QString data)
{
    QDomDocument document;
    document.setContent(data);

    QDomElement response= document.elementsByTagName("response").at(0).toElement();

    QString login = response.attribute("login");
    QString status = response.attribute("status");

    if(status == "ok")
        emit success(login);
    else
        emit fail("Unkown Reason");

   // qDebug() << data;
    qDebug()<<status<<" ::::: "<<login;

}
void WARegRequest::run(){}

void WARegRequest::launched()
{
    //emit success("201006960035");
    emit trigger("https://r.whatsapp.net/v1/register.php");
}
