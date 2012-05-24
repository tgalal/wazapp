import QtQuick 1.1
import com.nokia.meego 1.0

Page {

    tools: regTools
    anchors.fill: parent
    property string cc:actor.getCc();
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
                text: qsTrId("Cancel")
                onClicked: Qt.quit()
            }
        }
    }

    Column{
        anchors.fill: parent


        WAHeader{
            id:header;
            width:parent.width
            title:"Registration"
        }

        Flickable {
                  width:parent.width
                  height:parent.height - header.height
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
                    inputMethodHints: Qt.ImhDigitsOnly

                }

                Label{
                    width:parent.width
                    text:"When you click next, Whatsapp will send you a 3 digit verification code. I will attempt to save you the effort of entering this code yourself :)"
                    font.pixelSize: 15
                }
                Column{
                    id:other_methods;
                    visible:false
                    width:parent.width
                    spacing: 10
                    Label{
                        width:parent.width
                        text:"Or try another method:"
                    }

                    Button{
                        text: "Code through voice"
                        anchors.horizontalCenter: parent.horizontalCenter
                        onClicked: {
                            voiceRegPage.cc = cc_field.value
                            voiceRegPage.number = number_field.value
                            appWindow.pageStack.push(voiceRegPage)
                        }
                    }

                    Button{
                        text:"Enter code manually"
                        anchors.horizontalCenter: parent.horizontalCenter
                        onClicked: {
                            appWindow.pageStack.push(codeEntry)
                        }

                    }

                    Button{
                        id:all_fail_btn
                        visible:false
                        text:"Everything failing? Try me"
                        anchors.horizontalCenter: parent.horizontalCenter
                        onClicked: {
                            appWindow.pageStack.push(codeEntryLoading);
                            codeEntryLoading.startTimer(10000)
                            actor.abraKadabra()
                        }

                    }

                }

                Label{
                    width:parent.width
                    text:"*By registering you agree to <a href='http://www.whatsapp.com/legal/#TOS'>Whatsapp's terms of service</a>"
                    onLinkActivated: Qt.openUrlExternally(link)
                }
            }
        }
    }





    QueryDialog {
        id: sendConfirm
        titleText: qsTrId("Confirm number")
        message: "Whatsapp will send an SMS with your 3 digit activation code to "+cc_field.value+number_field.value+". Is this phone number correct?"
        acceptButtonText: qsTrId("Yes")
        rejectButtonText: qsTrId("No")
        onAccepted: saveAccount(cc_field.value,number_field.value)
    }
}
