#-------------------------------------------------
#
# Project created by QtCreator 2012-12-23T07:06:43
#
#-------------------------------------------------

CONFIG += mobility console location
QT       += core gui

TARGET = _wazlibs
TEMPLATE = lib

QMAKE_PREFIX_SHLIB =

DEFINES += WAZLIBS_LIBRARY

SOURCES += waproviderpluginprocess.cpp \
            wazlibs_wrap.cxx

HEADERS += waproviderpluginprocess.h \
    wazlibs_global.h

INCLUDEPATH += /usr/include/python2.6

LIBS += -lpython2.6

CONFIG += link_pkgconfig
PKGCONFIG += accounts-qt \
            AccountSetup

QMAKE_CXXFLAGS += -fPIC

unix:!symbian {
    maemo5 {
        target.path = /opt/usr/lib
    } else {
        target.path = /usr/lib
    }
    INSTALLS += target
}
