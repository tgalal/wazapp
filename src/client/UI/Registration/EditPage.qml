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
import QtQuick 1.1
import com.nokia.meego 1.0
import "../common"
Page{
    property string phoneNumber;
    property string pushName;
    property string status:"Offline"

    property string expiration:typeof(accountExpiration) !== "undefined"? accountExpiration:""
    property string kind:typeof(accountKind) !== "undefined"? accountKind: ""

    function saveAccount()
    {
        if(push_field.value.trim() == ""){
            showNotification(qsTr("Push name cannot be left empty"))
        }
        else{
            appWindow.savePushName(push_field.value)
            showNotification(qsTr("Push name saved"));
            Qt.quit()
        }
    }

    tools:editTools
//    anchors.margins: 5

    WAHeader{
        id:h
        width:parent.width
        height:73
        title:qsTr("Edit account")
        anchors.top:parent.top
    }

    Flickable{
       anchors.bottom: parent.bottom
       anchors.left: parent.left
       anchors.right: parent.right
       anchors.top: h.bottom
       anchors.margins: 10
       contentHeight: acctDatacontainer.height
       clip: true

       Column{

           id:acctDatacontainer
           spacing:5
           anchors.top: parent.top
           anchors.left: parent.left
           anchors.right: parent.right

            LabeledValue{
                label: qsTr("Account")
                value: phoneNumber
            }

            LabeledValue {
                label: qsTr("Account type")
                value: kind
                visible: kind?true:false
                width:parent.width
            }

            LabeledValue {
                label: qsTr("Expiry date")
                value: expiration
                visible: expiration?true:false
                width:parent.width
            }

            Separator{
                height: 30
            }

            LabeledField{
                id:push_field
                label: qsTr("Your push name")
                width:parent.width
                value: pushName?pushName:"";
            }
       }

    }
}
