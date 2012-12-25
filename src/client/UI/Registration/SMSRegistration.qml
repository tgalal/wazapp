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
    signal saveAccount(string cc_val, string number_val);
    property alias allFail:all_fail_btn.visible

    anchors.margins: 5

    function showAlternatives(){
        other_methods.visible = true;
    }

    ToolBarLayout {
        id: regTools
        visible: false

        Row
        {
            spacing:3
            anchors.horizontalCenter: parent.horizontalCenter
            ToolButton {
                platformStyle: ToolButtonStyle{inverted: theme.inverted}
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
                 platformStyle: ToolButtonStyle{inverted: theme.inverted}
                text: qsTr("Cancel")
                onClicked: Qt.quit()
            }
        }
    }

    WAHeader{
        id:header;
        width:parent.width
        title:qsTr("Registration")
        height: 73

        MouseArea{
            anchors.fill: parent;

            onClicked: {
                theme.inverted = !theme.inverted
            }
        }
    }

    Column{
        anchors.top: header.bottom
        height: parent.height - header.height
        width: parent.width

        Flickable {
            anchors.fill: parent
            anchors.topMargin: 12
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            clip: true
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
                    inputMethodHints: Qt.ImhDigitsOnly

                }

                Label{
                    width:parent.width
                    text:qsTr("When you click next, Whatsapp will send your verification code. I will attempt to save you the effort of entering this code yourself :)")
                    font.pixelSize: 15
                }
                Column{
                    id:other_methods;
                    visible:false
                    width:parent.width
                    spacing: 10
                    Label{
                        width:parent.width
                        text:qsTr("Or try another method:")
                    }

                    Button{
                        text: qsTr("Code through voice")
                        anchors.horizontalCenter: parent.horizontalCenter
                        onClicked: {
                            voiceRegPage.number = number_field.value
                            appWindow.pageStack.push(voiceRegPage)
                        }
                    }

                    Button{
                        text:qsTr("Enter code manually")
                        anchors.horizontalCenter: parent.horizontalCenter
                        onClicked: {
                            appWindow.pageStack.push(codeEntry)
                        }

                    }

                    Button{
                        id:all_fail_btn
                        visible:false
                        text:qsTr("Everything failing? Try me")
                        anchors.horizontalCenter: parent.horizontalCenter
                        onClicked: {
                            appWindow.pageStack.push(codeEntryLoading);
                            codeEntryLoading.startTimer(10000)
                            appWindow.abraKadabra()
                        }

                    }

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
        message: qsTr("Whatsapp will send an SMS with your 3 digit activation code to %1. Is this phone number correct?").arg(cc_field.value+number_field.value)
        acceptButtonText: qsTr("Yes")
        rejectButtonText: qsTr("No")
        onAccepted: saveAccount(countriesModel.get(cc_selector.selectedIndex).cc,number_field.value)
    }
}
