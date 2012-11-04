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
#include "warequest.h"
#include <QDebug>

//const QString WARequest::userAgent = "WhatsApp/2.6.61 S60Version/5.2 Device/C7-00";
//const QString WARequest::userAgent = "WhatsApp/2.8.13 S60Version/5.3 Device/C7-00";
const QString WARequest::userAgent = "WhatsApp/2.8.2 WP7/7.10.8773.98 Device/NOKIA-Lumia_800-H112.1402.2.3";

WARequest::WARequest()
{
    manager = new QNetworkAccessManager(this);
    connect(manager,SIGNAL(finished(QNetworkReply*)),this,SLOT(replyFinished(QNetworkReply*)));
    qDebug()<<"CONNECTED SIGNAL";

    connect(this,SIGNAL(started()),this,SLOT(launched()));
}

//void WARequest::run(){}
QString WARequest::getBaseUrl(){return QString();}
QString WARequest::getReqFile(){return QString();}

void WARequest::addParam(QString name, QString value)
{
    //QMap<QString, QString> dict;

   // dict[name]=value;

    params << name << value;
}

void WARequest::runTests()
{

}

void WARequest::replyFinished(QNetworkReply *reply)
{
    QString answer = QString::fromUtf8(reply->readAll());
   // qDebug () << answer;



    emit done(answer);


}

QByteArray WARequest::encodeUrl(QList<QString> params)
{
    QString encoded;

    for(int i = 0; i<params.length(); i+=2)
    {
        if(i>0)
            encoded+="&";

        encoded+= params[i]+"="+params[i+1];
    }
    return encoded.toAscii();
    //return QUrl::toPercentEncoding(encoded);
}


//void WARequest::launched()

void WARequest::sslError(QList<QSslError> error)
{
    qDebug()<<"SSL ERROR";

    for (int i = 0; i<error.length(); i++)
    {
        qDebug()<<error[i].errorString();
    }
}

void WARequest::networkError(QNetworkReply::NetworkError)
{
    qDebug()<<"Network ERROR";
}

void WARequest::readyRead()
{

}

void WARequest::sendRequest(QString url)
{
    qDebug()<< "SENDING";

    QNetworkRequest request;
    request.setUrl(QUrl(url+"?"+encodeUrl(params)));

    request.setRawHeader("User-Agent", userAgent.toAscii());
    //request.setRawHeader("Content-Type","application/x-www-form-urlencoded");
    //request.setRawHeader("Accept","text/xml");

    //QNetworkReply *reply = manager->post(request,encodeUrl(params));
    QNetworkReply *reply = manager->get(request);
    reply->ignoreSslErrors();

    //connect(reply, SIGNAL(readyRead()), this, SLOT(readyRead()));
   connect(reply, SIGNAL(error(QNetworkReply::NetworkError)),
            this, SLOT(networkError(QNetworkReply::NetworkError)));
    connect(reply, SIGNAL(sslErrors(QList<QSslError>)),
            this, SLOT(sslError(QList<QSslError>)));



   // qDebug()<<encodeUrl(params);

   // manager->get(request);

    //manager->post(request,encodeUrl(params));
}
