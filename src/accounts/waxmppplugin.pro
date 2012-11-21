TEMPLATE = app

# Add more folders to ship with the application, here
folder_01.source = qml/waxmppplugin
folder_01.target = qml
#folder_02.source = wazapp

DEPLOYMENTFOLDERS = folder_01
                    #folder_02

# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH =

symbian:TARGET.UID3 = 0xE693757C

# Smart Installer package's UID
# This UID is from the protected range and therefore the package will
# fail to install if self-signed. By default qmake uses the unprotected
# range value if unprotected UID is defined for the application and
# 0x2002CCCF value if protected UID is given to the application
#symbian:DEPLOYMENT.installer_header = 0x2002CCCF

# Allow network access on Symbian
symbian:TARGET.CAPABILITY += NetworkServices

# If your application uses the Qt Mobility libraries, uncomment the following
# lines and add the respective components to the MOBILITY variable.
 CONFIG += mobility console location
 MOBILITY += systeminfo messaging

# Speed up launching on MeeGo/Harmattan when using applauncherd daemon
# CONFIG += qdeclarative-boostable

# Add dependency to Symbian components
# CONFIG += qt-components

QT += declarative dbus core network
CONFIG += meegotouch link_pkgconfig

PKGCONFIG += qdeclarative-boostable \
             accounts-qt \
             AccountSetup

# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += main.cpp \
    waaccount.cpp \
    warequest.cpp \
    wacoderequest.cpp \
    waexistsrequest.cpp \
    utilities.cpp \
    smshandler.cpp \
    waregrequest.cpp

# Please do not modify the following two lines. Required for deployment.
include(qmlapplicationviewer/qmlapplicationviewer.pri)
qtcAddDeployment()

target.path = /opt/waxmppplugin/bin
INSTALLS += target

CONFIG += qdeclarative-boostable

invoker.files = invoker/*
invoker.path = /opt/waxmppplugin/bin

wazappy.files = ../client/*

wazappy.path = /opt/waxmppplugin/bin/wazapp

INSTALLS += invoker \
            wazappy


accountsprovider.files = *.provider
accountsprovider.path = /usr/share/accounts/providers

INSTALLS += accountsprovider

accountsservice.files = *.service
accountsservice.path = /usr/share/accounts/services

INSTALLS += accountsservice

accountsicon.files = icon-m-service-wazapp.png
accountsicon.path =  /usr/share/themes/base/meegotouch/icons

INSTALLS += accountsicon


accountsiconx.files = icon-m-service-wazapp.png
accountsiconx.path =  /usr/share/themes/blanco/meegotouch/icons

INSTALLS += accountsiconx

powervr.files = python.ini
powervr.path =  /etc/powervr.d

INSTALLS += powervr

translation.files = qml/waxmppplugin/i18n/en.qm \
                    qml/waxmppplugin/i18n/ar.qm \
                    qml/waxmppplugin/i18n/bg.qm \
                    qml/waxmppplugin/i18n/de.qm \
                    qml/waxmppplugin/i18n/es.qm \
                    qml/waxmppplugin/i18n/eu.qm \
                    qml/waxmppplugin/i18n/fa.qm \
                    qml/waxmppplugin/i18n/hr.qm \
                    qml/waxmppplugin/i18n/it.qm \
                    qml/waxmppplugin/i18n/nl.qm \
                    qml/waxmppplugin/i18n/ru.qm \
                    qml/waxmppplugin/i18n/sq.qm \
                    qml/waxmppplugin/i18n/tr.qm \
                    qml/waxmppplugin/i18n/vi.qm

translation.path = /opt/waxmppplugin/qml/waxmppplugin/i18n
INSTALLS += translation



#notificationicons.files = icon-m-low-power-mode-wazapp-message.png \
                          #icon-s-status-notifier-wazapp-message.png \
                          #icon-s-status-wazapp-message.png

#notificationicons.path = /usr/share/themes/base/meegotouch/icons
#INSTALLS += notificationicons

#notificationiconx.files = icon-m-low-power-mode-wazapp-message.png \
#                          icon-s-status-notifier-wazapp-message.png \
#                          icon-s-status-wazapp-message.png

#notificationiconx.path = /usr/share/themes/blanco/meegotouch/icons

#INSTALLS += notificationiconx


notificationconf.files = wazapp.message.new.conf wazapp.message.chat.conf
notificationconf.path = /usr/share/meegotouch/notifications/eventtypes

INSTALLS += notificationconf


notificationicons.files = icon-m-low-power-mode-wazapp.png \
                          icon-s-status-notifier-wazapp.png
notificationicons.path = /usr/share/themes/blanco/meegotouch/icons

INSTALLS += notificationicons

contextprovider.files = org.tgalal.wazapp.context
contextprovider.path = /usr/share/contextkit/providers

INSTALLS += contextprovider


HEADERS += \
    waaccount.h \
    warequest.h \
    wacoderequest.h \
    waexistsrequest.h \
    utilities.h \
    smshandler.h \
    waregrequest.h

OTHER_FILES += \
    qtc_packaging/debian_harmattan/rules \
    qtc_packaging/debian_harmattan/README \
    qtc_packaging/debian_harmattan/manifest.aegis \
    qtc_packaging/debian_harmattan/copyright \
    qtc_packaging/debian_harmattan/control \
    qtc_packaging/debian_harmattan/compat \
    qtc_packaging/debian_harmattan/changelog \
    qtc_packaging/debian_harmattan/links \
    waxmpp.provider \
    invoker/waxmppaccount \
    waxmpp.service \
    wazapp.message.new.conf \
    qtc_packaging/debian_harmattan/postinst \
    qtc_packaging/debian_harmattan/rules \
    qtc_packaging/debian_harmattan/README \
    qtc_packaging/debian_harmattan/manifest.aegis \
    qtc_packaging/debian_harmattan/copyright \
    qtc_packaging/debian_harmattan/control \
    qtc_packaging/debian_harmattan/compat \
    qtc_packaging/debian_harmattan/changelog \
    qtc_packaging/debian_harmattan/postinst \
    qtc_packaging/debian_harmattan/prerm

contains(MEEGO_EDITION,harmattan) {
    desktopfile.files = waxmppplugin.desktop
    desktopfile.path = /usr/share/applications
    INSTALLS += desktopfile
}



