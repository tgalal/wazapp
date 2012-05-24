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
