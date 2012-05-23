import QtQuick 1.1
import QtMobility.feedback 1.1
import com.nokia.meego 1.0

Menu {
    id: myMenu
    property bool updateVisible:false
   // visualParent: pageStack

    signal syncClicked();
    signal aboutClicked();

        MenuLayout {
       // MenuItem { text: qsTr("Reset profile/Register") }
        //MenuItem { text: qsTr("Settings") }

         MenuItem{
                visible:updateVisible
                text:"Update Wazapp"
                onClicked:{appWindow.pageStack.push(updatePage)}
         }

        MenuItem {
            id:sync_item
            text: qsTr("Sync Contacts");
            onClicked: {console.log("SYNC");syncClicked();}
            }

        /*MenuItem{
            text:appWindow.stealth?qsTr("Normal Mode"):qsTr("Stealth Mode!");
            onClicked:appWindow.stealth?appWindow.normalMode():appWindow.stealthMode();
        }*/

        MenuItem{
            text:"Invert Colors"
            onClicked:{appWindow.normalMode();theme.inverted = !theme.inverted}
        }


        MenuItem {
               text: qsTr("About")
               onClicked: aboutClicked();
        }


        MenuItem{
            text:qsTr("Quit")
            onClicked:appWindow.quitInit();
        }



    }
}
