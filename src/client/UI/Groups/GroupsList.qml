// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0
import "../common"
import "../common/WAListView"


WAPage{
    id:groupsSelectorPage
    property alias title:header.title

    signal selected(variant selectedItem);

    onStatusChanged: {

        consoleDebug("STATUS CHANGED")

        if(status == PageStatus.Activating) {

            consoleDebug("ACTIVATING!!");
            var groups = getGroups();
            groupslist.model = groups

            consoleDebug("OK")

        }
    }




    WAHeader{
        id:header
        anchors.top:parent.top
        width:parent.width
        height: 73
    }



    WAListView{
        id: groupslist
        defaultPicture: "../common/images/user.png"
        anchors.top:header.bottom
       // model: getGroups();


        onSelected:{ consoleDebug("from groups");groupsSelectorPage.selected(selectedItem);}
    }

}
