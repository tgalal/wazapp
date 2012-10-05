import "../Contacts"
import "../Groups"
import "../common"
import QtQuick 1.1
import com.nokia.meego 1.0
WAPage {
    id: selectorroot
    property alias contactsTitle:contactsSelector.title
    property alias groupsTitle:groupsSelector.title
    property int show:2 //0:all, 1:contacts, 2:groups
    property bool multiSelect:false

    signal selected(variant selectedItem)

    tools:selectorTools


    TabGroup {
        id: tabGroups
        currentTab: contactsSelector

       SyncedContactsList{
            id:contactsSelector

            Connections {
                onSelected:selected(selectedItem)
            }
            height: parent.height
        }
        GroupsList {
            id: groupsSelector
            Connections {
                onSelected:selected(selectedItem)
            }
            height: parent.height
        }
    }

    ToolBarLayout {

        id:selectorTools

        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }

        ButtonRow {
            style: TabButtonStyle { inverted:theme.inverted }

            TabButton {
                id: contactsButton
                platformStyle: TabButtonStyle{inverted:theme.inverted}
                text: qsTr("Contacts")
                //iconSource: "image://theme/icon-m-toolbar-new-chat" + (theme.inverted ? "-white" : "")
                tab: contactsSelector
            }
            TabButton {
                id: groupsbButton
                platformStyle: TabButtonStyle{inverted: theme.inverted}
                text: qsTr("Groups")
                //iconSource: "common/images/book" + (theme.inverted ? "-white" : "") + ".png";
                tab: groupsSelector
            }
        }


    }
}
