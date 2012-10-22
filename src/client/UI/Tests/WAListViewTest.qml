// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0
import "../common"
import "../common/WAListView"
import "js/testshelpers.js" as MyFunctions

WAPage {
   tools:wlvtools
    onStatusChanged: {
        if(status == PageStatus.Active){
            var arrData = new Array(),
                    sorted;
            for(var i=0; i<100; i++){
                arrData.push({name:MyFunctions.makeid(5)})
            }

            sorted = arrData.sort(function(a, b){
                 var keyA = a.name,
                 keyB = b.name;
                 // Compare the 2 dates
                 if(keyA < keyB) return -1;
                 if(keyA > keyB) return 1;
                 return 0;
             });

            mylistmodel.clear();
            for(var i=0; i<sorted.length; i++){

                mylistmodel.append(sorted[i])
            }
             mylist.model = mylistmodel
        }
    }


    WAListView{
        id:mylist
        anchors.fill: parent
        allowFastScroll: true
        multiSelectMode: true
        defaultPicture: "../common/images/user.png"

    }

    ListModel{
        id:mylistmodel
    }

    ToolBarLayout {
        id:wlvtools

        ToolIcon{
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }

        ToolButton
        {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.centerIn: parent
            width: 300
            text: qsTr("Done")
            onClicked: {

            }

        }
    }

}
