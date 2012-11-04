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

    function resetSelections(){
        contactlist.resetSelections()
    }

    function positionViewAtBeginning (){
        contactlist.positionViewAtBeginning()
    }

    function unbindSlots(){
        selected.disconnect()
    }

    function select(ind){return contactlist.select(ind);}
    function unSelect(ind){return contactlist.unSelect(ind);}


    WAHeader{
        id:header
        anchors.top:parent.top
        width:parent.width
        height: 73
    }

    WAListView{
        id: contactlist
        defaultPicture: defaultProfilePicture
        anchors.top:header.bottom
        model: getContacts()
        useRoundedImages: false

        onSelected:{ consoleDebug("from contacts"); contactsSelectorPage.selected(selectedItem);}
    }

}
