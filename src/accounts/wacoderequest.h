#ifndef WACODEREQUEST_H
#define WACODEREQUEST_H

#include "warequest.h"
#include <QDomDocument>

class WACodeRequest : public WARequest
{
   Q_OBJECT
public:
    WACodeRequest(QString cc, QString in, QString method = "sms");

    void run();
    void runTests();

signals:
    void success();
    void fail(QString);

public slots:
    void launched();
    void onDone(QString);

};

#endif // WACODEREQUEST_H
