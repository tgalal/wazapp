// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0
import "../common"
import "../common/WAListView"

WAPage{
    id:phoneContactsSelectorPage
    property alias title:header.title
    property alias multiSelectmode:contactlist.multiSelectMode
    property alias allowFastScroll:contactlist.allowFastScroll
    property alias allowRemove:contactlist.allowRemove
    property alias state:contactlist.state

    property bool _loadedSent:false

    signal loadedPhoneContacts()
    signal removed(int index);
    signal selected(variant selectedItem);

    onStatusChanged: {
        if(status == PageStatus.Active){
            loadPhoneContacts();
        }
    }

    function loadPhoneContacts(){
        if (phoneContactsModel.count==0) {

            appWindow.phoneContactsReady.connect(onPhoneContactsReady)
            populatePhoneContacts()

        } else{
                onPhoneContactsReady();
            }
    }

    function select(ind){return contactlist.select(ind);}
    function unSelect(ind){return contactlist.unSelect(ind);}

    function getSelected(){
        return contactlist.getSelected()
    }

    function getPhoneContactsViews(){
        return contactlist.getItems()
    }

    function onPhoneContactsReady() {

        if(!_loadedSent){
            console.log("GOT IT")
            contactlist.model = phoneContactsModel;
            loadedPhoneContacts()
            _loadedSent = true
        }

    }


    WAHeader{
        id:header
        anchors.top:parent.top
        width:parent.width
        height: 73
    }


    WAListView{
        id: contactlist
        defaultPicture: defaultProfilePicture
        useRoundedImages: false
        anchors.top:header.bottom
        //model: getPhoneContacts()

        onSelected:{phoneContactsSelectorPage.selected(selectedItem);}
        onRemoved: {phoneContactsSelectorPage.removed(index)}
    }

}
