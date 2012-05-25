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
#ifndef WAREQUEST_H
#define WAREQUEST_H

#include <QThread>
#include <QMap>
#include <QList>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QByteArray>
#include <QSslError>


class WARequest : public QThread
{
    Q_OBJECT
public:
    explicit WARequest();

    QList<QString> params;


    void runTests();

    static const QString userAgent;

    QByteArray encodeUrl(QList<QString> params);


    void addParam(QString name,QString value);

    //virtual void run();
    virtual QString getBaseUrl();
    virtual QString getReqFile();

private:
    QNetworkAccessManager *manager;

signals:
    void done(QString);
    void trigger(QString);

    
public slots:
    void replyFinished(QNetworkReply*);
    void networkError(QNetworkReply::NetworkError);
    void sslError(QList<QSslError>);
    void readyRead();
    void sendRequest(QString url);
    virtual void launched()=0;
    virtual void onDone(QString)=0;

    
};

#endif // WAREQUEST_H
