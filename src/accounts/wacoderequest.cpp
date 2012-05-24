#include "wacoderequest.h"
#include "QDebug"
#include "utilities.h";

using namespace WA_UTILITIES::Utilities;



WACodeRequest::WACodeRequest(QString cc, QString in, QString method)
{
    this->addParam("cc",cc);
    this->addParam("in",in);
    this->addParam("to",cc+in);
    this->addParam("lc","US");
    this->addParam("lg","en");
    this->addParam("mcc",Utilities::getMcc());
    this->addParam("mnc",Utilities::getMnc());
    this->addParam("imsi",Utilities::getImsi());
    this->addParam("method",method);


    connect(this,SIGNAL(trigger(QString)),this,SLOT(sendRequest(QString)));
    connect(this,SIGNAL(done(QString)),this,SLOT(onDone(QString)));

}

void WACodeRequest::runTests()
{
    qDebug() << this->encodeUrl(params);
}

void WACodeRequest::onDone(QString data)
{
    QDomDocument document;
    document.setContent(data);

    QDomElement response= document.elementsByTagName("response").at(0).toElement();

    QString status = response.attribute("status");
    QString result = response.attribute("result");

    if(status == "success-sent")
        emit success();
    else
        emit fail(status +"::"+result);

    qDebug()<<status<<" ::::: "<<result;

}

void WACodeRequest::run(){}

void WACodeRequest::launched()
{
    emit trigger("https://r.whatsapp.net/v1/code.php");
    //emit success();
}
