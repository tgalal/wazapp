// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0
//import com.nokia.extras 1.0

import "../common"
import "../EmojiDialog"
import "../About"
import "../Misc"
import "../Registration"


WAStackWindow{
    id:appWindow
    initialPage: mainPage
    showToolBar: true;
    property string myBackgroundImage;
    property int myBackgroundOpacity;
    property string defaultProfilePicture: "common/images/user.png"
    property string connectionStatus:"online"

    property int count:0;

    signal setBackground;

    function consoleDebug(d){
        console.log(d);
    }

    WAPage{
        id:mainPage

        WANotify{
            id:wa_notifier
            state:"connecting"
        }

        Column{
            anchors.centerIn: parent
            spacing:5

            Button{
                text: "Test WAListView"
                onClicked: {
                    appWindow.pageStack.push(walistviewtest)
                }
            }

            Button{
                text: "Test WAImageViewer"
                onClicked: {
                    appWindow.pageStack.push(waimageviwertest)
                }
            }

            Button{
                text: "Test WATextArea"
                onClicked: {
                    appWindow.pageStack.push(watextareatest)
                }
            }

            Button{
                text: "Test About Dialog"
                onClicked: {
                    aboutDialog.open();
                }
            }

            Button{
                text: "Support Wazapp"
                onClicked: {
                   appWindow.pageStack.push(supportPage)
                }
            }

            Button{
                text: "Test Splash"
                onClicked: {
                   appWindow.pageStack.push(splashPage)
                }
            }

            Button{
                text: "Edit account"
                onClicked: {
                   appWindow.pageStack.push(editPage)
                }
            }
        }
    }

    EditPage{
        id: editPage
        expiration: "123456"
        kind: "free"
        phoneNumber: "1234567890"
        pushName: "tgalal"

        ToolBarLayout {
            id: editTools
            visible: false

            ToolButtonRow {
                //spacing: 5
                //anchors.verticalCenter: parent.verticalCenter
                ToolButton {
                    platformStyle: ToolButtonStyle{inverted: theme.inverted}

                    text: qsTrId("Save")
                    //enabled: mainPage.checkFilled()
                    onClicked: editPage.saveAccount()
                }
                ToolButton {
                    platformStyle: ToolButtonStyle{inverted: theme.inverted}
                    text: qsTrId("Cancel")
                    onClicked: Qt.quit()
                }
            }

            ToolIcon {
                platformIconId: "toolbar-view-menu"
               // anchors.right: (parent === undefined) ? undefined : parent.right
                onClicked: (myMenu.status == DialogStatus.Closed) ? myMenu.open() : myMenu.close()
            }
        }
    }

   // WATextAreaTest{
    //    id:watextareatest
    //}

    WAListViewTest{
        id:walistviewtest
    }

    WAImageViewerTest{
        id:waimageviwertest
    }

    AboutDialog{
        id:aboutDialog
        wazappVersion: "0.9.2"
        yowsupVersion: typeof(interfaceVersion)!="undefined"?interfaceVersion:"0.0"
    }

    WASupport{
        id:supportPage
    }

    WACredits{
        id:creditsPage
    }

    WASplash{
        id:splashPage
    }



}
