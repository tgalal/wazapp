#include "waexistsrequest.h"
#include <QDebug>

WAExistsRequest::WAExistsRequest(QString cc, QString number)
{
    this->addParam("cc",cc);
    this->addParam("in",number);
    this->addParam("udid","abcd");

    connect(this,SIGNAL(trigger(QString)),this,SLOT(sendRequest(QString)));
    connect(this,SIGNAL(done(QString)),this,SLOT(onDone(QString)));

}

void WAExistsRequest::runTests()
{
    qDebug() << this->encodeUrl(params);
}

void WAExistsRequest::onDone(QString data)
{
    QDomDocument document;
    document.setContent(data);

    QDomElement response= document.elementsByTagName("response").at(0).toElement();

    QString status = response.attribute("status");
    QString result = response.attribute("result");

    if(status == "success")
        emit exists();
    else
        emit notExists();

    qDebug()<<status<<" ::::: "<<result;

}

void WAExistsRequest::run(){}

void WAExistsRequest::launched()
{
    emit trigger("https://r.whatsapp.net/v1/exist.php");
}
