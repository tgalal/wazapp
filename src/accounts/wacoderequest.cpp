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
#include "utilities.h";

using namespace WA_UTILITIES::Utilities;



WACodeRequest::WACodeRequest(QString cc, QString in, QString method)
{
    this->addParam("dot","1");
    this->addParam("cc",cc);
    this->addParam("in",in);
    //this->addParam("to",cc+in);
    this->addParam("lg","zz");
    this->addParam("lc","ZZ");
    this->addParam("mcc",Utilities::getMcc());
    this->addParam("mnc",Utilities::getMnc());
    this->addParam("method",method);
    this->addParam("imsi", Utilities::getImsi());

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
