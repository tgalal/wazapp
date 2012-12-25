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

Page {

    tools: regTools
    anchors.fill: parent
    property string number;
    signal saveAccount(string cc_val, string number_val);

    anchors.margins: 5

    ToolBarLayout {
        id: regTools
        visible: false

        Row
        {
            spacing:3
            anchors.horizontalCenter: parent.horizontalCenter
            ToolButton {
                text: qsTr("Next")
                //enabled: mainPage.checkFilled()
                onClicked: {
                    if(number_field.value.length >5){


                        if(number_field.value.charAt(0) == '0'){
                            number_field.value = number_field.value.substring(1,number_field.value.length)
                        }

                         sendConfirm.open()
                    }
                    else{
                        showNotification(qsTr("Please enter a valid phone number"))
                    }


                }
            }
            ToolButton {
                text: qsTr("Cancel and quit")
                onClicked: Qt.quit()
            }
        }
    }

    Column{
        anchors.fill: parent


        WAHeader{
            id:header;
            width:parent.width
            title: qsTr("Voice Reg")
            height:73
        }

        Flickable {
                  width:parent.width
                  height:parent.height - header.height
                  anchors.margins: 5
                  contentWidth: width
                  contentHeight: form_column.height
                  boundsBehavior: Flickable.StopAtBounds
            Column{
                spacing:10
                width:parent.width
                id:form_column

                Button {
                     id:cc_button
                     text:  countriesModel.get(cc_selector.selectedIndex).name
                     onClicked: {
                         cc_selector.open()
                     }
                     width:parent.width-10
                     anchors.horizontalCenter: parent.horizontalCenter
                 }

                LabeledField{
                    id:cc_field
                    label: qsTr("Country code")
                     width:parent.width
                     input_size: "small"
                     value: "+" + countriesModel.get(cc_selector.selectedIndex).cc
                     inputMethodHints: Qt.ImhDigitsOnly
                     enabled: false


                     MouseArea{
                         anchors.fill: parent
                         onClicked: {
                             cc_selector.open()
                         }
                     }
                }

                LabeledField{
                    id:number_field
                    label:qsTr("Enter your phone number, without your country code")
                    width:parent.width
                    value:number
                    inputMethodHints: Qt.ImhDigitsOnly

                }

                Label{
                    width:parent.width
                    text:qsTr("When you click next, you will receive a call that repeats your verficiation code. Please enter this code in the next screen")
                    font.pixelSize: 15
                }

                Label{
                    width:parent.width
                    text:qsTr("*By registering and clicking next you agree to <a href='http://www.whatsapp.com/legal/#TOS'>Whatsapp's terms of service</a>")
                    onLinkActivated: Qt.openUrlExternally(link)
                }



            }
        }
    }



    QueryDialog {
        id: sendConfirm
        titleText: qsTr("Confirm number")
        message: qsTr("You will receive your verification code through a voice call made by Whatsapp to %1, which must be the phone number you are registering with. Is this phone number correct?").arg(cc_field.value+number_field.value)
        acceptButtonText: qsTr("Yes")
        rejectButtonText: qsTr("No")
        onAccepted: saveAccount(countriesModel.get(cc_selector.selectedIndex).cc,number_field.value)
    }
}
