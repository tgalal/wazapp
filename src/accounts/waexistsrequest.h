#ifndef WAEXISTSREQUEST_H
#define WAEXISTSREQUEST_H

#include "warequest.h"
#include <QDomDocument>

class WAExistsRequest : public WARequest
{
    Q_OBJECT
public:
    WAExistsRequest(QString cc, QString number);

    void run();
    void runTests();

signals:
    void exists();
    void notExists();

public slots:
    void launched();
    void onDone(QString);
};

#endif // WAEXISTSREQUEST_H
