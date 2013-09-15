import QtQuick 1.1
import com.nokia.meego 1.0
import "../common"

Dialog {
    id:aboutDialogRoot
    width: parent.width
    height: parent.height
    property string wazappVersion
    property string yowsupVersion

    SelectionDialogStyle { id: dialog}

    state: (screen.currentOrientation == Screen.Portrait) ? "portrait" : "landscape"

    states: [
        State {
            name: "landscape"

            PropertyChanges{target:dataHeader;  parent:landscapeRow; width: (aboutDialogRoot.width/2) + 50}
            PropertyChanges{target:aboutData; parent:landscapeRow; x:0; }
            //PropertyChanges{target:followHeader; visible: true}

        }
    ]

    /*title: Column{
        id:titleContainer
        width:parent.width
        anchors.top:parent.top
        WAHeader{
                height:73
                title: "Wazapp 0.9.5"
            }
    }*/

    content: Item {

        width: parent.width
        height:aboutDialogRoot.height - 50 // titleContainer.height-50
        anchors.top:parent.top
        anchors.topMargin: 10

        Row{
            id:landscapeRow
            spacing:5

            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter

           }

        Column {
            id:portraitColumn
            width:aboutDialogRoot.width
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10


            Column{
                id:dataHeader
                width:aboutDialogRoot.width
                spacing:10
                Image{
                    id:wazappIcon
                    //anchors.horizontalCenter: parent.horizontalCenter
                    source: "../common/images/icons/wazapp128.png"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Label{
                    id:wazappVersion
                    color:"white"
                    text:"Wazapp "+aboutDialogRoot.wazappVersion
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Label{
                    id:descText
                    color:"white"
                    text:qsTr("Part of OpenWhatsapp Project")
                    anchors.horizontalCenter: parent.horizontalCenter
                }


                Label{
                    id:copyrightText
                    color:"white"
                    text:"(c) 2012, Tarek Galal"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Item{
                    width:parent.width
                    height:11

                    Rectangle{
                        color:"gray"
                        width:parent.width
                        height:1
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Label{
                    id:yowsupVersion
                    color:"white"
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:qsTr("Using Yowsup ")+aboutDialogRoot.yowsupVersion
                }
                Row{
                    anchors.horizontalCenter: parent.horizontalCenter
                    Label{
                        color:"white"
                        text:qsTr("Connection Status")+": "
                    }

                    Label{
                        id:connectionStatusIndicator
                        color:connectionStatus=="online"?"green":(connectionStatus=="connecting"?"#19649c":"red")
                        text:connectionStatus=="online"?qsTr("Online"):(connectionStatus=="connecting"?qsTr("Connecting"):qsTr("Offline"))
                    }
                }


            }



            Column {
                id:aboutData
                 //id:aboutDataColumn
                width:browserButton.width

                x:(aboutDialogRoot.width/2) - browserButton.width/2

                spacing:10


                /*WAHeader{
                    id:followHeader
                    width:parent.width
                    title: "Follow Wazapp"
                    height:75
                    visible: false
                }*/

                ImageTextLink{
                    id:browserButton
                    source: "images/icons/browser.png"
                    text:"openwhatsapp.org"
                    url:"http://www.openwhatsapp.org"
                    inverted: true

                }
                ImageTextLink{
                    source: "images/icons/twitter.png"
                    text:"@tgalal"
                    url:"http://twitter.com/tgalal"
                    inverted: true
                }

                ImageTextLink{
                    source: "images/icons/facebook.png"
                    text:"fb.me/OpenWhatsapp"
                    url: "http://www.fb.me/OpenWhatsapp"
                    inverted: true
                }

                /*Label{
                    text:qsTr("Wazapp is a free software created entirely by the N9 Community. If you enjoy using Wazapp, you can help and support it by making a donation. Your donation helps maintain and further develop Wazapp and keep it always Free Software")
                    width:aboutData.width
                    horizontalAlignment: Text.AlignHCenter
                    color:"white"

                }*/

                Item{
                    width:parent.width
                    height:5

                    Rectangle{
                        color:"gray"
                        width:parent.width
                        height:1
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                ImageTextLink{
                    id:supportButton
                   //anchors.horizontalCenter: parent.horizontalCenter
                    source:"images/icons/support.png"
                    text:qsTr("Support Wazapp")+"!"
                    onClicked: {
                        close()
                        pageStack.push(supportPage)
                    }
                    //inverted: true
                }

                Item{
                    width:parent.width
                    height:5

                    Rectangle{
                        color:"gray"
                        width:parent.width
                        height:1
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                ImageTextLink{
                    id:creditsButton
                    inverted: true
                   //anchors.horizontalCenter: parent.horizontalCenter
                    source:"../common/images/icons/wazapp48.png"
                    text:qsTr("Credits")
                    onClicked: {
                        close()
                        pageStack.push(creditsPage)
                    }
                }

            }

        }

    }

}
