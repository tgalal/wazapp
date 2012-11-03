// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0
//import com.nokia.extras 1.0

import "../common"
import "../EmojiDialog"
import "../About"
import "../Misc"


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
        }
    }

    WATextAreaTest{
        id:watextareatest
    }

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
