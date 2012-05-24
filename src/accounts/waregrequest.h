#ifndef WAREGREQUEST_H
#define WAREGREQUEST_H

#include "warequest.h"
#include <QDomDocument>

class WARegRequest : public WARequest
{
    Q_OBJECT
public:
    explicit WARegRequest(QString cc, QString number, QString method ="sms");
    
    void run();

signals:
    void success(QString);
    void fail(QString);

public slots:
    void launched();
    void onDone(QString);
    void go(QString);
};

#endif // WAREGREQUEST_H
