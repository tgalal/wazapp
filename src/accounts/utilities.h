#include <QSystemDeviceInfo>
#include <QSystemNetworkInfo>
#include <QCryptographicHash>
#include <stdio.h>


QTM_USE_NAMESPACE


#ifndef WA_UTILITIES
#define WA_UTILITIES
using namespace std;

namespace Utilities{
    extern QSystemNetworkInfo ninfo;
    extern QSystemDeviceInfo dinfo;

    extern QString getImsi();
    extern QString getImei();
    extern QString getCountryCode();
    extern QString getMcc();
    extern QString getMnc();
    extern QString reverseString(QString str);

    extern QString getChatPassword();

}
#endif

