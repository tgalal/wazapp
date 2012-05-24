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
import QtQuick 1.1
import com.nokia.meego 1.0

Page{
    id:container
    property string cc_val;
    signal sendReg(string number, string cc);
    //function _sendReg(){sendReg(phone_number.text,cc.text)}

    Column{
        //anchors.fill: parent
        anchors{
            left:parent.left
            right:parent.right
        }

        //anchors.centerIn: parent
        spacing:2

        Text {
            id: name
            width:parent.width
        //    anchors.centerIn: parent

            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: qsTr("Please confirm your Country code and Enter your phone Number")
        }

        Row{
            anchors.horizontalCenter: parent.horizontalCenter
            id:cc_fields

            spacing:2
            TextField{
                id:cc
                width:100
                text: cc_val
            }

            TextField{
                width:container.width-20-cc.width-cc_fields.spacing
                text:"Egypt"
                enabled: false
            }
        }

        Text{
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
             width:parent.width
            text:qsTr("Your number without the country code:")
        }

        TextField{
            id:phone_number
            width:container.width-20
            anchors.horizontalCenter:parent.horizontalCenter


        }

        Button{
            text: "Submit"
            width:200
            anchors.right: parent.right
            onClicked:{
                regconfirm.phone_number=cc.text+phone_number.text
                regconfirm.open();
            }

        }
    }






        Dialog{
           // anchors.fill: parent
            property string phone_number;
            id:regconfirm
            width:parent.width
           // Component.onCompleted: {regconfirm.accepted.connect(_sendReg)}

            onAccepted:sendReg(phone_number.text,cc.text)

            title:Text{
                color:"white"
                text:"Please confirm"
            }

            content: Text{
                color:"white"
                width:parent.width
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                  font.pixelSize: 22
                    horizontalAlignment: Text.AlignHCenter
                text:"Whatsapp will send an SMS with your 3 digit activation code to "+regconfirm.phone_number+". Is that phone number correct?"
            }

            buttons:ButtonRow {
                style: ButtonStyle { }
                anchors.horizontalCenter: parent.horizontalCenter


                Button{
                    text:"Yes"
                    onClicked: regconfirm.accept();
                }

                Button{
                    text:"No"
                    onClicked: regconfirm.reject();
                }
            }

        }





}
