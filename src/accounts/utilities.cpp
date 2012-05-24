/***************************************************************************
**
** Copyright (c) 2012, Tarek Galal <tarek@wazapp.im>
**
** This file is part of Wazapp, an IM application for Meego Harmattan
** platform that allows communication with Whatsapp users.
**
** Wazapp is free software: you can redistribute it and/or modify it under
** the terms of the GNU General Public License as published by the
** Free Software Foundation, either version 3 of the License, or
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
#include "utilities.h";
namespace Utilities{
    QSystemNetworkInfo ninfo;
    QSystemDeviceInfo dinfo;

    QString getImsi(){return dinfo.imsi();}
    QString getImei(){return dinfo.imei();}
    QString getCountryCode(){return ninfo.homeMobileCountryCode();}
    QString getMcc(){return ninfo.currentMobileCountryCode();}
    QString getMnc(){
        QString mnc = ninfo.currentMobileNetworkCode();

        while(mnc.length() < 3){
            mnc = "0"+mnc;
        }
        return mnc;

    }



    QString reverseString(QString str)
    {
        QString res ="";
        for(int i = str.length()-1; i>=0; i--){
            res = res+str.at(i);
        }

        return res;


      char *p = str.toAscii().data();
      char *q = p;

      while(q && *q) ++q;
      for(--q; p < q; ++p, --q)
        *p = *p ^ *q,
        *q = *p ^ *q,
        *p = *p ^ *q;

      str = QString(p);

      return str;
    }



    std::string itoa(int value, unsigned int base) {

        const char digitMap[] = "0123456789abcdef";

        std::string buf;
        // Guard:
        if (base == 0 || base > 16) {

            // Error: may add more trace/log output here
            return buf;
        }
        // Take care of negative int:
        std::string sign;
        int _value = value;
        // Check for case when input is zero:
        if (_value == 0) return "0";
        if (value < 0) {
            _value = -value;
            sign = "-";
        }

        // Translating number to string with base:

        for (int i = 30; _value && i ; --i) {

            buf = digitMap[ _value % base ] + buf;

            _value /= base;

        }

        return sign.append(buf);

    }



    QString getChatPassword(){


        QString imei = getImei();
        QString buffer_str = reverseString(imei);

        qDebug()<<buffer_str;

        QCryptographicHash digest(QCryptographicHash::Md5);
        digest.reset();
        digest.addData(buffer_str.toAscii());


        QByteArray bytes = digest.result();


        buffer_str = "";

        for(int i =0; i<bytes.length(); i++){
            int tmp = bytes.at(i)+128;
            int c = (tmp >> 8) & 0xff;
            int f = tmp & 0xff;

            buffer_str=buffer_str + QString::fromStdString(itoa(f,16));

        }


        return buffer_str;

    }

}

