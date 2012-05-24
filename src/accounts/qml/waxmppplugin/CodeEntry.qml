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
