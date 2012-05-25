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

    signal saveAccount(string code);

    anchors.margins: 5


    Column{
        anchors.fill: parent
        WAHeader{
            title: "Code Entry"
            width:parent.width
        }

        LabeledField{
            id:codeField
            label: "Enter your 3 digit verification code"
            inputMethodHints: Qt.ImhDigitsOnly
            input_size: "medium"
            width:parent.width
        }

    }


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
                    if(codeField.value.length ==3){

                        saveAccount(codeField.value);
                    }
                    else{
                        showNotification("Please enter a valid code")
                    }
                }
            }
            ToolButton {
                text: qsTrId("Cancel and quit")
                onClicked: Qt.quit()
            }
        }
    }

    Label{
        width:parent.width
        text:"*By registering and clicking next you agree to <a href='http://www.whatsapp.com/legal/#TOS'>Whatsapp's terms of service</a>"
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        onLinkActivated: Qt.openUrlExternally(link)
    }
}
