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

Page {

    tools: regTools
    anchors.fill: parent
    //property string cc:actor.getCc();
    property string cc;
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
                text: qsTrId("Next")
                //enabled: mainPage.checkFilled()
                onClicked: {
                    if(number_field.value.length >5){


                        if(number_field.value.charAt(0) == '0'){
                            number_field.value = number_field.value.substring(1,number_field.value.length)
                        }

                         sendConfirm.open()
                    }
                    else{
                        showNotification("Please enter a valid phone number")
                    }


                }
            }
            ToolButton {
                text: qsTrId("Cancel and quit")
                onClicked: Qt.quit()
            }
        }
    }

    Column{
        anchors.fill: parent


        WAHeader{
            id:header;
            width:parent.width
            title: "Voice Reg"
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
                    label: "Country code"
                     width:parent.width
                     input_size: "small"
                     value: countriesModel.get(cc_selector.selectedIndex).cc
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
                    label:"Enter your phone number, without your country code"
                    width:parent.width
                    value:number
                    inputMethodHints: Qt.ImhDigitsOnly

                }

                Label{
                    width:parent.width
                    text:"When you click next, you will receive a call that repeats your verficiation code. Please enter this code in the next screen"
                    font.pixelSize: 15
                }

                Label{
                    width:parent.width
                    text:"*By registering and clicking next you agree to <a href='http://www.whatsapp.com/legal/#TOS'>Whatsapp's terms of service</a>"

                    onLinkActivated: Qt.openUrlExternally(link)
                }



            }
        }
    }



    QueryDialog {
        id: sendConfirm
        titleText: qsTrId("Confirm number")
        message: "You will receive your verification code through a voice call made by Whatsapp to "+cc_field.value+number_field.value+", which must be the phone number you are registering with. Is this phone number correct?"
        acceptButtonText: qsTrId("Yes")
        rejectButtonText: qsTrId("No")
        onAccepted: saveAccount(cc_field.value,number_field.value)
    }
}
