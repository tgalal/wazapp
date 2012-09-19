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
#include "wacoderequest.h"
#include "QDebug"
#include "utilities.h"
#include <QCryptographicHash>

using namespace WA_UTILITIES::Utilities;



WACodeRequest::WACodeRequest(QString cc, QString in, QString method)
{
    QString mytoken = "k7Iy3bWARdNeSL8gYgY6WveX12A1g4uTNXrRzt1H";
    mytoken.append("c0d4db538579a3016902bf699c16d490acf91ff4");
    mytoken.append(in);

    QCryptographicHash md(QCryptographicHash::Md5);
    QByteArray ba = mytoken.toUtf8();
    md.addData(ba);
    QString token = QString(md.result().toHex().constData());

    this->addParam("cc",cc);
    this->addParam("in",in);
    //this->addParam("to",cc+in);
    this->addParam("lc","US");
    this->addParam("lg","en");
    this->addParam("mcc",Utilities::getMcc());
    this->addParam("mnc",Utilities::getMnc());
    this->addParam("imsi",Utilities::getImsi());
    this->addParam("method",method);
    this->addParam("token",token);


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
    else if (status == "success-attached")
        emit success(result);
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
