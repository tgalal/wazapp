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
