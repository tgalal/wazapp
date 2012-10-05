// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import "../common"
import "../common/WAListView"

WAPage{
    id:contactsSelectorPage
    property alias title:header.title
    property alias multiSelectmode:contactlist.multiSelectMode

    signal selected(variant selectedItem);

    function getSelected(){
        return contactlist.getSelected()
    }

    WAHeader{
        id:header
        anchors.top:parent.top
        width:parent.width
        height: 73
    }

    WAListView{
        id: contactlist
        defaultPicture: "../common/images/user.png"
        anchors.top:header.bottom
        model: getContacts()

        onSelected:{ consoleDebug("from contacts"); contactsSelectorPage.selected(selectedItem);}
    }

}
